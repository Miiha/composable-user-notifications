import Foundation
import ComposableArchitecture
import ComposableUserNotifications
import UIKit

struct App: Reducer {
  struct State: Equatable {
    var count: Int?
  }

  enum Action: Equatable {
    case addNotificationResponse(TaskResult<Unit>)
    case didFinishLaunching
    case didReceiveBackgroundNotification(BackgroundNotification)
    case remoteCountResponse(TaskResult<Int>)
    case requestAuthorizationResponse(TaskResult<Bool>)
    case tappedScheduleButton
    case userNotifications(UserNotificationClient.DelegateAction)
  }

  @Dependency(\.remote) var remote
  @Dependency(\.userNotifications) var userNotifications

  func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case .didFinishLaunching:
      // Ensure that the delegate is created within `didFinishLaunchingWithOptions` to
      // receive notifications that started the application.
      let userNotifications = self.userNotifications.delegate()
      return .run { send in
        await withThrowingTaskGroup(of: Void.self) { group in
          group.addTask {
            for await event in userNotifications {
              await send(.userNotifications(event))
            }
          }

          group.addTask {
            await send(
              .requestAuthorizationResponse(
                TaskResult {
                  try await self.userNotifications.requestAuthorization([.alert, .badge, .sound])
                }
              )
            )
          }
        }
      }

    case let .didReceiveBackgroundNotification(backgroundNotification):
      let fetchCompletionHandler = backgroundNotification.fetchCompletionHandler
      guard backgroundNotification.content == .countAvailable else {
        return .run { _ in
          backgroundNotification.fetchCompletionHandler(.noData)
        }
      }

      return .run { send in
        do {
          let count = try await self.remote.fetchRemoteCount()
          fetchCompletionHandler(.newData)
          await send(.remoteCountResponse(.success(count)))
        } catch {
          fetchCompletionHandler(.failed)
          await send(.remoteCountResponse(.failure(error)))
        }
      }

    case let .remoteCountResponse(.success(count)):
      state.count = count
      return .none

    case .remoteCountResponse(.failure):
      return .none

    case let .userNotifications(.willPresentNotification(_, completion)):
      return .run { _ in
        completion([.list, .banner, .sound])
      }

    case let .userNotifications(.didReceiveResponse(response, completion)):
      let userInfo = response.notification.request.content.userInfo
      let notification = UserNotification(userInfo: userInfo)
      if case let .count(value) = notification {
        state.count = value
      }

      return .run { _ in
        completion()
      }

    case .userNotifications(.openSettingsForNotification):
      return .none

    case .requestAuthorizationResponse:
      return .none

    case .addNotificationResponse:
      return .none

    case .tappedScheduleButton:
      let content = UNMutableNotificationContent()
      content.title = "Example title"
      content.body = "Example body"
      content.userInfo = ["count": 123]

      let request = UNNotificationRequest(
        identifier: "example_notification",
        content: content,
        trigger: UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
      )

      return .run { send in
        await self.userNotifications
          .removePendingNotificationRequestsWithIdentifiers(["example_notification"])
        await send(
          await .addNotificationResponse(
            TaskResult {
              Unit(try await self.userNotifications.add(request))
            }
          )
        )
      }
    }
  }
}

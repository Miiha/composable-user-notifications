//
//  AppState.swift
//  Example
//
//  Created by Michael Kao on 31.10.20.
//

import Foundation
import ComposableArchitecture
import ComposableUserNotifications
import UIKit

struct AppState: Equatable {
  var count: Int?
}

enum AppAction: Equatable {
  case addNotificationResponse(Result<Unit, UserNotificationClient.Error>)
  case didFinishLaunching(notification: UserNotification?)
  case didReceiveBackgroundNotification(BackgroundNotification)
  case remoteCountResponse(Result<Int, RemoteClient.Error>)
  case requestAuthorizationResponse(Result<Bool, UserNotificationClient.Error>)
  case tappedScheduleButton
  case userNotification(UserNotificationClient.Action)
}

struct AppEnvironment {
  var remoteClient: RemoteClient
  var userNotificationClient: UserNotificationClient
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
  switch action {
  case let .didFinishLaunching(notification):
    if case let .count(value) = notification {
      state.count = value
    }

    return .merge(
      environment.userNotificationClient
        .delegate()
        .map(AppAction.userNotification),
      environment.userNotificationClient.requestAuthorization([.alert, .badge, .sound])
        .catchToEffect()
        .map(AppAction.requestAuthorizationResponse)
      )

  case let .didReceiveBackgroundNotification(backgroundNotification):
    let fetchCompletionHandler = backgroundNotification.fetchCompletionHandler
    guard backgroundNotification.content == .countAvailable else {
      return .fireAndForget {
        backgroundNotification.fetchCompletionHandler(.noData)
      }
    }

    return environment.remoteClient.fetchRemoteCount()
      .catchToEffect()
      .handleEvents(receiveOutput: { result in
        switch result {
        case .success:
          fetchCompletionHandler(.newData)
        case .failure:
          fetchCompletionHandler(.failed)
        }
      })
      .eraseToEffect()
      .map(AppAction.remoteCountResponse)

  case let .remoteCountResponse(.success(count)):
    state.count = count
    return .none

  case .remoteCountResponse(.failure):
    return .none

  case let .userNotification(.willPresentNotification(notification, completion)):
    return .fireAndForget {
      completion([.list, .banner, .sound])
    }

  case let .userNotification(.didReceiveResponse(response, completion)):
    let notification = UserNotification(userInfo: response.notification.request.content.userInfo())
    if case let .count(value) = notification {
      state.count = value
    }

    return .fireAndForget {
      completion()
    }

  case .userNotification(.openSettingsForNotification):
    return .none

  case .requestAuthorizationResponse:
    return .none

  case .addNotificationResponse:
    return .none

  case .tappedScheduleButton:
    let content = UNMutableNotificationContent()
    content.title = "Example title"
    content.body = "Example body"

    let request = UNNotificationRequest(
      identifier: "example_notification",
      content: content,
      trigger: UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
    )

    return .concatenate(
      environment.userNotificationClient.removePendingNotificationRequestsWithIdentifiers(["example_notification"])
        .map(absurd),
      environment.userNotificationClient.add(request)
        .map(Unit.init)
        .catchToEffect()
        .map(AppAction.addNotificationResponse)
    )
  }
}

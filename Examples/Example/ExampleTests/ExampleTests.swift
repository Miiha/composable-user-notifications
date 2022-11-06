import Combine
import ComposableArchitecture
import ComposableUserNotifications
import struct ComposableUserNotifications.Notification
import XCTest
@testable import Example

@MainActor
class ExampleTests: XCTestCase {
  func testApplicationLaunchWithoutNotification() async throws {
    let delegate = AsyncStream<UserNotificationClient.DeletegateAction>.streamWithContinuation()
    let requestedAuthorizationOptions = ActorIsolated<UNAuthorizationOptions?>(nil)
    let store = TestStore(
      initialState: App.State(count: nil),
      reducer: App()
    )
    store.dependencies.userNotifications.delegate = { delegate.stream }
    store.dependencies.userNotifications.requestAuthorization = { options in
      await requestedAuthorizationOptions.setValue(options)
      return true
    }
    let task = await store.send(.didFinishLaunching(notification: nil))
    await store.receive(.requestAuthorizationResponse(.success(true)))
    await requestedAuthorizationOptions.withValue {
      XCTAssertNoDifference($0, [.alert, .badge, .sound])
    }
    await task.cancel()
  }

  func testApplicationLaunchWithtNotification() async throws {
    let delegate = AsyncStream<UserNotificationClient.DeletegateAction>.streamWithContinuation()
    let requestedAuthorizationOptions = ActorIsolated<UNAuthorizationOptions?>(nil)

    let store = TestStore(
      initialState: App.State(count: nil),
      reducer: App()
    )
    store.dependencies.userNotifications.delegate = { delegate.stream }
    store.dependencies.userNotifications.requestAuthorization = { options in
      await requestedAuthorizationOptions.setValue(options)
      return true
    }

    let task = await store.send(.didFinishLaunching(notification: .count(5))) {
      $0.count = 5
    }
    await store.receive(.requestAuthorizationResponse(.success(true)))
    await requestedAuthorizationOptions.withValue {
      XCTAssertNoDifference($0, [.alert, .badge, .sound])
    }
    await task.cancel()
  }

  func testNotificationPresentationHandling() async throws {
    let delegate = AsyncStream<UserNotificationClient.DeletegateAction>.streamWithContinuation()

    let store = TestStore(
      initialState: App.State(count: nil),
      reducer: App()
    )
    store.dependencies.userNotifications.requestAuthorization = { _ in true }
    store.dependencies.userNotifications.delegate = { delegate.stream }

    let task = await store.send(.didFinishLaunching(notification: nil))
    await store.receive(.requestAuthorizationResponse(.success(true)))

    var notificationPresentationOptions: UNNotificationPresentationOptions?
    let willPresentNotificationCompletionHandler = { notificationPresentationOptions = $0 }
    let content = UNMutableNotificationContent()
    content.userInfo = ["count": 5]
    let notification = Notification(
      date: Date(timeIntervalSince1970: 0),
      request: Notification.Request(
        identifier: "fixture",
        content: Notification.Content(rawValue: content),
        trigger: nil
      )
    )

    delegate.continuation.yield(
      .willPresentNotification(
        notification,
        completionHandler: { willPresentNotificationCompletionHandler($0) }
      )
    )
    await store.receive(
      .userNotifications(
        .willPresentNotification(
          notification,
          completionHandler: willPresentNotificationCompletionHandler
        )
      )
    )
    XCTAssertNoDifference(notificationPresentationOptions, [.list, .banner, .sound])
    await task.cancel()
  }

  func testReceivedNotification() async throws {
    let delegate = AsyncStream<UserNotificationClient.DeletegateAction>.streamWithContinuation()

    let store = TestStore(
      initialState: App.State(count: nil),
      reducer: App()
    )
    store.dependencies.userNotifications.requestAuthorization = { _ in true }
    store.dependencies.userNotifications.delegate = { delegate.stream }

    let task = await store.send(.didFinishLaunching(notification: nil))
    await store.receive(.requestAuthorizationResponse(.success(true)))

    var didReceiveResponseCompletionHandlerCalled = false
    let didReceiveResponseCompletionHandler = { didReceiveResponseCompletionHandlerCalled = true }
    let content = UNMutableNotificationContent()
    content.userInfo = ["count": 5]
    let response = Notification.Response.user(
      Notification.Response.UserAction(
        actionIdentifier: "fixture",
        notification: Notification(
          date: Date(timeIntervalSince1970: 0),
          request: Notification.Request(
            identifier: "fixture",
            content: Notification.Content(rawValue: content),
            trigger: nil
          )
        )
      )
    )

    delegate.continuation.yield(
      .didReceiveResponse(response, completionHandler: { didReceiveResponseCompletionHandler() })
    )
    await store.receive(
      .userNotifications(
        .didReceiveResponse(
          response,
          completionHandler: didReceiveResponseCompletionHandler
        )
      )
    ) {
      $0.count = 5
    }
    XCTAssert(didReceiveResponseCompletionHandlerCalled)
    await task.cancel()
  }

  func testReceiveBackgroundNotification() async throws {
    let store = TestStore(
      initialState: App.State(count: nil),
      reducer: App()
    )
    store.dependencies.remote.fetchRemoteCount = { 5 }

    var backgroundFetchResult: UIBackgroundFetchResult?
    let backgroundNotification = BackgroundNotification(
      appState: .inactive,
      content: .countAvailable,
      fetchCompletionHandler: { backgroundFetchResult = $0 }
    )

    await store.send(.didReceiveBackgroundNotification(backgroundNotification))
    await store.receive(.remoteCountResponse(.success(5))) {
      $0.count = 5
    }
    XCTAssertNoDifference(backgroundFetchResult, .newData)
  }

  func testReceiveBackgroundNotificationFailure() async throws {
    let store = TestStore(
      initialState: App.State(count: nil),
      reducer: App()
    )
    struct Error: Swift.Error, Equatable {}
    store.dependencies.remote.fetchRemoteCount = { throw Error() }

    var backgroundFetchResult: UIBackgroundFetchResult?
    let backgroundNotification = BackgroundNotification(
      appState: .inactive,
      content: .countAvailable,
      fetchCompletionHandler: { backgroundFetchResult = $0 }
    )

    await store.send(.didReceiveBackgroundNotification(backgroundNotification))
    await store.receive(.remoteCountResponse(.failure(Error())))
    XCTAssertNoDifference(backgroundFetchResult, .failed)
  }

  func testReceiveBackgroundNotificationWithoutContent() async throws {
    let store = TestStore(
      initialState: App.State(count: nil),
      reducer: App()
    )

    var backgroundFetchResult: UIBackgroundFetchResult?
    let backgroundNotification = BackgroundNotification(
      appState: .inactive,
      content: nil,
      fetchCompletionHandler: { backgroundFetchResult = $0 }
    )

    await store.send(.didReceiveBackgroundNotification(backgroundNotification))
    XCTAssertNoDifference(backgroundFetchResult, .noData)
  }

  func testTappedScheduleButton() async throws {
    let store = TestStore(
      initialState: App.State(count: nil),
      reducer: App()
    )

    let notificationRequest = ActorIsolated<UNNotificationRequest?>(nil)
    let removedPendingIdentifiers = ActorIsolated<[String]?>(nil)

    store.dependencies.userNotifications.add = { request in
      await notificationRequest.setValue(request)
    }
    store.dependencies.userNotifications.removePendingNotificationRequestsWithIdentifiers = { identifiers in
      await removedPendingIdentifiers.setValue(identifiers)
    }

    await store.send(.tappedScheduleButton)
    await store.receive(.addNotificationResponse(.success(Unit())))
    await removedPendingIdentifiers.withValue {
      XCTAssertNoDifference($0, ["example_notification"])
    }
    await notificationRequest.withValue {
      XCTAssertEqual($0?.content.title, "Example title")
      XCTAssertEqual($0?.content.body, "Example body")
      XCTAssertTrue($0?.trigger is UNTimeIntervalNotificationTrigger)
      XCTAssertEqual(
        ($0?.trigger as? UNTimeIntervalNotificationTrigger)?.timeInterval,
        5
      )
    }
  }
}

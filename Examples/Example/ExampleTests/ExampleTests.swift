//
//  ExampleTests.swift
//  ExampleTests
//
//  Created by Michael Kao on 31.10.20.
//

import Combine
import ComposableArchitecture
import ComposableUserNotifications
import struct ComposableUserNotifications.Notification
import XCTest
@testable import Example

class ExampleTests: XCTestCase {
  var environment = AppEnvironment(
    remoteClient: RemoteClient(fetchRemoteCount: { Effect(value: 5) }),
    userNotificationClient: .mock(
      requestAuthorization: { _ in Effect(value: true) }
    )
  )

  func testApplicationLaunchWithoutNotification() throws {
    let delegateActionSubject = PassthroughSubject<UserNotificationClient.Action, Never>()
    var didSubscribeNotifications = false
    var didRequestAuthrizationOptions: UNAuthorizationOptions?
    environment.userNotificationClient.requestAuthorization = { options in
      didRequestAuthrizationOptions = options
      return Effect(value: true)
    }

    environment.userNotificationClient.delegate = {
      didSubscribeNotifications = true
      return delegateActionSubject.eraseToEffect()
    }

    TestStore(
      initialState: AppState(count: nil),
      reducer: appReducer,
      environment: environment
    ).assert(
      .send(.didFinishLaunching(notification: nil)),
      .receive(.requestAuthorizationResponse(.success(true))),
      .do { XCTAssertEqual(didRequestAuthrizationOptions, [.alert, .badge, .sound]) },
      .do { XCTAssertTrue(didSubscribeNotifications) },
      .do { delegateActionSubject.send(completion: .finished) }
    )
  }

  func testApplicationLaunchWithtNotification() throws {
    let delegateActionSubject = PassthroughSubject<UserNotificationClient.Action, Never>()
    environment.userNotificationClient.delegate = { delegateActionSubject.eraseToEffect() }

    TestStore(
      initialState: AppState(count: nil),
      reducer: appReducer,
      environment: environment
    ).assert(
      .send(.didFinishLaunching(notification: .count(5))) {
        $0.count = 5
      },
      .receive(.requestAuthorizationResponse(.success(true))),
      .do { delegateActionSubject.send(completion: .finished) }
    )
  }


  func testNotificationPresentationHandling() throws {
    let delegateActionSubject = PassthroughSubject<UserNotificationClient.Action, Never>()
    environment.userNotificationClient.delegate = { delegateActionSubject.eraseToEffect() }

    var presentationOptions: UNNotificationPresentationOptions?
    let completion = { presentationOptions = $0 }

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

    TestStore(
      initialState: AppState(count: nil),
      reducer: appReducer,
      environment: environment
    ).assert(
      .send(.didFinishLaunching(notification: nil)),
      .receive(.requestAuthorizationResponse(.success(true))),
      .do { delegateActionSubject.send(.willPresentNotification(notification, completion: completion)) },
      .receive(.userNotification(.willPresentNotification(notification, completion: completion))),
      .do { XCTAssertEqual(presentationOptions, [.list, .banner, .sound]) },
      .do { delegateActionSubject.send(completion: .finished) }
    )
  }

  func testReceivedNotification() throws {
    let delegateActionSubject = PassthroughSubject<UserNotificationClient.Action, Never>()
    environment.userNotificationClient.delegate = { delegateActionSubject.eraseToEffect() }

    var didComplete = false
    let completion = { didComplete = true }

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

    TestStore(
      initialState: AppState(count: nil),
      reducer: appReducer,
      environment: environment
    ).assert(
      .send(.didFinishLaunching(notification: nil)),
      .receive(.requestAuthorizationResponse(.success(true))),
      .do { delegateActionSubject.send(.didReceiveResponse(response, completion: completion)) },
      .receive(.userNotification(.didReceiveResponse(response, completion: completion))) {
        $0.count = 5
      },
      .do { XCTAssertTrue(didComplete) },
      .do { delegateActionSubject.send(completion: .finished) }
    )
  }

  func testReceiveBackgroundNotification() throws {
    let delegateActionSubject = PassthroughSubject<UserNotificationClient.Action, Never>()
    environment.userNotificationClient.delegate = { delegateActionSubject.eraseToEffect() }

    var backgroundFetchResult: UIBackgroundFetchResult?
    let backgroundNotification = BackgroundNotification(
      appState: .inactive,
      content: .countAvailable,
      fetchCompletionHandler: { backgroundFetchResult = $0 }
    )

    TestStore(
      initialState: AppState(count: nil),
      reducer: appReducer,
      environment: environment
    ).assert(
      .send(.didReceiveBackgroundNotification(backgroundNotification)),
      .receive(.remoteCountResponse(.success(5))) {
        $0.count = 5
      },
      .do { XCTAssertEqual(backgroundFetchResult, .newData) },
      .do { delegateActionSubject.send(completion: .finished) }
    )
  }

  func testReceiveBackgroundNotificationFailure() throws {
    let delegateActionSubject = PassthroughSubject<UserNotificationClient.Action, Never>()
    environment.userNotificationClient.delegate = { delegateActionSubject.eraseToEffect() }
    environment.remoteClient.fetchRemoteCount = { Effect(error: RemoteClient.Error()) }

    var backgroundFetchResult: UIBackgroundFetchResult?
    let backgroundNotification = BackgroundNotification(
      appState: .inactive,
      content: .countAvailable,
      fetchCompletionHandler: { backgroundFetchResult = $0 }
    )

    TestStore(
      initialState: AppState(count: nil),
      reducer: appReducer,
      environment: environment
    ).assert(
      .send(.didReceiveBackgroundNotification(backgroundNotification)),
      .receive(.remoteCountResponse(.failure(RemoteClient.Error()))),
      .do { XCTAssertEqual(backgroundFetchResult, .failed) },
      .do { delegateActionSubject.send(completion: .finished) }
    )
  }

  func testReceiveBackgroundNotificationWithoutContent() throws {
    let delegateActionSubject = PassthroughSubject<UserNotificationClient.Action, Never>()
    environment.userNotificationClient.delegate = { delegateActionSubject.eraseToEffect() }

    var backgroundFetchResult: UIBackgroundFetchResult?
    let backgroundNotification = BackgroundNotification(
      appState: .inactive,
      content: nil,
      fetchCompletionHandler: { backgroundFetchResult = $0 }
    )

    TestStore(
      initialState: AppState(count: nil),
      reducer: appReducer,
      environment: environment
    ).assert(
      .send(.didReceiveBackgroundNotification(backgroundNotification)),
      .do { XCTAssertEqual(backgroundFetchResult, .noData) },
      .do { delegateActionSubject.send(completion: .finished) }
    )
  }

  func testTappedScheduleButton() throws {
    var notificationRequest: UNNotificationRequest?
    environment.userNotificationClient.add = { request in
      notificationRequest = request
      return Effect(value: ())
    }
    var removedPendingIdentifiers: [String]?
    environment.userNotificationClient.removePendingNotificationRequestsWithIdentifiers = { identifiers in
      removedPendingIdentifiers = identifiers
      return .fireAndForget {}
    }

    TestStore(
      initialState: AppState(count: nil),
      reducer: appReducer,
      environment: environment
    ).assert(
      .send(.tappedScheduleButton),
      .receive(.addNotificationResponse(.success(Unit()))),
      .do { XCTAssertEqual(removedPendingIdentifiers, ["example_notification"]) },
      .do { XCTAssertEqual(notificationRequest?.content.title, "Example title") },
      .do { XCTAssertEqual(notificationRequest?.content.body, "Example body") },
      .do { XCTAssertTrue(notificationRequest?.trigger is UNTimeIntervalNotificationTrigger) },
      .do { XCTAssertEqual(
        (notificationRequest?.trigger as? UNTimeIntervalNotificationTrigger)?.timeInterval, 5
      )}
    )
  }
}

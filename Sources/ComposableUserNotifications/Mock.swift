import Foundation
import ComposableArchitecture
import UserNotifications

extension UserNotificationClient {
  @available(tvOS, unavailable)
  static func mock(
    add: @escaping (UNNotificationRequest) -> Effect<Void, Error> = { _ in
      _unimplemented("add")
    },
    getDeliveredNotifications: @escaping () -> Effect<[Notification], Never> = {
      _unimplemented("getDeliveredNotifications")
    },
    getNotificationCategories: @escaping () -> Effect<Set<UNNotificationCategory>, Never> = {
      _unimplemented("getNotificationCategories")
    },
    getNotificationSettings: @escaping () -> Effect<NotificationSettings, Never> = {
      _unimplemented("getNotificationSettings")
    },
    getPendingNotificationRequests: @escaping () -> Effect<[NotificationRequest], Never> = {
      _unimplemented("getPendingNotificationRequests")
    },
    removeAllDeliveredNotifications: @escaping () -> Void = {
      _unimplemented("removeAllDeliveredNotifications")
    },
    removeAllPendingNotificationRequests: @escaping () -> Void = {
      _unimplemented("removeAllPendingNotificationRequests")
    },
    removeDeliveredNotifications: @escaping ([String]) -> Void = { _ in
      _unimplemented("removeDeliveredNotifications")
    },
    removePendingNotificationRequests: @escaping ([String]) -> Void = { _ in
      _unimplemented("removePendingNotificationRequests")
    },
    requestAuthorization: @escaping (UNAuthorizationOptions) -> Effect<Bool, NSError> = { _ in
      _unimplemented("requestAuthorization")
    },
    setNotificationCategories: @escaping (Set<UNNotificationCategory>) -> Void = { _ in
      _unimplemented("setNotificationCategories")
    },
    supportsContentExtensions: @escaping () -> Bool = {
      _unimplemented("setNotificationCategories")
    },
    delegate: @escaping () -> Effect<Action, Never> = {
      _unimplemented("getDeliveredNotifications")
    }
  ) -> Self {
    Self(
      add: add,
      getDeliveredNotifications: getDeliveredNotifications,
      getNotificationCategories: getNotificationCategories,
      getNotificationSettings: getNotificationSettings,
      getPendingNotificationRequests: getPendingNotificationRequests,
      removeAllDeliveredNotifications: removeAllDeliveredNotifications,
      removeAllPendingNotificationRequests: removeAllPendingNotificationRequests,
      removeDeliveredNotifications: removeDeliveredNotifications,
      removePendingNotificationRequests: removePendingNotificationRequests,
      requestAuthorization: requestAuthorization,
      setNotificationCategories: setNotificationCategories,
      supportsContentExtensions: supportsContentExtensions,
      delegate: delegate
    )
  }

  @available(iOS, unavailable)
  @available(watchOS, unavailable)
  @available(macOS, unavailable)
  @available(macCatalyst, unavailable)
  static func mock(
    add: @escaping (UNNotificationRequest) -> Effect<Void, Error> = { _ in
      _unimplemented("add")
    },
    getNotificationSettings: @escaping () -> Effect<NotificationSettings, Never> = {
      _unimplemented("getNotificationSettings")
    },
    getPendingNotificationRequests: @escaping () -> Effect<[NotificationRequest], Never> = {
      _unimplemented("getPendingNotificationRequests")
    },
    removeAllPendingNotificationRequests: @escaping () -> Void = {
      _unimplemented("removeAllPendingNotificationRequests")
    },
    removePendingNotificationRequests: @escaping ([String]) -> Void = { _ in
      _unimplemented("removePendingNotificationRequests")
    },
    requestAuthorization: @escaping (UNAuthorizationOptions) -> Effect<Bool, NSError> = { _ in
      _unimplemented("requestAuthorization")
    },
    supportsContentExtensions: @escaping () -> Bool = {
      _unimplemented("setNotificationCategories")
    },
    delegate: @escaping () -> Effect<Action, Never> = {
      _unimplemented("getDeliveredNotifications")
    }
  ) -> Self {
    Self(
      add: add,
      getNotificationSettings: getNotificationSettings,
      getPendingNotificationRequests: getPendingNotificationRequests,
      removeAllPendingNotificationRequests: removeAllPendingNotificationRequests,
      removePendingNotificationRequests: removePendingNotificationRequests,
      requestAuthorization: requestAuthorization,
      supportsContentExtensions: supportsContentExtensions,
      delegate: delegate
    )
  }
}

// see https://github.com/pointfreeco/swift-composable-architecture/blob/d39022f32b27725c5cdd24febc789f0933fa2329/Sources/ComposableCoreLocation/Mock.swift#L323
func _unimplemented(
  _ function: StaticString, file: StaticString = #file, line: UInt = #line
) -> Never {
  fatalError(
    """
    `\(function)` was called but is not implemented. Be sure to provide an implementation for
    this endpoint when creating the mock.
    """,
    file: file,
    line: line
  )
}

import Foundation
import ComposableArchitecture
import UserNotifications

extension UserNotificationClient {
  @available(tvOS, unavailable)
  public static func mock(
    add: @escaping (UNNotificationRequest) -> Effect<Void, Error> = { _ in
      _unimplemented("add")
    },
    getDeliveredNotifications: @escaping () -> Effect<[Notification], Never> = {
      _unimplemented("getDeliveredNotifications")
    },
    getNotificationCategories: @escaping () -> Effect<Set<UNNotificationCategory>, Never> = {
      _unimplemented("getNotificationCategories")
    },
    getNotificationSettings: @escaping () -> Effect<Notification.Settings, Never> = {
      _unimplemented("getNotificationSettings")
    },
    getPendingNotificationRequests: @escaping () -> Effect<[Notification.Request], Never> = {
      _unimplemented("getPendingNotificationRequests")
    },
    removeAllDeliveredNotifications: @escaping () -> Effect<Never, Never> = {
      _unimplemented("removeAllDeliveredNotifications")
    },
    removeAllPendingNotificationRequests: @escaping () -> Effect<Never, Never> = {
      _unimplemented("removeAllPendingNotificationRequests")
    },
    removeDeliveredNotificationsWithIdentifiers: @escaping ([String]) -> Effect<Never, Never> = { _ in
      _unimplemented("removeDeliveredNotificationsWithIdentifiers")
    },
    removePendingNotificationRequestsWithIdentifiers: @escaping ([String]) -> Effect<Never, Never> = { _ in
      _unimplemented("removePendingNotificationRequestsWithIdentifiers")
    },
    requestAuthorization: @escaping (UNAuthorizationOptions) -> Effect<Bool, Error> = { _ in
      _unimplemented("requestAuthorization")
    },
    setNotificationCategories: @escaping (Set<UNNotificationCategory>) -> Effect<Never, Never> = { _ in
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
      removeDeliveredNotificationsWithIdentifiers: removeDeliveredNotificationsWithIdentifiers,
      removePendingNotificationRequestsWithIdentifiers: removePendingNotificationRequestsWithIdentifiers,
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
  public static func mock(
    add: @escaping (UNNotificationRequest) -> Effect<Void, Error> = { _ in
      _unimplemented("add")
    },
    getNotificationSettings: @escaping () -> Effect<Notification.Settings, Never> = {
      _unimplemented("getNotificationSettings")
    },
    getPendingNotificationRequests: @escaping () -> Effect<[Notification.Request], Never> = {
      _unimplemented("getPendingNotificationRequests")
    },
    removeAllPendingNotificationRequests: @escaping () -> Effect<Never, Never> = {
      _unimplemented("removeAllPendingNotificationRequests")
    },
    removePendingNotificationRequestsWithIdentifiers: @escaping ([String]) -> Effect<Never, Never> = { _ in
      _unimplemented("removePendingNotificationRequestsWithIdentifiers")
    },
    requestAuthorization: @escaping (UNAuthorizationOptions) -> Effect<Bool, Error> = { _ in
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
      removePendingNotificationRequestsWithIdentifiers: removePendingNotificationRequestsWithIdentifiers,
      requestAuthorization: requestAuthorization,
      supportsContentExtensions: supportsContentExtensions,
      delegate: delegate
    )
  }
}

public func _unimplemented(
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

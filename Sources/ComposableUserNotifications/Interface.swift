import CoreLocation
import ComposableArchitecture
import UserNotifications

/// A wrapper around UserNotifications's `UNUserNotificationCenter` that exposes its functionality through
/// effects and actions, making it easy to use with the Composable Architecture and easy to test.
@available(iOS 10.0, *)
@available(macCatalyst 13.0, *)
@available(macOS 10.14, *)
@available(tvOS 10.0, *)
@available(watchOS 3.0, *)
public struct UserNotificationClient {
  /// Actions that correspond to `UNUserNotificationCenterDelegate` methods.
  ///
  /// See `UNUserNotificationCenterDelegate` for more information.
  public enum Action {
    case willPresentNotification(
          _ notification: Notification,
          completion: (UNNotificationPresentationOptions) -> Void)

    @available(tvOS, unavailable)
    case didReceiveResponse(_ response: Notification.Response, completion: () -> Void)

    case openSettingsForNotification(_ notification: Notification?)
  }

  public var add: (UNNotificationRequest) -> Effect<Void, Error> = { _ in
    _unimplemented("add")
  }

  @available(tvOS, unavailable)
  public var getDeliveredNotifications: () -> Effect<[Notification], Never> = {
    _unimplemented("getDeliveredNotifications")
  }

  @available(tvOS, unavailable)
  public var getNotificationCategories: () -> Effect<Set<UNNotificationCategory>, Never> = {
    _unimplemented("getNotificationCategories")
  }

  public var getNotificationSettings: () -> Effect<Notification.Settings, Never> = {
    _unimplemented("getNotificationSettings")
  }

  public var getPendingNotificationRequests: () -> Effect<[Notification.Request], Never> = {
    _unimplemented("getPendingNotificationRequests")
  }

  @available(tvOS, unavailable)
  public var removeAllDeliveredNotifications: () -> Effect<Never, Never> = {
    _unimplemented("removeAllDeliveredNotifications")
  }

  public var removeAllPendingNotificationRequests: () -> Effect<Never, Never> = {
    _unimplemented("removeAllPendingNotificationRequests")
  }

  @available(tvOS, unavailable)
  public var removeDeliveredNotificationsWithIdentifiers: ([String]) -> Effect<Never, Never> = { _ in
    _unimplemented("removeDeliveredNotificationsWithIdentifiers")
  }

  public var removePendingNotificationRequestsWithIdentifiers: ([String]) -> Effect<Never, Never> = { _ in
    _unimplemented("removePendingNotificationRequestsWithIdentifiers")
  }

  public var requestAuthorization: (UNAuthorizationOptions) -> Effect<Bool, Error> = { _ in
    _unimplemented("requestAuthorization")
  }

  @available(tvOS, unavailable)
  public var setNotificationCategories: (Set<UNNotificationCategory>) -> Effect<Never, Never> = { _ in
    _unimplemented("setNotificationCategories")
  }

  public var supportsContentExtensions: () -> Bool = {
    _unimplemented("supportsContentExtensions")
  }

  /// This Effect represents calls to the `UNUserNotificationCenterDelegate`.
  /// Handling the completion handlers of the `UNUserNotificationCenterDelegate`s methods
  /// by multiple observers might lead to unexpected behaviour.
  public var delegate: () -> Effect<Action, Never> = {
    _unimplemented("delegate")
  }

  public struct Error: Swift.Error, Equatable {
    public let error: NSError

    public init(_ error: Swift.Error) {
      self.error = error as NSError
    }
  }
}

extension UserNotificationClient.Action: Equatable {
  public static func == (lhs: UserNotificationClient.Action, rhs: UserNotificationClient.Action) -> Bool {
    switch (lhs, rhs) {
    case let (.willPresentNotification(lhs, _), .willPresentNotification(rhs, _)):
      return lhs == rhs
    #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
    case let (.didReceiveResponse(lhs, _), .didReceiveResponse(rhs, _)):
      return lhs == rhs
    #endif
    case let (.openSettingsForNotification(lhs), .openSettingsForNotification(rhs)):
      return lhs == rhs
    default:
      return false
    }
  }
}

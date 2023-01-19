import CoreLocation
import ComposableArchitecture
import UserNotifications
import XCTestDynamicOverlay

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
  public enum DelegateAction {
    case willPresentNotification(
          _ notification: Notification,
          completionHandler: (UNNotificationPresentationOptions) -> Void)

    @available(tvOS, unavailable)
    case didReceiveResponse(_ response: Notification.Response, completionHandler: () -> Void)

    case openSettingsForNotification(_ notification: Notification?)
  }

  public var add: @Sendable (UNNotificationRequest) async throws -> Void  =
    unimplemented("\(Self.self).add")

  @available(tvOS, unavailable)
  public var deliveredNotifications: @Sendable () async -> [Notification] = unimplemented("\(Self.self).deliveredNotifications")

  @available(tvOS, unavailable)
  public var notificationCategories: () async -> Set<UNNotificationCategory> = unimplemented("\(Self.self).deliveredNotifications")

  public var notificationSettings: () async -> Notification.Settings = unimplemented("\(Self.self).notificationSettings")

  public var pendingNotificationRequests: () async -> [Notification.Request] = unimplemented("\(Self.self).pendingNotificationRequests")

  @available(tvOS, unavailable)
  public var removeAllDeliveredNotifications: () async -> Void = unimplemented("\(Self.self).removeAllDeliveredNotifications")

  public var removeAllPendingNotificationRequests: () async -> Void = unimplemented("\(Self.self).removeAllPendingNotificationRequests")

  @available(tvOS, unavailable)
  public var removeDeliveredNotificationsWithIdentifiers: ([String]) async -> Void = unimplemented("\(Self.self).removeDeliveredNotificationsWithIdentifiers")

  public var removePendingNotificationRequestsWithIdentifiers: ([String]) async -> Void = unimplemented("\(Self.self).removePendingNotificationRequestsWithIdentifiers")

  public var requestAuthorization: (UNAuthorizationOptions) async throws -> Bool =
    unimplemented("\(Self.self).requestAuthorization")

  @available(tvOS, unavailable)
  public var setNotificationCategories: (Set<UNNotificationCategory>) async -> Void = unimplemented("\(Self.self).setNotificationCategories")

  public var supportsContentExtensions: () -> Bool = unimplemented("\(Self.self).supportsContentExtensions")

  /// This Effect represents calls to the `UNUserNotificationCenterDelegate`.
  /// Handling the completion handlers of the `UNUserNotificationCenterDelegate`s methods
  /// by multiple observers might lead to unexpected behaviour.
  public var delegate: @Sendable () -> AsyncStream<DelegateAction> = unimplemented("\(Self.self).delegate", placeholder: .finished)
}

extension UserNotificationClient.DelegateAction: Equatable {
  public static func == (lhs: UserNotificationClient.DelegateAction, rhs: UserNotificationClient.DelegateAction) -> Bool {
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

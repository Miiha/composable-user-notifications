import Foundation
import CoreLocation
import ComposableArchitecture
import UserNotifications

@available(iOS 10.0, *)
@available(macCatalyst 13.0, *)
@available(macOS 10.14, *)
@available(tvOS 10.0, *)
@available(watchOS 3.0, *)
public struct UserNotificationClient {
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

  public var getNotificationSettings: () -> Effect<NotificationSettings, Never> = {
    _unimplemented("getNotificationSettings")
  }

  public var getPendingNotificationRequests: () -> Effect<[NotificationRequest], Never> = {
    _unimplemented("getPendingNotificationRequests")
  }

  @available(tvOS, unavailable)
  public var removeAllDeliveredNotifications: () -> Void = {
    _unimplemented("removeAllDeliveredNotifications")
  }

  public var removeAllPendingNotificationRequests: () -> Void = {
    _unimplemented("removeAllPendingNotificationRequests")
  }

  @available(tvOS, unavailable)
  public var removeDeliveredNotifications: ([String]) -> Void = { _ in
    _unimplemented("removeDeliveredNotifications")
  }

  public var removePendingNotificationRequests: ([String]) -> Void = { _ in
    _unimplemented("removePendingNotificationRequests")
  }

  public var requestAuthorization: (UNAuthorizationOptions) -> Effect<Bool, NSError> = { _ in
    _unimplemented("requestAuthorization")
  }

  @available(tvOS, unavailable)
  public var setNotificationCategories: (Set<UNNotificationCategory>) -> Void = { _ in
    _unimplemented("setNotificationCategories")
  }

  public var supportsContentExtensions: () -> Bool = {
    _unimplemented("supportsContentExtensions")
  }

  public var delegate: () -> Effect<Action, Never> = {
    _unimplemented("delegate")
  }

  public enum Action {
    case willPresentNotification(
          _ notification: Notification,
          completion: (UNNotificationPresentationOptions) -> Void)

    @available(tvOS, unavailable)
    case didReceiveResponse(_ response: NotificationResponseType, completion: () -> Void)

    case openSettingsForNotification(_ notification: Notification?)
  }
}

public struct Notification {
  public let rawValue: UNNotification?

  public var date: Date
  public var request: NotificationRequest

  public init(rawValue: UNNotification) {
    self.rawValue = rawValue
    self.date = rawValue.date
    self.request = NotificationRequest(rawValue: rawValue.request)
  }
}

public struct NotificationRequest {
  public let rawValue: UNNotificationRequest?

  public var identifier: String
  public var content: NotificationContent
  public var trigger: NotificationTrigger?

  public init(rawValue: UNNotificationRequest) {
    self.rawValue = rawValue
    self.identifier = rawValue.identifier
    self.content = NotificationContent(rawValue: rawValue.content)

    self.trigger = {
      switch rawValue.trigger {
      case let trigger as UNPushNotificationTrigger:
        return PushNotificationTrigger(rawValue: trigger)
      case let trigger as UNCalendarNotificationTrigger:
        return CalendarNotificationTrigger(rawValue: trigger)
      #if os(iOS) || os(watchOS)
      case let trigger as UNLocationNotificationTrigger:
        return LocationNotificationTrigger(rawValue: trigger)
      #endif
      default:
        return nil
      }
    }()
  }
}

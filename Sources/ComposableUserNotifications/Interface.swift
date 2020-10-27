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

  public var getAuthStatus: () -> Effect<UNAuthorizationStatus, Never> = {
    _unimplemented("getAuthStatus")
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

public struct NotificationContent {
  public let rawValue: UNNotificationContent?

  public var title: String
  public var subtitle: String
  public var body: String
  public var badge: NSNumber?
  public var sound: UNNotificationSound?
//  public var launchImageName: String
  public var userInfo: [AnyHashable : Any]
  public var attachments: [NotificationAttachment]
  public var summaryArgument: String
  public var summaryArgumentCount: Int
  public var categoryIdentifier: String
  public var threadIdentifier: String
  public var targetContentIdentifier: String?

  public init(rawValue: UNNotificationContent) {
    self.rawValue = rawValue

    self.title = rawValue.title
    self.subtitle = rawValue.subtitle
    self.body = rawValue.body
    self.badge = rawValue.badge
    self.sound = rawValue.sound
//    self.launchImageName = rawValue.launchImageName
    self.userInfo = rawValue.userInfo
    self.attachments = rawValue.attachments.map(NotificationAttachment.init)
    self.summaryArgument = rawValue.summaryArgument
    self.summaryArgumentCount = rawValue.summaryArgumentCount
    self.categoryIdentifier = rawValue.categoryIdentifier
    self.threadIdentifier = rawValue.threadIdentifier
    self.targetContentIdentifier = rawValue.targetContentIdentifier
  }
}

public struct NotificationAttachment: Equatable {
  public let rawValue: UNNotificationAttachment

  public var identifier: String
  public var url: URL
  public var type: String

  public init(rawValue: UNNotificationAttachment) {
    self.rawValue = rawValue
    self.identifier = rawValue.identifier
    self.url = rawValue.url
    self.type = rawValue.type
  }
}

public protocol NotificationTrigger {
  var repeats: Bool { get }
}

public struct PushNotificationTrigger: NotificationTrigger {
  public let repeats: Bool

  public init(rawValue: UNPushNotificationTrigger) {
    self.repeats = rawValue.repeats
  }
}

public struct TimeIntervalNotificationTrigger: NotificationTrigger {
  public let rawValue: UNTimeIntervalNotificationTrigger?

  public var repeats: Bool
  public var timeInterval: TimeInterval
  public var nextTriggerDate: () -> Date?

  init(rawValue: UNTimeIntervalNotificationTrigger) {
    self.rawValue = rawValue

    self.repeats = rawValue.repeats
    self.timeInterval = rawValue.timeInterval
    self.nextTriggerDate = rawValue.nextTriggerDate
  }

  public static func == (lhs: TimeIntervalNotificationTrigger, rhs: TimeIntervalNotificationTrigger) -> Bool {
    lhs.repeats == rhs.repeats && lhs.timeInterval == rhs.timeInterval
  }
}

public struct CalendarNotificationTrigger: NotificationTrigger {
  public let rawValue: UNCalendarNotificationTrigger?

  public var repeats: Bool
  public var dateComponents: DateComponents
  public var nextTriggerDate: () -> Date?

  init(rawValue: UNCalendarNotificationTrigger) {
    self.rawValue = rawValue
    self.repeats = rawValue.repeats
    self.dateComponents = rawValue.dateComponents
    self.nextTriggerDate = rawValue.nextTriggerDate
  }

  public static func == (lhs: CalendarNotificationTrigger, rhs: CalendarNotificationTrigger) -> Bool {
    lhs.repeats == rhs.repeats && lhs.dateComponents == rhs.dateComponents
  }
}

@available(macOS, unavailable)
public struct LocationNotificationTrigger: NotificationTrigger {
  public let rawValue: UNLocationNotificationTrigger?

  public var repeats: Bool
  public var region: Region

  init(rawValue: UNLocationNotificationTrigger) {
    self.rawValue = rawValue
    self.repeats = rawValue.repeats
    self.region = Region(rawValue: rawValue.region)
  }
}

public protocol NotificationResponseType {
  var actionIdentifier: String  { get }
  var notification: Notification { get }
}

@available(tvOS, unavailable)
public struct NotificationResponse: NotificationResponseType {
  public let rawValue: UNNotificationResponse?

  public var actionIdentifier: String
  public var notification: Notification

  public init(rawValue: UNNotificationResponse) {
    self.rawValue = rawValue
    self.actionIdentifier = rawValue.actionIdentifier
    self.notification = Notification(rawValue: rawValue.notification)
  }
}

public struct TextInputNotificationResponse: NotificationResponseType {
  public let rawValue: UNTextInputNotificationResponse?

  public var actionIdentifier: String
  public var notification: Notification
  public var userText: String

  public init(rawValue: UNTextInputNotificationResponse) {
    self.rawValue = rawValue
    self.actionIdentifier = rawValue.actionIdentifier
    self.notification = Notification(rawValue: rawValue.notification)
    self.userText = rawValue.userText
  }
}

public struct NotificationSettings {
  public let rawValue: UNNotificationSettings?

  public var alertSetting: UNNotificationSetting
  public var alertStyle: UNAlertStyle
//  public var announcementSetting: UNNotificationSetting
  public var authorizationStatus: UNAuthorizationStatus
  public var badgeSetting: UNNotificationSetting
//  public var carPlaySetting: UNNotificationSetting
  public var criticalAlertSetting: UNNotificationSetting
  public var lockScreenSetting: UNNotificationSetting
  public var notificationCenterSetting: UNNotificationSetting
  public var providesAppNotificationSettings: Bool
  public var showPreviewsSetting: UNShowPreviewsSetting
  public var soundSetting: UNNotificationSetting

  public init(rawValue: UNNotificationSettings) {
    self.rawValue = rawValue

    self.alertSetting = rawValue.alertSetting
    self.alertStyle = rawValue.alertStyle
//    self.announcementSetting = rawValue.announcementSetting
    self.authorizationStatus = rawValue.authorizationStatus
    self.badgeSetting = rawValue.badgeSetting
//    self.carPlaySetting = rawValue.carPlaySetting
    self.criticalAlertSetting = rawValue.criticalAlertSetting
    self.lockScreenSetting = rawValue.lockScreenSetting
    self.notificationCenterSetting = rawValue.notificationCenterSetting
    self.providesAppNotificationSettings = rawValue.providesAppNotificationSettings
    self.showPreviewsSetting = rawValue.showPreviewsSetting
    self.soundSetting = rawValue.soundSetting
  }
}

// see https://github.com/pointfreeco/swift-composable-architecture/blob/767e1d9553fcee5a95af10e0352f20fb03b98352/Sources/ComposableCoreLocation/Models/Region.swift#L5
public struct Region: Hashable {
  public let rawValue: CLRegion?
  public var identifier: String
  public var notifyOnEntry: Bool
  public var notifyOnExit: Bool

  init(rawValue: CLRegion) {
    self.rawValue = rawValue
    self.identifier = rawValue.identifier
    self.notifyOnEntry = rawValue.notifyOnEntry
    self.notifyOnExit = rawValue.notifyOnExit
  }

  init(
    identifier: String,
    notifyOnEntry: Bool,
    notifyOnExit: Bool
  ) {
    self.rawValue = nil
    self.identifier = identifier
    self.notifyOnEntry = notifyOnEntry
    self.notifyOnExit = notifyOnExit
  }

  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.identifier == rhs.identifier
      && lhs.notifyOnEntry == rhs.notifyOnEntry
      && lhs.notifyOnExit == rhs.notifyOnExit
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.identifier)
    hasher.combine(self.notifyOnExit)
    hasher.combine(self.notifyOnEntry)
  }
}

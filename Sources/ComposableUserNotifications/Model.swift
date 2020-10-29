import UserNotifications
import CoreLocation

public struct Notification: Equatable {
  public let rawValue: UNNotification?

  public var date: Date
  public var request: NotificationRequest

  public init(rawValue: UNNotification) {
    self.rawValue = rawValue

    self.date = rawValue.date
    self.request = NotificationRequest(rawValue: rawValue.request)
  }

  public init(date: Date, request: NotificationRequest) {
    self.rawValue = nil

    self.date = date
    self.request = request
  }
}

public struct NotificationRequest: Equatable {
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
        return .push(NotificationTrigger.PushNotification(rawValue: trigger))
      case let trigger as UNCalendarNotificationTrigger:
        return .calendar(NotificationTrigger.Calendar(rawValue: trigger))
      #if os(iOS) || os(watchOS)
      case let trigger as UNLocationNotificationTrigger:
        return .location(NotificationTrigger.Location(rawValue: trigger))
      #endif
      default:
        return nil
      }
    }()
  }

  public init(identifier: String, content: NotificationContent) {
    self.rawValue = nil

    self.identifier = identifier
    self.content = content
  }
}

public struct NotificationContent: Equatable {
  public var rawValue: UNNotificationContent?

  @available(tvOS, unavailable)
  public var title: () -> String = {
    _unimplemented("title")
  }

  @available(tvOS, unavailable)
  public var subtitle: () -> String = {
    _unimplemented("subtitle")
  }

  @available(tvOS, unavailable)
  public var body: () -> String = {
    _unimplemented("body")
  }

  public var badge: () -> NSNumber? = {
    _unimplemented("badge")
  }

  @available(tvOS, unavailable)
  public var sound: () -> UNNotificationSound? = {
    _unimplemented("sound")
  }

  @available(macOS, unavailable)
  @available(tvOS, unavailable)
  public var launchImageName: () -> String = {
    _unimplemented("launchImageName")
  }

  @available(tvOS, unavailable)
  public var userInfo: () -> [AnyHashable : Any] = {
    _unimplemented("userInfo")
  }

  @available(tvOS, unavailable)
  public var attachments: () -> [NotificationAttachment] = {
    _unimplemented("attachments")
  }

  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
  public var summaryArgument: () -> String = {
    _unimplemented("summaryArgument")
  }

  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
  public var summaryArgumentCount: () -> Int = {
    _unimplemented("summaryArgumentCount")
  }

  @available(tvOS, unavailable)
  public var categoryIdentifier: () -> String = {
    _unimplemented("categoryIdentifier")
  }

  @available(tvOS, unavailable)
  public var threadIdentifier: () -> String = {
    _unimplemented("threadIdentifier")
  }

  public var targetContentIdentifier: () -> String? = {
    _unimplemented("targetContentIdentifier")
  }

  public init(rawValue: UNNotificationContent) {
    self.rawValue = rawValue

    #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
    self.title = { rawValue.title }
    #endif

    #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
    self.subtitle = { rawValue.subtitle }
    #endif

    #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
    self.body = { rawValue.body }
    #endif

    self.badge = { rawValue.badge }

    #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
    self.sound = { rawValue.sound }
    #endif

    #if os(iOS) || os(watchOS) || targetEnvironment(macCatalyst)
    self.launchImageName = { rawValue.launchImageName }
    #endif

    #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
    self.userInfo = { rawValue.userInfo }
    #endif

    #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
    self.attachments = { rawValue.attachments.map(NotificationAttachment.init) }
    #endif

    #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
    self.summaryArgument = { rawValue.summaryArgument }
    #endif

    #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
    self.summaryArgumentCount = { rawValue.summaryArgumentCount }
    #endif

    #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
    self.categoryIdentifier = { rawValue.categoryIdentifier }
    #endif

    #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
    self.threadIdentifier = { rawValue.threadIdentifier }
    #endif

    self.targetContentIdentifier = { rawValue.targetContentIdentifier }
  }

  public static func == (lhs: NotificationContent, rhs: NotificationContent) -> Bool {
    lhs.rawValue == rhs.rawValue
  }
}

@available(tvOS, unavailable)
public struct NotificationAttachment {
  public let rawValue: UNNotificationAttachment?

  public var identifier: String
  public var url: URL
  public var type: String

  public init(rawValue: UNNotificationAttachment) {
    self.rawValue = rawValue

    self.identifier = rawValue.identifier
    self.url = rawValue.url
    self.type = rawValue.type
  }

  public init(identifier: String, url: URL, type: String) {
    self.rawValue = nil

    self.identifier = identifier
    self.url = url
    self.type = type
  }
}

public enum NotificationTrigger: Equatable {
  case push(PushNotification)
  case timeInterval(TimeInterval)
  case calendar(Calendar)

  @available(macOS, unavailable)
  case location(Location)
}

extension NotificationTrigger {
  public struct PushNotification: Equatable {
    public var rawValue: UNPushNotificationTrigger?

    public var repeats: Bool

    public init(rawValue: UNPushNotificationTrigger) {
      self.repeats = rawValue.repeats
    }

    public init(repeats: Bool) {
      self.repeats = repeats
    }

    public static func == (lhs: PushNotification, rhs: PushNotification) -> Bool {
      lhs.rawValue == rhs.rawValue
    }
  }

  public struct TimeInterval: Equatable {
    public let rawValue: UNTimeIntervalNotificationTrigger?

    public var repeats: Bool
    public var timeInterval: Foundation.TimeInterval
    public var nextTriggerDate: () -> Date?

    init(rawValue: UNTimeIntervalNotificationTrigger) {
      self.rawValue = rawValue

      self.repeats = rawValue.repeats
      self.timeInterval = rawValue.timeInterval
      self.nextTriggerDate = rawValue.nextTriggerDate
    }

    public init(repeats: Bool, timeInterval: Foundation.TimeInterval, nextTriggerDate: @escaping () -> Date?) {
      self.rawValue = nil

      self.repeats = repeats
      self.timeInterval = timeInterval
      self.nextTriggerDate = nextTriggerDate
    }

    public static func == (lhs: TimeInterval, rhs: TimeInterval) -> Bool {
      lhs.rawValue == rhs.rawValue
    }
  }

  public struct Calendar: Equatable {
    public let rawValue: UNCalendarNotificationTrigger?

    public var repeats: Bool
    public var dateComponents: DateComponents
    public var nextTriggerDate: () -> Date?

    public init(rawValue: UNCalendarNotificationTrigger) {
      self.rawValue = rawValue

      self.repeats = rawValue.repeats
      self.dateComponents = rawValue.dateComponents
      self.nextTriggerDate = rawValue.nextTriggerDate
    }

    public init(repeats: Bool, dateComponents: DateComponents, nextTriggerDate: @escaping () -> Date?) {
      self.rawValue = nil

      self.repeats = repeats
      self.dateComponents = dateComponents
      self.nextTriggerDate = nextTriggerDate
    }

    public static func == (lhs: Calendar, rhs: Calendar) -> Bool {
      lhs.rawValue == rhs.rawValue
    }
  }

  @available(macOS, unavailable)
  @available(tvOS, unavailable)
  public struct Location: Equatable {
    public let rawValue: UNLocationNotificationTrigger?

    public var repeats: Bool
    public var region: Region

    public init(rawValue: UNLocationNotificationTrigger) {
      self.rawValue = rawValue

      self.repeats = rawValue.repeats
      self.region = Region(rawValue: rawValue.region)
    }

    public init(repeats: Bool, region: Region) {
      self.rawValue = nil

      self.repeats = repeats
      self.region = region
    }
  }
}


@available(tvOS, unavailable)
public enum Response: Equatable {
  case user(UserAction)
  case textInput(TextInputAction)
}

extension Response {
  @available(tvOS, unavailable)
  public struct UserAction: Equatable {
    public let rawValue: UNNotificationResponse?

    public var actionIdentifier: String
    public var notification: Notification

    public init(rawValue: UNNotificationResponse) {
      self.rawValue = rawValue
      self.actionIdentifier = rawValue.actionIdentifier
      self.notification = Notification(rawValue: rawValue.notification)
    }

    public init(actionIdentifier: String, notification: Notification) {
      self.rawValue = nil

      self.actionIdentifier = actionIdentifier
      self.notification = notification
    }
  }

  @available(tvOS, unavailable)
  public struct TextInputAction: Equatable {
    public let rawValue: UNTextInputNotificationResponse?

    public var actionIdentifier: String
    public var notification: Notification
    public var userText: String

    @available(tvOS, unavailable)
    public init(rawValue: UNTextInputNotificationResponse) {
      self.rawValue = rawValue
      self.actionIdentifier = rawValue.actionIdentifier
      self.notification = Notification(rawValue: rawValue.notification)
      self.userText = rawValue.userText
    }

    @available(tvOS, unavailable)
    public init(actionIdentifier: String, notification: Notification, userText: String) {
      self.rawValue = nil

      self.actionIdentifier = actionIdentifier
      self.notification = notification
      self.userText = userText
    }
  }
}

public struct NotificationSettings {
  public var rawValue: () -> UNNotificationSettings? = {
    _unimplemented("rawValue")
  }

  @available(tvOS, unavailable)
  public var alertSetting: () -> UNNotificationSetting = {
    _unimplemented("alertSetting")
  }

  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
  public var alertStyle: () -> UNAlertStyle = {
    _unimplemented("alertStyle")
  }

  @available(macOS, unavailable)
  @available(tvOS, unavailable)
  public var announcementSetting: () -> UNNotificationSetting = {
    _unimplemented("announcementSetting")
  }

  public var authorizationStatus: () -> UNAuthorizationStatus = {
    _unimplemented("authorizationStatus")
  }

  @available(watchOS, unavailable)
  public var badgeSetting: () -> UNNotificationSetting = {
    _unimplemented("badgeSetting")
  }

  @available(macOS, unavailable)
  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
  public var carPlaySetting: () -> UNNotificationSetting = {
    _unimplemented("carPlaySetting")
  }

  @available(tvOS, unavailable)
  public var criticalAlertSetting: () -> UNNotificationSetting = {
    _unimplemented("criticalAlertSetting")
  }

  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
  public var lockScreenSetting: () -> UNNotificationSetting = {
    _unimplemented("lockScreenSetting")
  }

  @available(tvOS, unavailable)
  public var notificationCenterSetting: () -> UNNotificationSetting = {
    _unimplemented("notificationCenterSetting")
  }

  @available(tvOS, unavailable)
  public var providesAppNotificationSettings: () -> Bool = {
    _unimplemented("providesAppNotificationSettings")
  }

  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
  public var showPreviewsSetting: () -> UNShowPreviewsSetting = {
    _unimplemented("showPreviewsSetting")
  }

  @available(tvOS, unavailable)
  public var soundSetting: () -> UNNotificationSetting = {
    _unimplemented("soundSetting")
  }

  public init(rawValue: UNNotificationSettings) {
    self.rawValue = { rawValue }

    #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
    self.alertSetting = { rawValue.alertSetting }
    #endif

    #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
    self.alertStyle = { rawValue.alertStyle }
    #endif

    #if os(iOS) || os(watchOS) || targetEnvironment(macCatalyst)
    self.announcementSetting = { rawValue.announcementSetting }
    #endif

    self.authorizationStatus = { rawValue.authorizationStatus }

    #if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)
    self.badgeSetting = { rawValue.badgeSetting }
    #endif

    #if os(iOS) || targetEnvironment(macCatalyst)
    self.carPlaySetting = { rawValue.carPlaySetting }
    #endif

    #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
    self.criticalAlertSetting = { rawValue.criticalAlertSetting }
    #endif

    #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
    self.lockScreenSetting = { rawValue.lockScreenSetting }
    #endif

    #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
    self.notificationCenterSetting = { rawValue.notificationCenterSetting }
    self.providesAppNotificationSettings = {  rawValue.providesAppNotificationSettings }
    #endif

    #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
    self.showPreviewsSetting = { rawValue.showPreviewsSetting }
    #endif

    #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
    self.soundSetting = { rawValue.soundSetting }
    #endif
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

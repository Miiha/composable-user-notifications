import UserNotifications
import CoreLocation
import XCTestDynamicOverlay

public struct Notification: Equatable {
  public let rawValue: UNNotification?

  public var date: Date
  public var request: Request

  public init(rawValue: UNNotification) {
    self.rawValue = rawValue

    self.date = rawValue.date
    self.request = Request(rawValue: rawValue.request)
  }

  public init(date: Date, request: Request) {
    self.rawValue = nil

    self.date = date
    self.request = request
  }

  public static func == (lhs: Notification, rhs: Notification) -> Bool {
    lhs.rawValue == rhs.rawValue
  }
}

extension Notification {
  public struct Request: Equatable {
    public let rawValue: UNNotificationRequest?

    public var identifier: String
    public var content: UNNotificationContent
    public var trigger: Trigger?

    public init(rawValue: UNNotificationRequest) {
      self.rawValue = rawValue

      self.identifier = rawValue.identifier
      self.content = rawValue.content

      self.trigger = {
        switch rawValue.trigger {
        case let trigger as UNPushNotificationTrigger:
          return .push(Trigger.Push(rawValue: trigger))
        case let trigger as UNCalendarNotificationTrigger:
          return .calendar(Trigger.Calendar(rawValue: trigger))
        case let trigger as UNTimeIntervalNotificationTrigger:
          return .timeInterval(Trigger.TimeInterval(rawValue: trigger))
#if os(iOS) || os(watchOS)
        case let trigger as UNLocationNotificationTrigger:
          return .location(Trigger.Location(rawValue: trigger))
#endif
        default:
          return nil
        }
      }()
    }

    public init(
      identifier: String,
      content: UNNotificationContent,
      trigger: Trigger?
    ) {
      self.rawValue = nil

      self.identifier = identifier
      self.content = content
      self.trigger = trigger
    }

    public static func == (lhs: Request, rhs: Request) -> Bool {
      lhs.rawValue == rhs.rawValue
    }
  }
}

extension Notification {
  public enum Trigger: Equatable {
    case push(Push)
    case timeInterval(TimeInterval)
    case calendar(Calendar)

    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    case location(Location)

    public static func == (lhs: Trigger, rhs: Trigger) -> Bool {
      switch (lhs, rhs) {
      case let (.push(lhs), .push(rhs)):
        return lhs == rhs
      case let (.timeInterval(lhs), .timeInterval(rhs)):
        return lhs == rhs
      case let (.calendar(lhs), .calendar(rhs)):
        return lhs == rhs
#if os(iOS) || os(watchOS) || targetEnvironment(macCatalyst)
      case let (.location(lhs), .location(rhs)):
        return lhs == rhs
#endif
      default:
        return false
      }
    }
  }
}

extension Notification.Trigger {
  public var repeats: Bool {
    switch self {
    case let .push(value):
      return value.repeats
    case let .timeInterval(value):
      return value.repeats
    case let .calendar(value):
      return value.repeats
#if os(iOS) || os(watchOS) || targetEnvironment(macCatalyst)
    case let .location(value):
      return value.repeats
#endif
    }
  }

  public struct Push: Equatable {
    public var rawValue: UNPushNotificationTrigger?

    public var repeats: Bool

    public init(rawValue: UNPushNotificationTrigger) {
      self.repeats = rawValue.repeats
    }

    public init(repeats: Bool) {
      self.repeats = repeats
    }

    public static func == (lhs: Push, rhs: Push) -> Bool {
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

    public init(
      repeats: Bool,
      timeInterval: Foundation.TimeInterval,
      nextTriggerDate: @escaping () -> Date?
    ) {
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

    public init(
      repeats: Bool,
      dateComponents: DateComponents,
      nextTriggerDate: @escaping () -> Date?
    ) {
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

extension Notification {
  @available(tvOS, unavailable)
  public enum Response: Equatable {
    case user(UserAction)
    case textInput(TextInputAction)
  }
}

@available(tvOS, unavailable)
extension Notification.Response {
  public var actionIdentifier: String {
    switch self {
    case let .user(value):
      return value.actionIdentifier
    case let .textInput(value):
      return value.actionIdentifier
    }
  }

  public var notification: Notification {
    switch self {
    case let .user(value):
      return value.notification
    case let .textInput(value):
      return value.notification
    }
  }
}

@available(tvOS, unavailable)
extension Notification.Response {
  public init(rawValue: UNNotificationResponse) {
    switch rawValue {
    case let rawValue as UNTextInputNotificationResponse:
      self = .textInput(TextInputAction(rawValue: rawValue))
    default:
      self = .user(UserAction(rawValue: rawValue))
    }
  }

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

    public init(
      actionIdentifier: String,
      notification: Notification,
      userText: String) {
        self.rawValue = nil

        self.actionIdentifier = actionIdentifier
        self.notification = notification
        self.userText = userText
      }
  }
}

extension Notification {
  public struct Settings: Equatable {
    public var rawValue: () -> UNNotificationSettings? = unimplemented("rawValue")

    @available(tvOS, unavailable)
    public var alertSetting: UNNotificationSetting { _alertSetting() }
    @_spi(Internal)
    public var _alertSetting: () -> UNNotificationSetting = unimplemented("alertSetting")

    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public var alertStyle: UNAlertStyle {
#if !os(tvOS) && !os(watchOS)
      _alertStyle()
#else
      fatalError()
#endif
    }
#if !os(tvOS) && !os(watchOS)
    @_spi(Internal)
    public var _alertStyle: () -> UNAlertStyle = unimplemented("alertStyle")
#endif


    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    public var announcementSetting: UNNotificationSetting {_announcementSetting() }
    @_spi(Internal)
    public var _announcementSetting: () -> UNNotificationSetting = unimplemented(
      "announcementSetting"
    )

    public var authorizationStatus: () -> UNAuthorizationStatus = unimplemented(
      "authorizationStatus"
    )

    @available(watchOS, unavailable)
    public var badgeSetting: UNNotificationSetting { _badgeSetting() }
    @_spi(Internal)
    public var _badgeSetting: () -> UNNotificationSetting = unimplemented("badgeSetting")

    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public var carPlaySetting: UNNotificationSetting { _carPlaySetting() }
    @_spi(Internal)
    public var _carPlaySetting: () -> UNNotificationSetting = unimplemented("carPlaySetting")

    @available(tvOS, unavailable)
    public var criticalAlertSetting: UNNotificationSetting { _criticalAlertSetting() }
    @_spi(Internal)
    public var _criticalAlertSetting: () -> UNNotificationSetting = unimplemented(
      "criticalAlertSetting"
    )

    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public var lockScreenSetting: UNNotificationSetting { _lockScreenSetting() }
    @_spi(Internal)
    public var _lockScreenSetting: () -> UNNotificationSetting = unimplemented("lockScreenSetting")

    @available(tvOS, unavailable)
    public var notificationCenterSetting: UNNotificationSetting { _notificationCenterSetting() }
    @_spi(Internal)
    public var _notificationCenterSetting: () -> UNNotificationSetting = unimplemented(
      "notificationCenterSetting"
    )

    @available(tvOS, unavailable)
    public var providesAppNotificationSettings: Bool { _providesAppNotificationSettings() }
    @_spi(Internal)
    public var _providesAppNotificationSettings: () -> Bool = unimplemented(
      "providesAppNotificationSettings"
    )

    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public var showPreviewsSetting: UNShowPreviewsSetting {
#if !os(tvOS) && !os(watchOS)
      _showPreviewsSetting()
#else
      fatalError()
#endif
    }
#if !os(tvOS) && !os(watchOS)
    @_spi(Internal)
    public var _showPreviewsSetting: () -> UNShowPreviewsSetting = unimplemented(
      "showPreviewsSetting"
    )
#endif

    @available(tvOS, unavailable)
    public var soundSetting: UNNotificationSetting { _soundSetting() }
    @_spi(Internal)
    public var _soundSetting: () -> UNNotificationSetting = unimplemented("soundSetting")

    public init(rawValue: UNNotificationSettings) {
      self.rawValue = { rawValue }

#if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
      self._alertSetting = { rawValue.alertSetting }
#endif

#if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
      self._alertStyle = { rawValue.alertStyle }
#endif

#if os(iOS) || os(watchOS) || targetEnvironment(macCatalyst)
      self._announcementSetting = { rawValue.announcementSetting }
#endif

      self.authorizationStatus = { rawValue.authorizationStatus }

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)
      self._badgeSetting = { rawValue.badgeSetting }
#endif

#if os(iOS) || targetEnvironment(macCatalyst)
      self._carPlaySetting = { rawValue.carPlaySetting }
#endif

#if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
      self._criticalAlertSetting = { rawValue.criticalAlertSetting }
#endif

#if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
      self._lockScreenSetting = { rawValue.lockScreenSetting }
#endif

#if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
      self._notificationCenterSetting = { rawValue.notificationCenterSetting }
      self._providesAppNotificationSettings = {
        rawValue.providesAppNotificationSettings
      }
#endif

#if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
      self._showPreviewsSetting = { rawValue.showPreviewsSetting }
#endif

#if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
      self._soundSetting = { rawValue.soundSetting }
#endif
    }

    public static func == (
      lhs: Notification.Settings,
      rhs: Notification.Settings
    ) -> Bool {
      lhs.rawValue() == rhs.rawValue()
    }
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

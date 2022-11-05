import Foundation
import ComposableArchitecture
import UserNotifications
import XCTestDynamicOverlay

extension DependencyValues {
  public var userNotifications: UserNotificationClient {
    get { self[UserNotificationClient.self] }
    set { self[UserNotificationClient.self] = newValue }
  }
}

extension UserNotificationClient: TestDependencyKey {
  public static let previewValue = Self.noop

#if os(iOS) || os(macOS) || os(watchOS)  || targetEnvironment(macCatalyst)
  public static let testValue = Self(
    add: XCTUnimplemented("\(Self.self).add"),
    deliveredNotifications: XCTUnimplemented("\(Self.self).deliveredNotifications", placeholder: []),
    notificationCategories: XCTUnimplemented("\(Self.self).notificationCategories", placeholder: []),
    notificationSettings: XCTUnimplemented("\(Self.self).notificationSettings"),
    pendingNotificationRequests: XCTUnimplemented("\(Self.self).pendingNotificationRequests"),
    removeAllDeliveredNotifications: XCTUnimplemented("\(Self.self).removeAllDeliveredNotifications"),
    removeAllPendingNotificationRequests: XCTUnimplemented("\(Self.self).removeAllPendingNotificationRequests"),
    removeDeliveredNotificationsWithIdentifiers: XCTUnimplemented("\(Self.self).removeDeliveredNotificationsWithIdentifiers"),
    removePendingNotificationRequestsWithIdentifiers: XCTUnimplemented("\(Self.self).removePendingNotificationRequestsWithIdentifiers"),
    requestAuthorization: XCTUnimplemented("\(Self.self).requestAuthorization"),
    setNotificationCategories: XCTUnimplemented("\(Self.self).setNotificationCategories"),
    supportsContentExtensions: XCTUnimplemented("\(Self.self).supportsContentExtensions"),
    delegate: XCTUnimplemented("\(Self.self).delegate", placeholder: .finished)
  )
#else // tvOS
  public static let testValue = Self(
    add: XCTUnimplemented("\(Self.self).add"),
    deliveredNotifications: XCTUnimplemented("\(Self.self).deliveredNotifications", placeholder: []),
    pendingNotificationRequests: XCTUnimplemented("\(Self.self).pendingNotificationRequests"),
    removeAllPendingNotificationRequests: XCTUnimplemented("\(Self.self).removeAllPendingNotificationRequests"),
    removePendingNotificationRequestsWithIdentifiers: XCTUnimplemented("\(Self.self).removePendingNotificationRequestsWithIdentifiers"),
    requestAuthorization: XCTUnimplemented("\(Self.self).requestAuthorization"),
    supportsContentExtensions: XCTUnimplemented("\(Self.self).supportsContentExtensions"),
    delegate: XCTUnimplemented("\(Self.self).delegate", placeholder: .finished)
  )
#endif
}

#if DEBUG
extension UserNotificationClient {
  public static let noop = Self(
    add: { _ in },
    deliveredNotifications: { [] },
    notificationCategories: { [] },
    notificationSettings: { Notification.Settings(rawValue: .init(coder: NSCoder())!) },
    pendingNotificationRequests: { [] },
    removeAllDeliveredNotifications: { },
    removeAllPendingNotificationRequests: { },
    removeDeliveredNotificationsWithIdentifiers: { _ in },
    removePendingNotificationRequestsWithIdentifiers: { _ in },
    requestAuthorization: { _ in false },
    setNotificationCategories: { _ in },
    supportsContentExtensions: { false },
    delegate: { AsyncStream { _ in } }
  )
}
#endif

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

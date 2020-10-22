import Foundation
import Combine

extension UserNotificationClient {
  static var mock: UserNotificationClient {
    Self(
      add: { _ in _unimplemented("add") },
      getAuthStatus: { _unimplemented("getAuthStatus") },
      getDeliveredNotifications: { _unimplemented("getDeliveredNotifications") },
      getNotificationSettings: { _unimplemented("getNotificationSettings") },
      getNotificationCategories: { _unimplemented("getNotificationCategories") },
      getPendingNotificationRequests: { _unimplemented("getPendingNotificationRequests") },
      removeAllDeliveredNotifications: { _unimplemented("removeAllDeliveredNotifications") },
      removeAllPendingNotificationRequests: { _unimplemented("removeAllPendingNotificationRequests") },
      removeDeliveredNotifications: { _ in _unimplemented("removeDeliveredNotifications") },
      removePendingNotificationRequests: { _ in _unimplemented("removePendingNotificationRequests") },
      requestAuthorization: { _ in _unimplemented("requestAuthorization") },
      setNotificationCategories: { _ in _unimplemented("setNotificationCategories") },
      supportsContentExtensions: { _unimplemented("supportsContentExtensions") },
      delegate: Empty().eraseToAnyPublisher()
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

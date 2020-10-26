import Foundation
import Combine

extension UserNotificationClient {
  static var mock: UserNotificationClient {
    Self()
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

import Foundation

public enum UserNotification: Equatable {
  case count(Int)
}

extension UserNotification {
  public init?(userInfo: [AnyHashable : Any]) {
    guard let count = userInfo["count"] as? Int else { return nil }
    self = .count(count)
  }
}

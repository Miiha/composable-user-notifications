//
//  BackgroundNotification.swift
//  Example
//
//  Created by Michael Kao on 31.10.20.
//

import Foundation
import UIKit

public struct BackgroundNotification {
  public let appState: UIApplication.State
  public let fetchCompletionHandler: (UIBackgroundFetchResult) -> Void
  public let content: Content?

  public init(
    appState: UIApplication.State,
    content: Content?,
    fetchCompletionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

    self.appState = appState
    self.content = content
    self.fetchCompletionHandler = fetchCompletionHandler
  }

  public enum Content: Equatable {
    case countAvailable
  }
}

extension BackgroundNotification: Equatable {
  public static func == (lhs: BackgroundNotification, rhs: BackgroundNotification) -> Bool {
    return lhs.appState == rhs.appState && lhs.content == rhs.content
  }
}

extension BackgroundNotification.Content {
  public init?(userInfo: [AnyHashable : Any]) {
    guard userInfo["countAvailable"] != nil else { return nil }
    self = .countAvailable
  }
}

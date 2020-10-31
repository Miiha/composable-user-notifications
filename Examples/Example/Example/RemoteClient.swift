//
//  RemoteClient.swift
//  Example
//
//  Created by Michael Kao on 31.10.20.
//

import Foundation
import ComposableArchitecture

struct RemoteClient {
  var fetchRemoteCount: () -> Effect<Int, Error>

  public struct Error: Swift.Error, Equatable {
    public init() {}
  }
}

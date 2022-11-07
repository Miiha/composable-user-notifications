import Foundation
import ComposableArchitecture
import XCTestDynamicOverlay

struct RemoteClient {
  var fetchRemoteCount: () async throws -> Int
}

extension DependencyValues {
  var remote: RemoteClient {
    get { self[RemoteClient.self] }
    set { self[RemoteClient.self] = newValue }
  }
}

extension RemoteClient: DependencyKey {
  static let liveValue = Self(
    fetchRemoteCount: { 1 }
  )
}

extension RemoteClient: TestDependencyKey {
  static let previewValue = Self(
    fetchRemoteCount: { 666 }
  )

  static let testValue = Self(
    fetchRemoteCount: unimplemented("\(Self.self).fetchRemoteCount")
  )
}


//
//  ExampleApp.swift
//  Example
//
//  Created by Michael Kao on 31.10.20.
//

import ComposableArchitecture
import SwiftUI
import UIKit
import Combine

private let store = Store(
  initialState: AppState(),
  reducer: appReducer,
  environment: AppEnvironment(
    remoteClient: .randomDelayed,
    userNotificationClient: .live
  )
)

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    let contentView = ContentView(store: store)
    self.window = (scene as? UIWindowScene).map(UIWindow.init(windowScene:))
    self.window?.rootViewController = UIHostingController(rootView: contentView)
    self.window?.makeKeyAndVisible()
  }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    ViewStore(store).send(.didFinishLaunching(notification: launchOptions?.notification))
    return true
  }

  func application(_ application: UIApplication,
                   didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                   fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

    let notification = BackgroundNotification(
      appState: application.applicationState,
      content: BackgroundNotification.Content(userInfo: userInfo),
      fetchCompletionHandler: completionHandler
    )
    ViewStore(store).send(.didReceiveBackgroundNotification(notification))
  }
}

extension RemoteClient {
  static let randomDelayed = RemoteClient(
    fetchRemoteCount: {
      Effect(value: Int.random(in: 0...10))
        .delay(for: 2, scheduler: DispatchQueue.main)
        .eraseToEffect()
    }
  )
}

private extension Dictionary where Key == UIApplication.LaunchOptionsKey, Value == Any {
  var notification: UserNotification? {
    self[.remoteNotification]
      .flatMap { $0 as? [AnyHashable: Any] }
      .flatMap(UserNotification.init)
  }
}

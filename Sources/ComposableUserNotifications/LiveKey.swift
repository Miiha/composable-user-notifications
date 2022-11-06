import Foundation
import ComposableArchitecture
import UserNotifications

extension UserNotificationClient: DependencyKey {
  public static var liveValue: Self {
    let center = UNUserNotificationCenter.current()

    var client = UserNotificationClient()
    client.add = { try await UNUserNotificationCenter.current().add($0) }

    #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
    client.deliveredNotifications = {
      let notifications = await center.deliveredNotifications()
      return notifications.map(Notification.init(rawValue:))
    }
    #endif

    client.notificationSettings = {
      let settings = await center.notificationSettings()
      return Notification.Settings(rawValue: settings)
    }

    #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
    client.notificationCategories = {
      await center.notificationCategories()
    }
    #endif

    client.pendingNotificationRequests = {
      let requests = await center.pendingNotificationRequests()
      return requests.map(Notification.Request.init(rawValue:))
    }

    #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
    client.removeAllDeliveredNotifications = {
      center.removeAllDeliveredNotifications()
    }
    #endif

    client.removeAllPendingNotificationRequests = {
      center.removeAllPendingNotificationRequests()
    }

    #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
    client.removeDeliveredNotificationsWithIdentifiers = { identifiers in
      center.removeDeliveredNotifications(withIdentifiers: identifiers)
    }
    #endif

    client.removePendingNotificationRequestsWithIdentifiers = { identifiers in
      center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    client.requestAuthorization = { options in
      try await center.requestAuthorization(options: options)
    }

    #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
    client.setNotificationCategories = { categories in
      center.setNotificationCategories(categories)
    }
    #endif

    client.supportsContentExtensions = {
      center.supportsContentExtensions
    }

    client.delegate = {
      AsyncStream { continuation in
        let delegate = Delegate(continuation: continuation)
        UNUserNotificationCenter.current().delegate = delegate
        continuation.onTermination = { [delegate] _ in }
      }
    }
    
    return client
  }
}

private extension UserNotificationClient {
  class Delegate: NSObject, UNUserNotificationCenterDelegate {
    let continuation: AsyncStream<UserNotificationClient.DeletegateAction>.Continuation

    init(continuation: AsyncStream<UserNotificationClient.DeletegateAction>.Continuation) {
      self.continuation = continuation
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

      self.continuation.yield(
        .willPresentNotification(
          Notification(rawValue: notification),
          completionHandler: completionHandler
        )
      )
    }

    #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

      let wrappedResponse = Notification.Response(rawValue: response)
      self.continuation.yield(
        .didReceiveResponse(wrappedResponse) { completionHandler() }
      )
    }
    #endif

    #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                openSettingsFor notification: UNNotification?) {


      let mappedNotification = notification.map(Notification.init)
      self.continuation.yield(
        .openSettingsForNotification(mappedNotification)
      )
    }
    #endif
  }
}

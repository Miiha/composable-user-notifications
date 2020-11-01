import Foundation
import Combine
import ComposableArchitecture
import UserNotifications

extension UserNotificationClient {
  public static var live: UserNotificationClient {
    let center = UNUserNotificationCenter.current()

    var client = UserNotificationClient()
    client.add = { request in
      .future { callback in
        center.add(request) { error in
          if let error = error {
            callback(.failure(Error(error)))
          } else {
            callback(.success(()))
          }
        }
      }
    }

    #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
    client.getDeliveredNotifications = {
      .future { callback in
        center.getDeliveredNotifications { notifications in
          callback(.success(notifications.map(Notification.init(rawValue:))))
        }
      }
    }
    #endif

    client.getNotificationSettings = {
      Effect.future { callback in
        center.getNotificationSettings { settings in
          callback(.success(Notification.Settings(rawValue: settings)))
        }
      }.eraseToEffect()
    }

    #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
    client.getNotificationCategories = {
      Effect.future { callback in
        center.getNotificationCategories { categories in
          callback(.success(categories))
        }
      }
    }
    #endif

    client.getPendingNotificationRequests = {
      Effect.future { callback in
        center.getPendingNotificationRequests { requests in
          callback(.success(requests.map(Notification.Request.init(rawValue:))))
        }
      }
    }

    #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
    client.removeAllDeliveredNotifications = {
      .fireAndForget {
        center.removeAllDeliveredNotifications()
      }
    }
    #endif

    client.removeAllPendingNotificationRequests = {
      .fireAndForget {
        center.removeAllPendingNotificationRequests()
      }
    }

    #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
    client.removeDeliveredNotificationsWithIdentifiers = { identifiers in
      .fireAndForget {
        center.removeDeliveredNotifications(withIdentifiers: identifiers)
      }
    }
    #endif

    client.removePendingNotificationRequestsWithIdentifiers = { identifiers in
      .fireAndForget {
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
      }
    }

    client.requestAuthorization = { options in
      .future { callback in
        center.requestAuthorization(options: options) { (granted, error) in
          if let error = error {
            callback(.failure(Error(error)))
          } else {
            callback(.success(granted))
          }
        }
      }
    }

    #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
    client.setNotificationCategories = { categories in
      .fireAndForget {
        center.setNotificationCategories(categories)
      }
    }
    #endif

    client.supportsContentExtensions = {
      center.supportsContentExtensions
    }

    client.delegate = {
      Effect.run { subscriber in
        var delegate: Optional = Delegate(subscriber: subscriber)
        UNUserNotificationCenter.current().delegate = delegate
        return AnyCancellable {
          delegate = nil
        }
      }
      .share()
      .eraseToEffect()
    }
    
    return client
  }
}

private extension UserNotificationClient {
  class Delegate: NSObject, UNUserNotificationCenterDelegate {
    let subscriber: Effect<UserNotificationClient.Action, Never>.Subscriber

    init(subscriber: Effect<UserNotificationClient.Action, Never>.Subscriber) {
      self.subscriber = subscriber
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

      subscriber.send(
        .willPresentNotification(
          Notification(rawValue: notification),
          completion: completionHandler)
      )
    }

    #if os(iOS) || os(macOS) ||  os(watchOS) || targetEnvironment(macCatalyst)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

      let mappedResponse: Notification.Response = {
        switch response {
        case let response as UNTextInputNotificationResponse:
          return .textInput(Notification.Response.TextInputAction(rawValue: response))
        default:
          return .user(Notification.Response.UserAction(rawValue: response))
        }
      }()
      subscriber.send(.didReceiveResponse(mappedResponse, completion: completionHandler))
    }
    #endif

    #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                openSettingsFor notification: UNNotification?) {


      let mappedNotification = notification.map(Notification.init)
      subscriber.send(.openSettingsForNotification(mappedNotification))
    }
    #endif
  }
}

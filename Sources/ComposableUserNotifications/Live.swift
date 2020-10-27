import Foundation
import Combine
import ComposableArchitecture
import UserNotifications

extension UserNotificationClient {
  public static var live: UserNotificationClient {
    let center = UNUserNotificationCenter.current()
    let subject = PassthroughSubject<Action, Never>()
    var delegate: UserNotificationCenterDelegate? = UserNotificationCenterDelegate(subject)
    center.delegate = delegate

    var client = UserNotificationClient()
    client.add = { request in
      Future { promise in
        center.add(request) { error in
          if let error = error {
            promise(.failure(error))
          } else {
            promise(.success(()))
          }
        }
      }.eraseToEffect()
    }

    client.getAuthStatus = {
      Future { promise in
        center.getNotificationSettings { settings in
          promise(.success(settings.authorizationStatus))
        }
      }.eraseToEffect()
    }

    #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
    client.getDeliveredNotifications = {
      Future { callback in
        center.getDeliveredNotifications { notifications in
          callback(.success(notifications.map(Notification.init(rawValue:))))
        }
      }.eraseToEffect()
    }
    #endif

    client.getNotificationSettings = {
      Future { callback in
        center.getNotificationSettings { settings in
          callback(.success(NotificationSettings(rawValue: settings)))
        }
      }.eraseToEffect()
    }

    #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
    client.getNotificationCategories = {
      Future { callback in
        center.getNotificationCategories { categories in
          callback(.success(categories))
        }
      }.eraseToEffect()
    }
    #endif

    client.getPendingNotificationRequests = {
      Future { callback in
        center.getPendingNotificationRequests { requests in
          callback(.success(requests.map(NotificationRequest.init(rawValue:))))
        }
      }.eraseToEffect()
    }

    #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
    client.removeAllDeliveredNotifications = {
      center.removeAllDeliveredNotifications()
    }
    #endif

    client.removeAllPendingNotificationRequests = {
      center.removeAllPendingNotificationRequests()
    }

    #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
    client.removeDeliveredNotifications = {
      center.removeDeliveredNotifications(withIdentifiers: $0)
    }
    #endif

    client.removePendingNotificationRequests = {
      center.removePendingNotificationRequests(withIdentifiers: $0)
    }

    client.requestAuthorization = { options in
      Future { callback in
        center.requestAuthorization(options: options) { (granted, error) in
          if let error = error {
            callback(.failure(error as NSError))
          } else {
            callback(.success(granted))
          }
        }
      }.eraseToEffect()
    }

    #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
    client.setNotificationCategories = {
      center.setNotificationCategories($0)
    }
    #endif

    client.supportsContentExtensions = {
      center.supportsContentExtensions
    }

    client.delegate = {
      subject
        .handleEvents(receiveCancel: { delegate = nil })
        .eraseToEffect()
    }
    
    return client
  }
}

final class UserNotificationCenterDelegate: NSObject, UNUserNotificationCenterDelegate {
  let subject: PassthroughSubject<UserNotificationClient.Action, Never>

  init(_ subject: PassthroughSubject<UserNotificationClient.Action, Never>) {
    self.subject = subject
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

    subject.send(
      .willPresentNotification(
        Notification(rawValue: notification),
        completion: completionHandler)
    )
  }

  #if os(iOS) || os(macOS) ||  os(watchOS) || targetEnvironment(macCatalyst)
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {

    let mappedResponse: NotificationResponseType = {
      switch response {
      case let response as UNTextInputNotificationResponse:
        return TextInputNotificationResponse(rawValue: response)
      default:
        return NotificationResponse(rawValue: response)
      }
    }()
    subject.send(.didReceiveResponse(mappedResponse, completion: completionHandler))
  }
  #endif

  #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              openSettingsFor notification: UNNotification?) {


    let mappedNotification = notification.map(Notification.init)
    subject.send(.openSettingsForNotification(mappedNotification))
  }
  #endif
}

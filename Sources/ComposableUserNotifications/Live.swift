import Foundation
import UserNotifications
import Combine

extension UserNotificationClient {
  public static var live: UserNotificationClient {
    final class Delegate: NSObject, UNUserNotificationCenterDelegate {
      let subject: PassthroughSubject<DelegateEvent, Never>

      init(subject: PassthroughSubject<DelegateEvent, Never>) {
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

      func userNotificationCenter(_ center: UNUserNotificationCenter,
                                  openSettingsFor notification: UNNotification?) {


        let mappedNotification = notification.map(Notification.init)
        subject.send(.openSettingsForNotification(mappedNotification))
      }
    }

    let center = UNUserNotificationCenter.current()
    let subject = PassthroughSubject<DelegateEvent, Never>()
    var delegate: Delegate? = Delegate(subject: subject)
    center.delegate = delegate

    return Self(
      add: { request in
        Future { promise in
          center.add(request) { error in
            if let error = error {
              promise(.failure(error))
            } else {
              promise(.success(()))
            }
          }
        }.eraseToAnyPublisher()
      },
      getAuthStatus: {
        Future { promise in
          center.getNotificationSettings { settings in
            promise(.success(settings.authorizationStatus))
          }
        }.eraseToAnyPublisher()
      },
      getDeliveredNotifications: {
        Future { callback in
          center.getDeliveredNotifications { notifications in
            callback(.success(notifications.map(Notification.init(rawValue:))))
          }
        }.eraseToAnyPublisher()
      },
      getNotificationSettings: {
        Future { callback in
          center.getNotificationSettings { settings in
            callback(.success(NotificationSettings(rawValue: settings)))
          }
        }.eraseToAnyPublisher()
      },
      getNotificationCategories: {
        Future { callback in
          center.getNotificationCategories { categories in
            callback(.success(categories))
          }
        }.eraseToAnyPublisher()
      },
      getPendingNotificationRequests: {
        Future { callback in
          center.getPendingNotificationRequests { requests in
            callback(.success(requests.map(NotificationRequest.init(rawValue:))))
          }
        }.eraseToAnyPublisher()
      },
      removeAllDeliveredNotifications: {
        center.removeAllDeliveredNotifications()
      },
      removeAllPendingNotificationRequests: {
        center.removeAllPendingNotificationRequests()
      },
      removeDeliveredNotifications: {
        center.removeDeliveredNotifications(withIdentifiers: $0)
      },
      removePendingNotificationRequests: {
        center.removePendingNotificationRequests(withIdentifiers: $0)
      },
      requestAuthorization: { options in
        Future { callback in
          center.requestAuthorization(options: options) { (granted, error) in
            if let error = error {
              callback(.failure(error as NSError))
            } else {
              callback(.success(granted))
            }
          }
        }.eraseToAnyPublisher()
      },
      setNotificationCategories: {
        center.setNotificationCategories($0)
      },
      supportsContentExtensions: {
        center.supportsContentExtensions
      },
      delegate: subject
        .handleEvents(receiveCancel: { delegate = nil })
        .eraseToAnyPublisher()
    )
  }
}

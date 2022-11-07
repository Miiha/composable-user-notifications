# Composable User Notifications

Composable User Notifications is library that bridges [the Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) and [User Notifications](https://developer.apple.com/documentation/usernotifications).

This library is modelling it's dependency using [swift concurrency](https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/swiftconcurrency) since version 0.3.0.

* [Example](#example)
* [Basic usage](#basic-usage)
* [Installation](#installation)

## Example
Check out the Example demo to see how [ComposableUserNotifications](./Examples/Example) can be used.

## Basic usage
To handle incoming user notification you can observe the `UNUserNotificationCenterDelegate` actions through `UserNotificationClient.DelegateAction` of the `UserNotificationClient.delegate`.

```swift
import ComposableUserNotifications

struct App: ReducerProtocol {
  enum Action {
  case userNotification(UserNotificationClient.DelegateAction)
  // Your domain's other actions:
...
```

The `UserNotificationClient.DelegateAction` holds the actions
* for handling foreground notifications `willPresentNotification(_:completion)`
* to process the user's response to a delivered notification `didReceiveResponse(_:completionHandler:)`
* to display the in-app notification settings `openSettingsForNotification(_:)`

The wrapper around apple's `UNUserNotificationCenter` `UserNotificationClient`, is available on the `DependencyValues` and can be retrieved on using `@Dependency(\.userNotifications)`.

At some point you need to subscribe to `UserNotificationClient.DelegateAction` in order not to miss any `UNUserNotificationCenterDelegate` related actions. This can be done early after starting the application.

```swift
func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
  switch action {
  case let .didFinishLaunching(notification):
    ...
    return .run { send in
        for await event in self.userNotifications.delegate() {
          await send(.userNotifications(event))
        }
      }
    }
  }
}
```

When subscribing to these actions we can handle them as follows.

```swift
...
  case let .userNotification(.willPresentNotification(notification, completion)):
    return .fireAndForget {
      completion([.list, .banner, .sound])
    }

  case let .userNotification(.didReceiveResponse(response, completion)):
    return .fireAndForget {
      completion()
    }

  case .userNotification(.openSettingsForNotification):
    return .none
...
```

To request authorization from the user you can use `requestAuthorization` and handle the users choice as a new action.

```swift
func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
  switch action {
  case .didFinishLaunching:
    return .task {
      .requestAuthorizationResponse(
        TaskResult {
          try await self.userNotifications.requestAuthorization([.alert, .badge, .sound])
        }
      )
    }
  }
  ...
}
```

Adding notification requests is also straight forward. It can be done using `UNNotificationRequest` in conjunction with `UserNotificationClient.add(_:)`.

```swift
  case .tappedScheduleButton:
    let content = UNMutableNotificationContent()
    content.title = "Example title"
    content.body = "Example body"

    let request = UNNotificationRequest(
      identifier: "example_notification",
      content: content,
      trigger: UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
    )

    return .task {
      await self.userNotifications
        .removePendingNotificationRequestsWithIdentifiers(["example_notification"])
      return await .addNotificationResponse(
        TaskResult {
          Unit(try await self.userNotifications.add(request))
        }
      )
    }
  ...
```
All API calls to `UNUserNotificationCenter` are available through `UserNotificationClient`. 
The true power of this approach lies in the testability of your notification logic.
For more info around testability have a look at [ExampleTests.swift](./Examples/Example/ExampleTests/ExampleTests.swift).

## Installation

You can add ComposableUserNotifications to an Xcode project by adding it as a package dependency.

  1. From the **File** menu, select **Swift Packages › Add Package Dependency…**
  2. Enter "https://github.com/miiha/composable-user-notifications" into the package repository URL text field

## License

This library is released under the MIT license. See [LICENSE](LICENSE) for details.

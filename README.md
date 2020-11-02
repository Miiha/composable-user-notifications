# Composable User Notifications

Composable User Notifications is library that bridges [the Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) and [User Notifications](https://developer.apple.com/documentation/usernotifications).

* [Example](#example)
* [Basic usage](#basic-usage)
* [Installation](#installation)

## Example
Check out the Example demo to see how [ComposableUserNotifications](./Examples/Example) can be used.

## Basic usage
To hanlde incomming user notification you can observe the `UNUserNotificationCenterDelegate` actions `UserNotificationClient.Action` of the `UserNotificationClient.delegate` effect.

```swift
import ComposableUserNotifications

enum AppAction {
  case userNotification(UserNotificationClient.Action)

  // Your domain's other actions:
  ...
}
```
The `UserNotificationClient.Action` holds the actions
* for handling foreground notifications `willPresentNotification(_:completion)`
* too process the user's response to a delivered notification `didReceiveResponse(_:completion:)`
* to display the in-app notification settings `openSettingsForNotification(_:)`

The wrapper around apple's `UNUserNotificationCenter` `UserNotificationClient`, should be part of your applications environment.
```swift
struct AppEnvironment {
  var userNotificationClient: UserNotificationClient

  // Your domain's other dependencies:
  ...
}
```

At some point you need to subscribe to `UserNotificationClient.Action` in order not to miss any `UNUserNotificationCenterDelegate` related actions. This can be done early after starting the application.

```swift
let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
  switch action {
  case .didFinishLaunching: // or onAppear of your first View
    return environment.userNotificationClient
      .delegate()
      .map(AppAction.userNotification)
```
When subscribing to these actions we can handle them as follows.

```swift
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
```

To request authorization from the user you can use `requestAuthorization` and handle the users choice as a new action.

```swift
let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
  switch action {
  case .didFinishLaunching:
    return .merge(
      ...,
      environment.userNotificationClient.requestAuthorization([.alert, .badge, .sound])
        .catchToEffect()
        .map(AppAction.requestAuthorizationResponse)
      )
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

    return .concatenate(
      environment.userNotificationClient.removePendingNotificationRequestsWithIdentifiers(["example_notification"])
        .map(absurd),
      environment.userNotificationClient.add(request)
        .map(Unit.init)
        .catchToEffect()
        .map(AppAction.addNotificationResponse)
    )
```
There are of course a lot more wrapped API calls to `UNUserNotificationCenter` available. 
The true power of this approach again lies in the testability of your notification logic.
For more info around testability have a look at [ExampleTests.swift](./Examples/Example/ExampleTests/ExampleTests.swift).

## Installation

You can add ComposableUserNotifications to an Xcode project by adding it as a package dependency.

  1. From the **File** menu, select **Swift Packages › Add Package Dependency…**
  2. Enter "https://github.com/miiha/composable-user-notifications" into the package repository URL text field

## License

This library is released under the MIT license. See [LICENSE](LICENSE) for details.

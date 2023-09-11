import ComposableArchitecture
import ComposableUserNotifications
import SwiftUI

struct ContentView: View {
  let store: StoreOf<App>

  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      VStack {
        Text("Count: \(viewStore.count ?? 0)")
          .padding()
        Button("Schedule notification") {
          viewStore.send(.tappedScheduleButton)
        }
      }
    }
  }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(
      store: Store(
        initialState: App.State(),
        reducer: { App() }
      )
    )
  }
}
#endif

import SwiftUI

public struct RootView: View {
    @StateObject private var state = AppState()

    public init() {}

    public var body: some View {
        NavigationStack {
            Form {
                Section("Create account") {
                    TextField("Username", text: $state.usernameInput)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    TextField("Phone number (optional)", text: $state.phoneInput)
                        .keyboardType(.phonePad)
                }

                Section("Actions") {
                    Button("Register (stub)") {
                        state.registerStub()
                    }
                    Button("Open room list (stub)") {
                        state.openRoomListStub()
                    }
                }

                Section("Status") {
                    Text(state.lastStatus)
                        .font(.footnote)
                }
            }
            .navigationTitle("ShadowChat")
        }
    }
}

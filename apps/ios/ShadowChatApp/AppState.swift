import Foundation

@MainActor
final class AppState: ObservableObject {
    @Published var usernameInput: String = ""
    @Published var phoneInput: String = ""
    @Published var lastStatus: String = "Signed out"

    private let secureStorage: SessionSecureStorage
    private let logger: RedactedLogger
    private let authGateway: RustAuthGateway

    init(
        secureStorage: SessionSecureStorage = KeychainSessionSecureStorage(),
        logger: RedactedLogger = RedactedLogger(),
        authGateway: RustAuthGateway = RustAuthGateway()
    ) {
        self.secureStorage = secureStorage
        self.logger = logger
        self.authGateway = authGateway
    }

    func registerStub() {
        let response = authGateway.registerStub(usernameInput: usernameInput, phoneNumber: phoneInput.isEmpty ? nil : phoneInput)
        switch response {
        case .success(let userID):
            lastStatus = "Signed in as \(userID)"
            let token = "session-\(UUID().uuidString)"
            _ = secureStorage.storeSessionSecret(token)
            logger.info("Auth success user=\(logger.redactUsername(usernameInput))")
        case .failure(let error):
            lastStatus = error.message
            logger.warning("Auth failed code=\(error.code.rawValue) username=\(logger.redactUsername(usernameInput))")
        }
    }

    func openRoomListStub() {
        let state = authGateway.roomListEntryPoint(sessionState: .signedIn)
        lastStatus = state.state
    }
}

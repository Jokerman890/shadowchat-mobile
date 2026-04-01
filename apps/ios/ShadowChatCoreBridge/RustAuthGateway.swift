import Foundation

struct CoreError: Error {
    enum Code: String {
        case invalidUsername = "INVALID_USERNAME"
        case usernameTaken = "USERNAME_TAKEN"
        case networkUnavailable = "NETWORK_UNAVAILABLE"
        case authFailed = "AUTH_FAILED"
        case internalError = "INTERNAL_ERROR"
    }

    let code: Code
    let message: String
}

enum SessionState {
    case signedOut
    case restoring
    case signedIn
}

struct RoomListEntryPoint {
    let sessionReady: Bool
    let state: String
}

struct RustAuthGateway {
    private let reserved = Set(["admin", "administrator", "support", "security", "system", "root", "null", "undefined"])
    private let taken = Set(["takenuser", "support"])

    func registerStub(usernameInput: String, phoneNumber: String?) -> Result<String, CoreError> {
        _ = phoneNumber
        switch validateAndNormalize(usernameInput) {
        case .success(let canonical):
            if taken.contains(canonical) {
                return .failure(CoreError(code: .usernameTaken, message: "Username is not available"))
            }
            return .success("@\(canonical):example.shadowchat")
        case .failure(let error):
            return .failure(error)
        }
    }

    func roomListEntryPoint(sessionState: SessionState) -> RoomListEntryPoint {
        RoomListEntryPoint(sessionReady: sessionState == .signedIn, state: "room-list-stub")
    }

    private func validateAndNormalize(_ raw: String) -> Result<String, CoreError> {
        let canonical = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard canonical.count >= 3, canonical.count <= 32 else {
            return .failure(CoreError(code: .invalidUsername, message: "Username length is invalid"))
        }
        let regex = try! NSRegularExpression(pattern: "^[a-z0-9](?:[a-z0-9]|[._-](?=[a-z0-9])){1,30}[a-z0-9]$")
        let range = NSRange(location: 0, length: canonical.utf16.count)
        guard regex.firstMatch(in: canonical, range: range) != nil else {
            return .failure(CoreError(code: .invalidUsername, message: "Username format is invalid"))
        }
        guard !reserved.contains(canonical) else {
            return .failure(CoreError(code: .invalidUsername, message: "Username is reserved"))
        }
        return .success(canonical)
    }
}

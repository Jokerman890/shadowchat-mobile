import Foundation
import Security

protocol SessionSecureStorage {
    @discardableResult
    func storeSessionSecret(_ secret: String) -> Bool
}

struct KeychainSessionSecureStorage: SessionSecureStorage {
    private let account = "shadowchat.session.secret"
    private let service = "com.shadowchat.mobile"

    func storeSessionSecret(_ secret: String) -> Bool {
        guard let data = secret.data(using: .utf8) else { return false }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]

        SecItemDelete(query as CFDictionary)

        var insertQuery = query
        insertQuery[kSecValueData as String] = data
        insertQuery[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly

        return SecItemAdd(insertQuery as CFDictionary, nil) == errSecSuccess
    }
}

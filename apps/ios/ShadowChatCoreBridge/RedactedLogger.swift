import Foundation

struct RedactedLogger {
    func redactUsername(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count > 2 else { return "[redacted]" }
        return "\(trimmed.prefix(2))***"
    }

    func redactPhone(_ value: String?) -> String {
        guard let value, !value.isEmpty else { return "[none]" }
        return "***\(value.suffix(2))"
    }

    func redactToken(_ value: String) -> String {
        return "tok_***\(value.suffix(4))"
    }

    func info(_ message: String) {
        #if DEBUG
        NSLog("[ShadowChat][INFO] %@", message)
        #endif
    }

    func warning(_ message: String) {
        #if DEBUG
        NSLog("[ShadowChat][WARN] %@", message)
        #endif
    }
}

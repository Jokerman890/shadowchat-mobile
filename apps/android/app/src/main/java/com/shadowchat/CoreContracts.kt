package com.shadowchat

enum class ErrorCode {
    INVALID_USERNAME,
    USERNAME_TAKEN,
    NETWORK_UNAVAILABLE,
    AUTH_FAILED,
    INTERNAL_ERROR,
}

data class CoreError(val code: ErrorCode, override val message: String) : Exception(message)

enum class SessionState {
    SIGNED_OUT,
    RESTORING,
    SIGNED_IN,
}

data class RoomListEntryPoint(val sessionReady: Boolean, val state: String)

class RustAuthGateway {
    private val reserved = setOf("admin", "administrator", "support", "security", "system", "root", "null", "undefined")
    private val taken = setOf("takenuser", "support")

    fun registerStub(usernameInput: String, phoneNumber: String?): Result<String> {
        phoneNumber?.let { RedactedLogger.info("Phone provided=${RedactedLogger.redactPhone(it)}") }

        val canonical = validateAndNormalize(usernameInput)
            .getOrElse { return Result.failure(it) }

        if (taken.contains(canonical)) {
            return Result.failure(CoreError(ErrorCode.USERNAME_TAKEN, "Username is not available"))
        }

        return Result.success("@$canonical:example.shadowchat")
    }

    fun roomListEntryPoint(sessionState: SessionState): RoomListEntryPoint {
        return RoomListEntryPoint(sessionReady = sessionState == SessionState.SIGNED_IN, state = "room-list-stub")
    }

    private fun validateAndNormalize(raw: String): Result<String> {
        val canonical = raw.trim().lowercase()
        if (canonical.length !in 3..32) {
            return Result.failure(CoreError(ErrorCode.INVALID_USERNAME, "Username length is invalid"))
        }
        if (!Regex("^[a-z0-9](?:[a-z0-9]|[._-](?=[a-z0-9])){1,30}[a-z0-9]$").matches(canonical)) {
            return Result.failure(CoreError(ErrorCode.INVALID_USERNAME, "Username format is invalid"))
        }
        if (reserved.contains(canonical)) {
            return Result.failure(CoreError(ErrorCode.INVALID_USERNAME, "Username is reserved"))
        }
        return Result.success(canonical)
    }
}

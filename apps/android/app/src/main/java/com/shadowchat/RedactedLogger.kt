package com.shadowchat

import android.util.Log

object RedactedLogger {
    private const val TAG = "ShadowChat"

    fun redactUsername(value: String): String {
        val trimmed = value.trim()
        return if (trimmed.length > 2) "${trimmed.take(2)}***" else "[redacted]"
    }

    fun redactPhone(value: String): String {
        return "***${value.takeLast(2)}"
    }

    fun redactToken(value: String): String {
        return "tok_***${value.takeLast(4)}"
    }

    fun info(message: String) {
        Log.i(TAG, message)
    }

    fun warn(message: String) {
        Log.w(TAG, message)
    }
}

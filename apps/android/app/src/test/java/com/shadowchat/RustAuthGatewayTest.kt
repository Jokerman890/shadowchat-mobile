package com.shadowchat

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class RustAuthGatewayTest {
    @Test
    fun canonicalizesUsername() {
        val result = RustAuthGateway().registerStub("  Alice_01 ", null)
        assertTrue(result.isSuccess)
        assertEquals("@alice_01:example.shadowchat", result.getOrNull())
    }
}

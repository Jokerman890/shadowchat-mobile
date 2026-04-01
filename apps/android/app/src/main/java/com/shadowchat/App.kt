package com.shadowchat

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

@Composable
fun ShadowChatApp() {
    val username = remember { mutableStateOf("") }
    val phone = remember { mutableStateOf("") }
    val status = remember { mutableStateOf("Signed out") }

    Column(modifier = Modifier.fillMaxSize().padding(16.dp)) {
        Text("ShadowChat", style = MaterialTheme.typography.headlineSmall)
        OutlinedTextField(value = username.value, onValueChange = { username.value = it }, label = { Text("Username") })
        OutlinedTextField(value = phone.value, onValueChange = { phone.value = it }, label = { Text("Phone number (optional)") })

        Button(onClick = {
            val gateway = RustAuthGateway()
            val result = gateway.registerStub(username.value, phone.value.ifBlank { null })
            status.value = result.fold(onSuccess = {
                KeystoreSessionSecureStorage().storeSessionSecret("session-$it")
                RedactedLogger.info("Auth success user=${RedactedLogger.redactUsername(username.value)}")
                "Signed in as $it"
            }, onFailure = {
                RedactedLogger.warn("Auth failed user=${RedactedLogger.redactUsername(username.value)} code=${it.code}")
                it.message
            })
        }, modifier = Modifier.padding(top = 12.dp)) {
            Text("Register (stub)")
        }

        Button(onClick = {
            status.value = RustAuthGateway().roomListEntryPoint(SessionState.SIGNED_IN).state
        }, modifier = Modifier.padding(top = 8.dp)) {
            Text("Open room list (stub)")
        }

        Text(status.value, modifier = Modifier.padding(top = 12.dp))
    }
}

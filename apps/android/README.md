# Android App

This directory is reserved for the native Android application.

Target stack:
- Kotlin
- Jetpack Compose
- Coroutines and Flow
- Android Keystore for secure storage integration
- BiometricPrompt for local protection flows
- FCM for mainstream push delivery
- potential UnifiedPush support later for privacy-oriented distribution

Expected future contents:
- Gradle settings and modules
- app module
- tests
- platform-specific resources and configuration

Validation goals for future work:
- Gradle sync succeeds
- assembleDebug succeeds
- lint and tests run for affected modules

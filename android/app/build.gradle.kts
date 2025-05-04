plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.timestandby"
    compileSdk = 35 // Update to SDK 35
    ndkVersion = "27.0.12077973" // Ensure the correct NDK version

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.timestandby"
        minSdk = 21
        targetSdk = 35 // Update to SDK 35
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = true // Enable code shrinking
            postprocessing {
                isRemoveUnusedCode = true
                isRemoveUnusedResources = true // Enable resource shrinking
                proguardFiles(
                    getDefaultProguardFile("proguard-android-optimize.txt"),
                    "proguard-rules.pro"
                )
            }
        }
        debug {
            isMinifyEnabled = false // Keep debug builds simple
        }
    }
}

flutter {
    source = "../.."
}

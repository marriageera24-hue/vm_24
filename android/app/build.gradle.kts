plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Add the dependency for the Google services Gradle plugin
   id("com.google.gms.google-services")

}

android {
    namespace = "com.example.vadar_marriage_era"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Use the assignment operator for boolean properties
        isCoreLibraryDesugaringEnabled  = true
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
         jvmTarget = "1.8"
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.vadar_marriage_era"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Obtains the signing configuration from the 'debug' variant.
            // This is safe for local release builds, but you should use
            // a real release key for the Play Store.
            signingConfig = signingConfigs.getByName("debug")
            
            // Enables code and resource shrinking.
            isMinifyEnabled = true
            
            // Specifies the ProGuard rules.
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
  // Import the Firebase BoM
  implementation(platform("com.google.firebase:firebase-bom:34.4.0"))
  
  // TODO: Add the dependencies for Firebase products you want to use
  // When using the BoM, don't specify versions in Firebase dependencies
  implementation("com.google.firebase:firebase-analytics")

  // Use double quotes for dependency strings
  coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
  implementation("androidx.window:window:1.0.0")
  implementation("androidx.window:window-java:1.0.0")

}

flutter {
    source = "../.."
}

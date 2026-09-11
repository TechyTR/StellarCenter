plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "org.test.thislinux"

    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "org.test.thislinux"

        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val keystorePath = System.getenv("STELLAR_KEYSTORE_PATH")
            val keystorePassword =
                System.getenv("STELLAR_KEYSTORE_PASSWORD")
            val keyAlias =
                System.getenv("STELLAR_KEY_ALIAS")
            val keyPassword =
                System.getenv("STELLAR_KEY_PASSWORD")

            if (
                keystorePath != null &&
                keystorePassword != null &&
                keyAlias != null &&
                keyPassword != null
            ) {
                storeFile = file(keystorePath)
                storePassword = keystorePassword
                this.keyAlias = keyAlias
                this.keyPassword = keyPassword
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

dependencies {
    implementation(
        platform("com.google.firebase:firebase-bom:34.19.0")
    )

    implementation(
        "com.google.firebase:firebase-auth"
    )
}

flutter {
    source = "../.."
}

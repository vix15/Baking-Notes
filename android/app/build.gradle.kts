plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.univalle.baking_notes"
    compileSdk = flutter.compileSdkVersion.toInt()
    ndkVersion = "27.0.12077973"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
    applicationId = "com.univalle.baking_notes"
    minSdk = flutter.minSdkVersion.toInt()
    targetSdk = flutter.targetSdkVersion.toInt()
    versionCode = 4 // ← Número de versión incrementado
    versionName = "1.0.3" // ← Nueva versión opcional
    }


    signingConfigs {
    create("release") {
        storeFile = file("baking_notes_keystore.jks")  // Ruta relativa desde android/app/
        storePassword = "bakingnotes1532"  // ¡Ahora en una línea separada!
        keyAlias = "bakingnotes"
        keyPassword = "bakingnotes1532"
    }
}

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        getByName("debug") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.9.22")
}
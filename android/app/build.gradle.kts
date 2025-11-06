// android/app/build.gradle.kts (ESTE ARQUIVO ESTÁ DENTRO DA PASTA 'app')

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    
    // LINHA CRUCIAL FALTANDO: APLICA o plugin do Google Services ao seu app.
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.api_petvida"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" 

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.api_petvida"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// ** ATENÇÃO: Se você usa outras bibliotecas do Firebase, o bloco `dependencies` 
// geralmente fica aqui, mas a importação do BoM não é mais necessária no `build.gradle.kts` **
// Se precisar de dependências, elas vão no arquivo `pubspec.yaml` do Flutter.
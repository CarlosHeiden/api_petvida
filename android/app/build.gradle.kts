// ===================================
// 📄 ARQUIVO: android/app/build.gradle
// ===================================

plugins {
    id 'com.android.application'
    id 'kotlin-android'
    id 'com.google.gms.google-services' // ✅ Necessário para Firebase
}

android {
    namespace "com.example.api_petvida" // 🔧 ajuste se for diferente no AndroidManifest.xml
    compileSdk 34

    defaultConfig {
        applicationId "com.example.api_petvida"
        minSdk 23
        targetSdk 34
        versionCode 1
        versionName "1.0"

        // Necessário para Firebase e notificações
        multiDexEnabled true
    }

    // ✅ Compilação com Java 17 (necessário para Gradle 8+)
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
        coreLibraryDesugaringEnabled true // ✅ necessário para flutter_local_notifications
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildFeatures {
        viewBinding true
    }
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk8"
    implementation 'androidx.multidex:multidex:2.0.1'

    // ✅ Adiciona suporte a APIs modernas no Android (requerido por flutter_local_notifications)
    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.4'
}
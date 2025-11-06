// android/build.gradle.kts (ESTE É O ARQUIVO DE NÍVEL DE PROJETO/RAIZ)

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Configuração para diretório de build (Mantendo sua lógica customizada)
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// CORREÇÃO: Alinhando a versão do AGP (Android Gradle Plugin) para 8.7.3
// Esta versão resolve o conflito que o seu ambiente encontrou.
plugins {
    // Usando 8.7.3 para resolver o conflito
    id("com.android.application") version "8.7.3" apply false 
    
    // Mantendo a versão do Kotlin
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false 
    
    // Plugin do Firebase (com versão declarada)
    id("com.google.gms.google-services") version "4.4.1" apply false 
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
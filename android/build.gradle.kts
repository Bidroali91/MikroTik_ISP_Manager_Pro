buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.4.2")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    project.plugins.withId("com.android.library") {
        project.afterEvaluate {
            try {
                val android = project.extensions.getByName("android")
                val compileSdkField = android.javaClass.getMethod("getCompileSdk")
                val currentSdk = compileSdkField.invoke(android) as? Int
                if (currentSdk != null && currentSdk < 36) {
                    android.javaClass.getMethod("setCompileSdk", Int::class.javaPrimitiveType).invoke(android, 36)
                }
            } catch (_: Exception) {}
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

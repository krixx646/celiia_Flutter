allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// Force plugin Android modules onto compileSdk 36 (several still declare 34/35).
subprojects {
    afterEvaluate {
        val android = extensions.findByName("android") ?: return@afterEvaluate
        val clazz = android.javaClass
        for (methodName in listOf("setCompileSdkVersion", "setCompileSdk")) {
            try {
                clazz.getMethod(methodName, Int::class.javaPrimitiveType).invoke(android, 36)
                break
            } catch (_: Throwable) {
                // try next
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

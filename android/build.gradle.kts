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
}
subprojects {
    project.evaluationDependsOn(":app")
}
subprojects {
    val configureAndroid: Project.() -> Unit = {
        extensions.findByName("android")?.let { android ->
            listOf("compileSdkVersion", "setCompileSdkVersion", "setCompileSdk").forEach { methodName ->
                try {
                    val method = android.javaClass.getMethod(methodName, Int::class.javaPrimitiveType)
                    method.invoke(android, 35)
                } catch (_: Throwable) {
                    try {
                        val method = android.javaClass.getMethod(methodName, java.lang.Integer::class.java)
                        method.invoke(android, 35)
                    } catch (_: Throwable) {}
                }
            }
        }
    }

    if (state.executed) {
        configureAndroid()
    } else {
        afterEvaluate {
            configureAndroid()
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

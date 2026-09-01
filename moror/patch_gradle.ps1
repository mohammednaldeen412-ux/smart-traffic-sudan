$content = Get-Content android/build.gradle -Raw
$content = $content -replace '(?s)subprojects \{[^}]*jvmTarget[^}]*\}[^}]*\}', ''
$content += "

subprojects {
    afterEvaluate { project ->
        if (project.hasProperty('android')) {
            project.android {
                compileOptions {
                    sourceCompatibility JavaVersion.VERSION_17
                    targetCompatibility JavaVersion.VERSION_17
                }
            }
        }
        project.tasks.withType(JavaCompile).configureEach {
            sourceCompatibility = JavaVersion.VERSION_17
            targetCompatibility = JavaVersion.VERSION_17
        }
        project.tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile).configureEach {
            kotlinOptions {
                jvmTarget = "17"
            }
        }
    }
}
"
Set-Content android/build.gradle $content

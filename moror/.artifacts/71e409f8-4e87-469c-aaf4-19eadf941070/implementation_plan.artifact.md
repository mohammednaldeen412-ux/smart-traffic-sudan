# Fix Build failure with Java 25 and Environment Conflict

The project is currently failing to build because:
1. Java 25 is being used, which requires very recent versions of Gradle and Android Gradle Plugin (AGP).
2. There is a conflict between `ANDROID_PREFS_ROOT` and `ANDROID_USER_HOME` environment variables, which AGP 9.x is strict about.

## Proposed Changes

### [Component] Android Build Configuration

#### [MODIFY] [gradle-wrapper.properties](file:///C:/Users/DATA/Desktop/moror/android/gradle/wrapper/gradle-wrapper.properties)
Ensure Gradle 9.7.0 is used to support Java 25.

#### [MODIFY] [settings.gradle](file:///C:/Users/DATA/Desktop/moror/android/settings.gradle)
Use AGP 9.3.1 and Kotlin 2.4.10 for compatibility with Java 25.

#### [MODIFY] [build.gradle](file:///C:/Users/DATA/Desktop/moror/android/app/build.gradle)
Ensure the app-level build file is correctly configured for AGP 9.x.

## Verification Plan

### Automated Tests
- Run `flutter build apk --debug` with `ANDROID_PREFS_ROOT` unset to bypass the environment conflict.

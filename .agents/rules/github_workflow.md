---
name: GitHub APK Release Workflow
description: Automates the process of copying the latest Flutter APK and pushing it to GitHub.
trigger: model_decision
---

# GitHub APK Release Workflow

When the user asks you to "ارفع التطبيق" or "عمل لي GitHub" or similar requests to update the GitHub repository with the latest app version, follow this exact procedure:

1. **Copy the latest APK:**
   Copy the `app-release.apk` file from the Flutter build directory:
   `C:\Users\DATA\Desktop\TrafficProjects\moror\build\app\outputs\flutter-apk\app-release.apk`
   To the GitHub repository's apk directory:
   `C:\Users\DATA\Desktop\smart-traffic-sudan\apk\app-release.apk`
   (Overwrite the existing file).

2. **Commit and Push:**
   Execute the following git commands in `C:\Users\DATA\Desktop\smart-traffic-sudan`:
   ```powershell
   git add apk/app-release.apk
   git commit -m "Update app-release.apk with latest version"
   git push origin main
   ```

3. **Confirm with User:**
   Wait for the push to complete (it is a ~65MB file, so it may take time). Once successful, inform the user that the new version is now live on GitHub and the download button in the README automatically points to this updated file.

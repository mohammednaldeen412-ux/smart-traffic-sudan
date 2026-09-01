@echo off
color 0A
echo ===========================================
echo    Smart Traffic Sudan - Deep Clean \u0026 Deploy
echo ===========================================
echo.

:: 1. Deep Clean Firebase Temp/Config folders
echo [1/4] Cleaning corrupted Firebase files...
if exist "%APPDATA%\configstore" rmdir /s /q "%APPDATA%\configstore"
if exist "%USERPROFILE%\.firebase" rmdir /s /q "%USERPROFILE%\.firebase"
if exist ".firebase" rmdir /s /q ".firebase"

:: 2. Check if build is needed
if not exist "build\web\index.html" (
    echo [2/4] Building Web Files...
    call flutter build web
) else (
    echo [2/4] Web files ready.
)

echo.
echo [3/4] Trying to Login (Skip Welcome Screen)...
echo.
echo * If it fails with SyntaxError, we will use a different method.
echo.

:: Try login with a flag that might bypass the broken welcome logic
.\firebase.exe login --no-localhost

if %errorlevel% neq 0 (
    echo.
    echo ===========================================
    echo [IMPORTANT] Standalone tool is still failing.
    echo Please follow these 2 simple steps:
    echo 1. Download \u0026 Install Node.js from: https://nodejs.org/
    echo 2. After install, run this command in Terminal:
    echo    npm install -g firebase-tools
    echo ===========================================
)

echo.
echo [4/4] Final Attempt to Deploy...
.\firebase.exe deploy --only hosting

echo.
pause

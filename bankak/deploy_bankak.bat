@echo off
color 0A
echo ===========================================
echo    Bankak Web - Build & Deploy to Firebase
echo ===========================================
echo.
echo [1/3] Building Bankak Web App...
call npm run build

if %errorlevel% neq 0 (
    echo [ERROR] Build failed!
    pause
    exit /b %errorlevel%
)

echo.
echo [2/3] Build succeeded. Deploying to Google Firebase Hosting (smart-traffic-bankak)...
call npx firebase deploy --only hosting:smart-traffic-bankak --project smart-traffic-sudan

echo.
echo ===========================================
echo [3/3] Deployment complete!
echo Site URL: https://smart-traffic-bankak.web.app
echo ===========================================
pause

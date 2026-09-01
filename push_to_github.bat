@echo off
color 0A
title Push Smart Traffic Sudan to GitHub
echo ========================================================
echo    Pushing Smart Traffic Sudan System to GitHub...
echo ========================================================
echo.
cd /d "%~dp0"

echo [1/3] Adding changes...
git add .

echo.
echo [2/3] Checking commits...
git commit -m "Update Smart Traffic Sudan Ecosystem" 2>nul || echo Everything up to date.

echo.
echo [3/3] Uploading to GitHub (https://github.com/mohammednaldeen412-ux/smart-traffic-sudan)...
git branch -M main
git push -u origin main

echo.
if %errorlevel% equ 0 (
    echo ========================================================
    echo  SUCCESS: Project successfully pushed to GitHub!
    echo ========================================================
) else (
    echo [NOTE] If prompted above, please complete GitHub sign-in.
)
echo.
pause

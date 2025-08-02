@echo off
title Doctor CRM Enhanced Debug Launcher
color 0A

echo ========================================
echo    Doctor CRM Enhanced Debug Launcher
echo ========================================
echo.
echo Working directory: %CD%
echo Current time: %date% %time%
echo.

REM Check if executable exists
if not exist "ayurvedic_doctor_crm.exe" (
    echo [ERROR] ayurvedic_doctor_crm.exe not found!
    goto :end
)

echo [INFO] Checking DLL dependencies...
echo.

REM List all files in current directory
echo [INFO] Files in application directory:
dir /b *.dll *.exe
echo.

REM Check for common missing DLLs
echo [INFO] Checking for critical DLLs:
if exist "msvcp140.dll" (echo ✓ msvcp140.dll found) else (echo ✗ msvcp140.dll MISSING)
if exist "vcruntime140.dll" (echo ✓ vcruntime140.dll found) else (echo ✗ vcruntime140.dll MISSING)
if exist "vcruntime140_1.dll" (echo ✓ vcruntime140_1.dll found) else (echo ✗ vcruntime140_1.dll MISSING)
if exist "flutter_windows.dll" (echo ✓ flutter_windows.dll found) else (echo ✗ flutter_windows.dll MISSING)
echo.

REM Set timeout for the process
echo [INFO] Launching application with 30-second timeout...
echo [INFO] If app doesn't appear in 30 seconds, it's likely hanging
echo.

REM Start the process and monitor it
start "" "ayurvedic_doctor_crm.exe"

REM Wait and check if process started
timeout /t 5 /nobreak >nul
tasklist /fi "imagename eq ayurvedic_doctor_crm.exe" 2>nul | find /i "ayurvedic_doctor_crm.exe" >nul

if %errorlevel%==0 (
    echo [INFO] Process started successfully!
    echo [INFO] Waiting for application window to appear...
    
    REM Wait 30 seconds for the app to show
    timeout /t 30 /nobreak >nul
    
    REM Check if process is still running
    tasklist /fi "imagename eq ayurvedic_doctor_crm.exe" 2>nul | find /i "ayurvedic_doctor_crm.exe" >nul
    
    if %errorlevel%==0 (
        echo [WARNING] Process is running but no window appeared!
        echo [INFO] This usually indicates:
        echo   1. Missing DLL dependencies
        echo   2. Firebase initialization hanging
        echo   3. Windows Defender blocking the app
        echo   4. Network connectivity issues
        echo.
        echo [ACTION] Killing the hanging process...
        taskkill /f /im ayurvedic_doctor_crm.exe >nul 2>&1
        echo [INFO] Process terminated
    ) else (
        echo [INFO] Application closed normally
    )
) else (
    echo [ERROR] Process failed to start!
    echo [INFO] This usually indicates:
    echo   1. Missing Visual C++ Redistributable
    echo   2. Corrupted executable
    echo   3. Windows compatibility issues
)

echo.
echo [INFO] Checking Windows Event Log for errors...
powershell -command "Get-WinEvent -FilterHashtable @{LogName='Application'; Level=2; StartTime=(Get-Date).AddMinutes(-5)} | Where-Object {$_.ProcessId -ne $null -and $_.LevelDisplayName -eq 'Error'} | Select-Object -First 5 TimeCreated, Id, LevelDisplayName, Message | Format-Table -AutoSize" 2>nul

:end
echo.
echo ========================================
echo Diagnosis complete.
echo.
echo COMMON SOLUTIONS:
echo 1. Install Visual C++ Redistributable 2022 x64
echo 2. Run as Administrator
echo 3. Temporarily disable Windows Defender
echo 4. Check internet connection for Firebase
echo 5. Install Windows updates
echo.
echo Press any key to close...
pause >nul
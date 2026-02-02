@echo off
REM Run MTP Target Forever Client with Log Rotation (Windows)
REM
REM This script starts the game client and rotates log files on startup
REM to prevent infinite log growth.
REM
REM Usage: scripts\run-client.bat [options]
REM Options:
REM   --lan <hostname>  Auto-connect to LAN server
REM   --user <username> Set username for auto-connect

setlocal enabledelayedexpansion

REM Configuration
set MAX_LOGS=5

REM Determine directories
set SCRIPT_DIR=%~dp0
set PROJECT_DIR=%SCRIPT_DIR%..

REM Check for client (Ninja outputs to bin/, VS outputs to bin/Release/)
set CLIENT_DIR=%PROJECT_DIR%\build-client\bin
if not exist "%CLIENT_DIR%\mtp-target-forever.exe" (
    set CLIENT_DIR=%PROJECT_DIR%\build-client\bin\Release
)
if not exist "%CLIENT_DIR%\mtp-target-forever.exe" (
    set CLIENT_DIR=%PROJECT_DIR%\build\bin\Release
)

set LOG_DIR=%CLIENT_DIR%\logs

REM Check if client exists
if not exist "%CLIENT_DIR%\mtp-target-forever.exe" (
    echo Error: Client not found at %CLIENT_DIR%\mtp-target-forever.exe
    echo Please build the client first with: scripts\build-client.bat
    exit /b 1
)

REM Create logs directory
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

echo =========================================
echo   MTP Target Forever Client
echo =========================================
echo.
echo Client directory: %CLIENT_DIR%
echo Log directory: %LOG_DIR%
echo.

REM Rotate log files
echo Rotating logs...
call :rotate_log "log.log"
call :rotate_log "chat.log"
call :rotate_log "nel_debug.dmp"
echo.

REM Check for login service
echo Checking services...
netstat -an 2>nul | findstr ":49997.*LISTENING" >nul
if %ERRORLEVEL%==0 (
    echo + Login service running on port 49997
) else (
    echo ! Login service not detected (port 49997)
    echo   For online play, start: cd login-service-deno ^&^& deno task login
    echo   For LAN play, select "Play on LAN" in game menu
)
echo.

REM Start client
echo Starting client...
echo.
echo Controls:
echo   - Arrow keys: Steer penguin
echo   - CTRL: Toggle ball/gliding modes
echo   - Enter: Open chat
echo.

cd /d "%CLIENT_DIR%"
mtp-target-forever.exe %*

echo.
echo Client exited.

REM Move any new logs to logs directory
if exist "%CLIENT_DIR%\log.log" move /Y "%CLIENT_DIR%\log.log" "%LOG_DIR%\" >nul 2>nul
if exist "%CLIENT_DIR%\chat.log" move /Y "%CLIENT_DIR%\chat.log" "%LOG_DIR%\" >nul 2>nul

echo Logs saved to: %LOG_DIR%
goto :end

REM ============================================
REM Log rotation function
REM ============================================
:rotate_log
set LOG_NAME=%~1
set LOG_FILE=%LOG_DIR%\%LOG_NAME%
set MAIN_LOG=%CLIENT_DIR%\%LOG_NAME%

REM Move main log to logs directory if it exists
if exist "%MAIN_LOG%" (
    REM Remove oldest
    if exist "%LOG_FILE%.%MAX_LOGS%" del /F /Q "%LOG_FILE%.%MAX_LOGS%"

    REM Shift existing logs
    for /L %%i in (%MAX_LOGS%,-1,2) do (
        set /a PREV=%%i-1
        if exist "%LOG_FILE%.!PREV!" move /Y "%LOG_FILE%.!PREV!" "%LOG_FILE%.%%i" >nul 2>nul
    )

    REM Current becomes .1
    if exist "%LOG_FILE%" move /Y "%LOG_FILE%" "%LOG_FILE%.1" >nul 2>nul

    REM Move main log to logs directory
    move /Y "%MAIN_LOG%" "%LOG_FILE%" >nul 2>nul
    echo    + Rotated: %LOG_NAME%
)
exit /b 0

:end
endlocal

@echo off
REM Run MTP Target Forever Server with Log Rotation (Windows)
REM
REM This script starts the game server and rotates log files on startup
REM to prevent infinite log growth.
REM
REM Usage: scripts\run-server.bat

setlocal enabledelayedexpansion

REM Configuration
set MAX_LOGS=5

REM Determine directories
set SCRIPT_DIR=%~dp0
set PROJECT_DIR=%SCRIPT_DIR%..

REM Check for server (Ninja outputs to bin/, VS outputs to bin/Release/)
set SERVER_DIR=%PROJECT_DIR%\build-server\bin
if not exist "%SERVER_DIR%\mtp-target-forever-srv.exe" (
    set SERVER_DIR=%PROJECT_DIR%\build-server\bin\Release
)
if not exist "%SERVER_DIR%\mtp-target-forever-srv.exe" (
    set SERVER_DIR=%PROJECT_DIR%\build\bin\Release
)

set LOG_DIR=%SERVER_DIR%\logs

REM Check if server exists
if not exist "%SERVER_DIR%\mtp-target-forever-srv.exe" (
    echo Error: Server not found at %SERVER_DIR%\mtp-target-forever-srv.exe
    echo Please build the server first with: scripts\build-server.bat
    exit /b 1
)

REM Create logs directory
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

echo =========================================
echo   MTP Target Forever Server
echo =========================================
echo.
echo Server directory: %SERVER_DIR%
echo Log directory: %LOG_DIR%
echo.

REM Rotate log files
echo Rotating logs...
call :rotate_log "mtp_target_service.log"
call :rotate_log "log.log"
call :rotate_log "nel_debug.dmp"
echo.

REM Show server configuration summary
if exist "%SERVER_DIR%\mtp_target_service.cfg" (
    echo Server configuration:
    findstr /B "TcpPort NbMaxClients NbBot SessionTimeout" "%SERVER_DIR%\mtp_target_service.cfg" 2>nul
    echo.
)

REM Start server
echo Starting server...
echo.
echo Server commands (in-game chat):
echo   /help       - Show available commands
echo   /v ^<level^>  - Vote for a level
echo   /forcemap   - Force next level (admin)
echo   /forceend   - End current session (admin)
echo.

cd /d "%SERVER_DIR%"
mtp-target-forever-srv.exe

echo.
echo Server exited.

REM Move any remaining logs to logs directory
if exist "%SERVER_DIR%\log.log" move /Y "%SERVER_DIR%\log.log" "%LOG_DIR%\" >nul 2>nul
if exist "%SERVER_DIR%\mtp_target_service.log" move /Y "%SERVER_DIR%\mtp_target_service.log" "%LOG_DIR%\" >nul 2>nul

echo Logs saved to: %LOG_DIR%
goto :end

REM ============================================
REM Log rotation function
REM ============================================
:rotate_log
set LOG_NAME=%~1
set LOG_FILE=%LOG_DIR%\%LOG_NAME%
set MAIN_LOG=%SERVER_DIR%\%LOG_NAME%

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

@echo off
REM
REM Build Both MTP Target Forever Client and Server (Windows)
REM
REM This script builds both the game client and server to separate directories.
REM Usage: scripts\build-all.bat [--clean] [--skip-post-build]
REM

setlocal

set SCRIPT_DIR=%~dp0

echo =========================================
echo   Building Client and Server
echo =========================================
echo.

REM Build client first
echo --- Building Client ---
call "%SCRIPT_DIR%build-client.bat" %*

if %ERRORLEVEL% neq 0 (
    echo Client build failed!
    exit /b %ERRORLEVEL%
)

echo.
echo.

REM Then build server
echo --- Building Server ---
call "%SCRIPT_DIR%build-server.bat" %*

if %ERRORLEVEL% neq 0 (
    echo Server build failed!
    exit /b %ERRORLEVEL%
)

echo.
echo =========================================
echo   Both builds complete!
echo =========================================
echo.
echo Client: build-client\bin\mtp-target-forever.exe
echo Server: build-server\bin\mtp-target-forever-srv.exe
echo.
echo Run scripts:
echo   scripts\run-client.bat
echo   scripts\run-server.bat

endlocal

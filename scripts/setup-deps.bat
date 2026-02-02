@echo off
REM
REM MTP Target Forever Dependencies Setup (Windows wrapper)
REM
REM Usage:
REM   scripts\setup-deps.bat              - Install dependencies
REM   scripts\setup-deps.bat --verify     - Verify existing installation
REM   scripts\setup-deps.bat --force      - Force re-download
REM

setlocal

set SCRIPT_DIR=%~dp0

REM Pass all arguments to PowerShell script
powershell -ExecutionPolicy Bypass -File "%SCRIPT_DIR%setup-deps.ps1" %*

endlocal
exit /b %ERRORLEVEL%

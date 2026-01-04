@echo off
REM Clear Tux Target client cache
REM This removes cached level files and other cached data

set CACHE_DIR=%~dp0..\build-client\bin\Release\cache

if exist "%CACHE_DIR%" (
    echo Clearing client cache at: %CACHE_DIR%
    del /Q "%CACHE_DIR%\*" 2>nul
    for /D %%d in ("%CACHE_DIR%\*") do rmdir /S /Q "%%d" 2>nul
    echo Cache cleared successfully.
) else (
    echo Cache directory not found: %CACHE_DIR%
    echo Nothing to clear.
)

pause

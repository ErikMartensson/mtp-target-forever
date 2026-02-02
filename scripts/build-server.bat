@echo off
REM
REM Build MTP Target Forever Server (Windows)
REM
REM Prerequisites: Run setup-deps.ps1 first to install dependencies
REM
REM Usage:
REM   scripts\build-server.bat              - Build server
REM   scripts\build-server.bat --clean      - Clean build
REM   scripts\build-server.bat --skip-post-build  - Skip post-build setup
REM

setlocal enabledelayedexpansion

REM Setup MSVC environment if needed
call "%~dp0setup-msvc-env.bat"
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

REM Parse arguments
set CLEAN_BUILD=0
set SKIP_POST_BUILD=0
for %%a in (%*) do (
    if "%%a"=="--clean" set CLEAN_BUILD=1
    if "%%a"=="--skip-post-build" set SKIP_POST_BUILD=1
)

REM Determine directories
set SCRIPT_DIR=%~dp0
set PROJECT_DIR=%SCRIPT_DIR%..
set BUILD_DIR=%PROJECT_DIR%\build-server

echo =========================================
echo   MTP Target Forever Server Build (Windows)
echo =========================================
echo.
echo Project directory: %PROJECT_DIR%
echo Build directory:   %BUILD_DIR%
echo.

REM Check dependencies (default: deps/ directory in repo)
set DEPS_PATH=%PROJECT_DIR%\deps
if defined MTPDEPS_PATH set DEPS_PATH=%MTPDEPS_PATH%
if defined TUXDEPS_PATH set DEPS_PATH=%TUXDEPS_PATH%
echo Dependencies path: %DEPS_PATH%

if not exist "%DEPS_PATH%\lua\lib\lua.lib" (
    echo.
    echo ERROR: Dependencies not found at %DEPS_PATH%
    echo Please run: scripts\setup-deps.bat
    echo.
    exit /b 1
)

if not exist "%DEPS_PATH%\ode\lib\ode_doubles.lib" (
    echo.
    echo ERROR: ODE physics library not found at %DEPS_PATH%\ode
    echo Please run: scripts\setup-deps.bat
    echo.
    exit /b 1
)
echo Dependencies: OK
echo.

REM Clean build if requested
if %CLEAN_BUILD%==1 (
    echo Cleaning build directory...
    if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%"
)

REM Create build directory
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"
cd /d "%BUILD_DIR%"

REM Get number of processors
set NUM_CORES=%NUMBER_OF_PROCESSORS%
if "%NUM_CORES%"=="" set NUM_CORES=4
echo Using %NUM_CORES% CPU cores for build
echo.

REM Set NeL path (check repo ryzomcore/ first, then env var, then default)
set NEL_PATH=
if exist "%PROJECT_DIR%\ryzomcore\build\lib\nelmisc_r.lib" (
    set NEL_PATH=%PROJECT_DIR%/ryzomcore/build
    echo Using local ryzomcore/
) else if defined NEL_PREFIX_PATH (
    set NEL_PATH=%NEL_PREFIX_PATH%
    echo Using NEL_PREFIX_PATH: %NEL_PREFIX_PATH%
) else if exist "C:\ryzomcore\build\lib\nelmisc_r.lib" (
    set NEL_PATH=C:/ryzomcore/build
    echo Using C:/ryzomcore/build
) else (
    echo.
    echo ERROR: RyzomCore/NeL not found!
    echo Please run: powershell -ExecutionPolicy Bypass -File scripts\setup-ryzomcore.ps1
    echo.
    exit /b 1
)
echo NeL path: %NEL_PATH%
echo.

REM Get CMake args from shared config (single source of truth)
echo Getting CMake configuration...
for /f "delims=" %%a in ('powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%cmake-config.ps1" -OutputArgs Server -DepsPath "%DEPS_PATH%" -NelPath "%NEL_PATH%"') do set CMAKE_ARGS=%%a

REM Configure CMake using Ninja generator
echo Configuring CMake (Server)...
cmake .. -G Ninja -DCMAKE_BUILD_TYPE=Release %CMAKE_ARGS%

if %ERRORLEVEL% neq 0 (
    echo CMake configuration failed!
    exit /b %ERRORLEVEL%
)
echo.

REM Build (Ninja uses all cores by default)
echo Building server...
cmake --build .

if %ERRORLEVEL% neq 0 (
    echo Build failed!
    exit /b %ERRORLEVEL%
)

echo.
echo Build complete!

REM Check for executable (Ninja outputs to bin/, not bin/Release/)
if exist "%BUILD_DIR%\bin\mtp-target-forever-srv.exe" (
    echo Server executable: %BUILD_DIR%\bin\mtp-target-forever-srv.exe
) else (
    echo Warning: Server executable not found
)

REM Run post-build setup
if %SKIP_POST_BUILD%==0 (
    echo.
    echo Running post-build setup...
    call "%SCRIPT_DIR%post-build.bat" --server-only --build-dir "%BUILD_DIR%\bin"
)

echo.
echo =========================================
echo   Server build finished!
echo =========================================
echo.
echo To run the server:
echo   scripts\run-server.bat
echo.

endlocal

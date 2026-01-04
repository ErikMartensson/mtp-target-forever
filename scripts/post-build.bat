@echo off
REM Post-Build Setup Script for Tux Target (Windows)
REM
REM This script copies all required runtime files to the build directory
REM after compiling the client and server.
REM
REM Usage:
REM   scripts\post-build.bat                              # Setup both (legacy build\)
REM   scripts\post-build.bat --client-only                # Setup client only
REM   scripts\post-build.bat --server-only                # Setup server only
REM   scripts\post-build.bat --build-dir C:\path\to\dir   # Custom build directory
REM
REM Options:
REM   --client-only    Only copy files needed for the client
REM   --server-only    Only copy files needed for the server
REM   --build-dir DIR  Specify custom release directory

setlocal enabledelayedexpansion

REM Default configuration
set RYZOMCORE_DIR=C:\ryzomcore
set PROJECT_DIR=%~dp0..
set RELEASE_DIR=
set CLIENT_ONLY=0
set SERVER_ONLY=0

REM Parse arguments
:parse_args
if "%~1"=="" goto done_parsing
if "%~1"=="--client-only" (
    set CLIENT_ONLY=1
    shift
    goto parse_args
)
if "%~1"=="--server-only" (
    set SERVER_ONLY=1
    shift
    goto parse_args
)
if "%~1"=="--build-dir" (
    set RELEASE_DIR=%~2
    shift
    shift
    goto parse_args
)
echo Unknown option: %~1
exit /b 1

:done_parsing

REM Set default release directory if not specified
if "%RELEASE_DIR%"=="" (
    if %CLIENT_ONLY%==1 (
        set RELEASE_DIR=%PROJECT_DIR%\build-client\bin\Release
    ) else if %SERVER_ONLY%==1 (
        set RELEASE_DIR=%PROJECT_DIR%\build-server\bin\Release
    ) else (
        set RELEASE_DIR=%PROJECT_DIR%\build\bin\Release
    )
)

REM Determine mode string for display
if %CLIENT_ONLY%==1 (
    set MODE=Client
) else if %SERVER_ONLY%==1 (
    set MODE=Server
) else (
    set MODE=Client + Server
)

echo =========================================
echo Tux Target Post-Build Setup (%MODE%)
echo =========================================
echo.

if not exist "%RELEASE_DIR%" (
    echo Error: Build directory not found: %RELEASE_DIR%
    echo Please build the project first.
    exit /b 1
)

echo Build directory: %RELEASE_DIR%
echo.

set STEP=1

REM ============================================
REM CLIENT-ONLY SETUP
REM ============================================
if %SERVER_ONLY%==1 goto skip_client_setup

REM 1. Copy NeL Driver DLLs (Client needs graphics + audio drivers)
echo %STEP%. Copying NeL driver DLLs...
if exist "%RYZOMCORE_DIR%\build\bin\Release\nel_drv_opengl_win_r.dll" (
    copy /Y "%RYZOMCORE_DIR%\build\bin\Release\nel_drv_opengl_win_r.dll" "%RELEASE_DIR%\" >nul
    echo    + Copied: nel_drv_opengl_win_r.dll
) else (
    echo    ! Missing: nel_drv_opengl_win_r.dll
)

if exist "%RYZOMCORE_DIR%\build\bin\Release\nel_drv_openal_win_r.dll" (
    copy /Y "%RYZOMCORE_DIR%\build\bin\Release\nel_drv_openal_win_r.dll" "%RELEASE_DIR%\" >nul
    echo    + Copied: nel_drv_openal_win_r.dll
) else (
    echo    ! Missing: nel_drv_openal_win_r.dll
)
echo.
set /a STEP+=1

REM 2. Copy Font Files (Client-specific)
echo %STEP%. Copying font files...
if not exist "%RELEASE_DIR%\data\font" mkdir "%RELEASE_DIR%\data\font"

if exist "%RYZOMCORE_DIR%\nel\samples\3d\cegui\datafiles\n019003l.pfb" (
    copy /Y "%RYZOMCORE_DIR%\nel\samples\3d\cegui\datafiles\n019003l.pfb" "%RELEASE_DIR%\data\font\" >nul
    echo    + Copied: n019003l.pfb
) else (
    echo    ! Missing: n019003l.pfb
)

if exist "%RYZOMCORE_DIR%\nel\samples\3d\font\beteckna.ttf" (
    copy /Y "%RYZOMCORE_DIR%\nel\samples\3d\font\beteckna.ttf" "%RELEASE_DIR%\data\font\bigfont.ttf" >nul
    echo    + Copied: bigfont.ttf
) else (
    echo    ! Missing: beteckna.ttf
)
echo.
set /a STEP+=1

REM 3. Copy GUI data (Client-specific)
echo %STEP%. Copying GUI data...
if not exist "%RELEASE_DIR%\data\gui" mkdir "%RELEASE_DIR%\data\gui"

REM Copy v1.2.2a GUI files first (from client/data/gui)
if exist "%PROJECT_DIR%\client\data\gui" (
    xcopy /Y /E /Q "%PROJECT_DIR%\client\data\gui\*" "%RELEASE_DIR%\data\gui\" >nul 2>nul
    echo    + Copied v1.2.2a GUI files
) else (
    echo    ! Warning: v1.2.2a GUI data not found
)

REM Copy any additional GUI files from data/gui (if they don't conflict)
if exist "%PROJECT_DIR%\data\gui" (
    for %%F in ("%PROJECT_DIR%\data\gui\*.xml" "%PROJECT_DIR%\data\gui\*.tga") do (
        if not exist "%RELEASE_DIR%\data\gui\%%~nxF" (
            copy /Y "%%F" "%RELEASE_DIR%\data\gui\" >nul 2>nul
        )
    )
    echo    + Merged additional GUI files
)
echo.
set /a STEP+=1

REM 4. Copy client config
echo %STEP%. Copying client config...
if exist "%PROJECT_DIR%\data\config\mtp_target_default.cfg" (
    copy /Y "%PROJECT_DIR%\data\config\mtp_target_default.cfg" "%RELEASE_DIR%\" >nul
    echo    + Copied: mtp_target_default.cfg
) else if exist "%PROJECT_DIR%\client\mtp_target_default.cfg" (
    copy /Y "%PROJECT_DIR%\client\mtp_target_default.cfg" "%RELEASE_DIR%\" >nul
    echo    ! Warning: Using original config (may need water fix)
)

REM Create tux-target.cfg wrapper (client looks for this file, not mtp_target_default.cfg)
if not exist "%RELEASE_DIR%\tux-target.cfg" (
    echo // This file tells the client where to find the main config> "%RELEASE_DIR%\tux-target.cfg"
    echo RootConfigFilename = "mtp_target_default.cfg";>> "%RELEASE_DIR%\tux-target.cfg"
    echo    + Created: tux-target.cfg
) else (
    echo    + tux-target.cfg already exists
)
echo.
set /a STEP+=1

REM 5. Copy client data files (textures, sounds, etc.)
echo %STEP%. Copying client data files...
if exist "%PROJECT_DIR%\data\texture" (
    if not exist "%RELEASE_DIR%\data\texture" mkdir "%RELEASE_DIR%\data\texture"
    xcopy /Y /E /Q "%PROJECT_DIR%\data\texture\*" "%RELEASE_DIR%\data\texture\" >nul 2>nul
    for /f %%a in ('dir /b "%RELEASE_DIR%\data\texture\*.dds" "%RELEASE_DIR%\data\texture\*.tga" 2^>nul ^| C:\Windows\System32\find.exe /c /v ""') do set TEXTURE_COUNT=%%a
    echo    + Copied !TEXTURE_COUNT! texture files
)
if exist "%PROJECT_DIR%\data\sound" (
    if not exist "%RELEASE_DIR%\data\sound" mkdir "%RELEASE_DIR%\data\sound"
    xcopy /Y /E /Q "%PROJECT_DIR%\data\sound\*" "%RELEASE_DIR%\data\sound\" >nul 2>nul
    echo    + Copied sound files
)
if exist "%PROJECT_DIR%\data\particle" (
    if not exist "%RELEASE_DIR%\data\particle" mkdir "%RELEASE_DIR%\data\particle"
    xcopy /Y /E /Q "%PROJECT_DIR%\data\particle\*" "%RELEASE_DIR%\data\particle\" >nul 2>nul
    echo    + Copied particle files
)
if exist "%PROJECT_DIR%\data\misc" (
    if not exist "%RELEASE_DIR%\data\misc" mkdir "%RELEASE_DIR%\data\misc"
    xcopy /Y /E /Q "%PROJECT_DIR%\data\misc\*" "%RELEASE_DIR%\data\misc\" >nul 2>nul
    echo    + Copied misc files
)
if exist "%PROJECT_DIR%\data\smiley" (
    if not exist "%RELEASE_DIR%\data\smiley" mkdir "%RELEASE_DIR%\data\smiley"
    xcopy /Y /E /Q "%PROJECT_DIR%\data\smiley\*" "%RELEASE_DIR%\data\smiley\" >nul 2>nul
    echo    + Copied smiley files
)
echo.
set /a STEP+=1

REM 6. Create remaining client directories
echo %STEP%. Creating remaining client directories...
if not exist "%RELEASE_DIR%\cache" mkdir "%RELEASE_DIR%\cache"
if not exist "%RELEASE_DIR%\replay" mkdir "%RELEASE_DIR%\replay"
if not exist "%RELEASE_DIR%\logs" mkdir "%RELEASE_DIR%\logs"
echo    + Client directory structure created
echo.
set /a STEP+=1

:skip_client_setup

REM ============================================
REM SERVER-ONLY SETUP
REM ============================================
if %CLIENT_ONLY%==1 goto skip_server_setup

REM Server config
echo %STEP%. Copying server config...
if not exist "%RELEASE_DIR%\mtp_target_service.cfg" (
    if exist "%PROJECT_DIR%\server\mtp_target_service_default.cfg" (
        copy /Y "%PROJECT_DIR%\server\mtp_target_service_default.cfg" "%RELEASE_DIR%\mtp_target_service.cfg" >nul
        echo    + Copied: mtp_target_service.cfg
    )
) else (
    echo    + Server config already exists
)
echo.
set /a STEP+=1

REM Copy helpers.lua (required for include() function in level scripts)
echo %STEP%. Copying helpers.lua...
if exist "%PROJECT_DIR%\server\data\misc\helpers.lua" (
    copy /Y "%PROJECT_DIR%\server\data\misc\helpers.lua" "%RELEASE_DIR%\data\" >nul
    echo    + Copied: helpers.lua
) else (
    echo    ! Warning: helpers.lua not found
)
echo.
set /a STEP+=1

REM Lua server scripts (Server-specific)
echo %STEP%. Copying Lua server scripts...
if not exist "%RELEASE_DIR%\data\lua" mkdir "%RELEASE_DIR%\data\lua"
if exist "%PROJECT_DIR%\data\lua" (
    copy /Y "%PROJECT_DIR%\data\lua\*.lua" "%RELEASE_DIR%\data\lua\" >nul 2>nul
    for /f %%a in ('dir /b "%RELEASE_DIR%\data\lua\*_server.lua" 2^>nul ^| C:\Windows\System32\find.exe /c /v ""') do set LUA_COUNT=%%a
    echo    + Copied !LUA_COUNT! Lua server scripts
) else (
    echo    ! Warning: Lua server scripts not found
)
echo.
set /a STEP+=1

REM Module Lua scripts (Server-specific - for paint, team, etc.)
echo %STEP%. Copying module Lua scripts...
if not exist "%RELEASE_DIR%\data\module" mkdir "%RELEASE_DIR%\data\module"
if exist "%PROJECT_DIR%\data\module" (
    copy /Y "%PROJECT_DIR%\data\module\*.lua" "%RELEASE_DIR%\data\module\" >nul 2>nul
    for /f %%a in ('dir /b "%RELEASE_DIR%\data\module\*.lua" 2^>nul ^| C:\Windows\System32\find.exe /c /v ""') do set MODULE_COUNT=%%a
    echo    + Copied !MODULE_COUNT! module Lua scripts
) else (
    echo    ! Warning: Module Lua scripts not found
)
echo.
set /a STEP+=1

REM Create server directories
echo %STEP%. Creating server directory structure...
if not exist "%RELEASE_DIR%\data\level" mkdir "%RELEASE_DIR%\data\level"
if not exist "%RELEASE_DIR%\data\lua" mkdir "%RELEASE_DIR%\data\lua"
if not exist "%RELEASE_DIR%\data\module" mkdir "%RELEASE_DIR%\data\module"
if not exist "%RELEASE_DIR%\data\shape" mkdir "%RELEASE_DIR%\data\shape"
if not exist "%RELEASE_DIR%\data\texture" mkdir "%RELEASE_DIR%\data\texture"
if not exist "%RELEASE_DIR%\data\particle" mkdir "%RELEASE_DIR%\data\particle"
if not exist "%RELEASE_DIR%\data\misc" mkdir "%RELEASE_DIR%\data\misc"
if not exist "%RELEASE_DIR%\data\smiley" mkdir "%RELEASE_DIR%\data\smiley"
if not exist "%RELEASE_DIR%\data\sound" mkdir "%RELEASE_DIR%\data\sound"
if not exist "%RELEASE_DIR%\data\font" mkdir "%RELEASE_DIR%\data\font"
if not exist "%RELEASE_DIR%\logs" mkdir "%RELEASE_DIR%\logs"
echo    + Server directory structure created
echo.
set /a STEP+=1

REM Copy game data files for server to serve to clients
echo %STEP%. Copying game data files (shapes, textures, etc.)...

REM Shape files - server serves these to clients
if exist "%PROJECT_DIR%\data\shape" (
    xcopy /Y /E /Q "%PROJECT_DIR%\data\shape\*" "%RELEASE_DIR%\data\shape\" >nul 2>nul
    for /f %%a in ('dir /b "%RELEASE_DIR%\data\shape\*.shape" 2^>nul ^| C:\Windows\System32\find.exe /c /v ""') do set SHAPE_COUNT=%%a
    echo    + Copied !SHAPE_COUNT! shape files
)

REM Texture files
if exist "%PROJECT_DIR%\data\texture" (
    xcopy /Y /E /Q "%PROJECT_DIR%\data\texture\*" "%RELEASE_DIR%\data\texture\" >nul 2>nul
    echo    + Copied texture files
)

REM Font files
if exist "%PROJECT_DIR%\data\font" (
    xcopy /Y /E /Q "%PROJECT_DIR%\data\font\*" "%RELEASE_DIR%\data\font\" >nul 2>nul
    echo    + Copied font files
)

REM Particle files
if exist "%PROJECT_DIR%\data\particle" (
    xcopy /Y /E /Q "%PROJECT_DIR%\data\particle\*" "%RELEASE_DIR%\data\particle\" >nul 2>nul
    echo    + Copied particle files
)

REM Misc files (helper shapes, etc.)
if exist "%PROJECT_DIR%\data\misc" (
    xcopy /Y /E /Q "%PROJECT_DIR%\data\misc\*" "%RELEASE_DIR%\data\misc\" >nul 2>nul
    echo    + Copied misc files
)

REM Smiley files
if exist "%PROJECT_DIR%\data\smiley" (
    xcopy /Y /E /Q "%PROJECT_DIR%\data\smiley\*" "%RELEASE_DIR%\data\smiley\" >nul 2>nul
    echo    + Copied smiley files
)

REM Sound files
if exist "%PROJECT_DIR%\data\sound" (
    xcopy /Y /E /Q "%PROJECT_DIR%\data\sound\*" "%RELEASE_DIR%\data\sound\" >nul 2>nul
    echo    + Copied sound files
)

echo.
set /a STEP+=1

:skip_server_setup

REM ============================================
REM SHARED SETUP (Both client and server need these)
REM ============================================

REM Copy dependency DLLs (Required for both client and server)
echo %STEP%. Copying dependency DLLs...

REM Determine base deps directory
set DEPS_BASE=
if defined TUXDEPS_PREFIX_PATH (
    if exist "%TUXDEPS_PREFIX_PATH%" set DEPS_BASE=%TUXDEPS_PREFIX_PATH%
)
if "%DEPS_BASE%"=="" (
    if exist "C:\tux_target_deps" set DEPS_BASE=C:\tux_target_deps
)

if "%DEPS_BASE%"=="" (
    echo    ! Warning: Dependency directory not found
    echo      Set TUXDEPS_PREFIX_PATH or ensure C:\tux_target_deps exists
    echo.
    set /a STEP+=1
    goto skip_deps_copy
)

echo    Using deps base: !DEPS_BASE!

REM Copy DLLs from individual library subdirectories
REM Core dependencies (needed by both client and server)
if exist "!DEPS_BASE!\lua\bin\lua.dll" (
    copy /Y "!DEPS_BASE!\lua\bin\lua.dll" "%RELEASE_DIR%\" >nul
    echo    + Copied: lua.dll
)
if exist "!DEPS_BASE!\zlib\bin\zlib.dll" (
    copy /Y "!DEPS_BASE!\zlib\bin\zlib.dll" "%RELEASE_DIR%\" >nul
    echo    + Copied: zlib.dll
)
if exist "!DEPS_BASE!\freetype\bin\freetype.dll" (
    copy /Y "!DEPS_BASE!\freetype\bin\freetype.dll" "%RELEASE_DIR%\" >nul
    echo    + Copied: freetype.dll
)
if exist "!DEPS_BASE!\libpng\bin\libpng16.dll" (
    copy /Y "!DEPS_BASE!\libpng\bin\libpng16.dll" "%RELEASE_DIR%\" >nul
    echo    + Copied: libpng16.dll
)
if exist "!DEPS_BASE!\libjpeg\bin\jpeg62.dll" (
    copy /Y "!DEPS_BASE!\libjpeg\bin\jpeg62.dll" "%RELEASE_DIR%\" >nul
    echo    + Copied: jpeg62.dll
)

REM Client-specific dependencies (graphics, audio, networking libraries)
if %SERVER_ONLY%==0 (
    if exist "!DEPS_BASE!\libxml2\bin\libxml2.dll" (
        copy /Y "!DEPS_BASE!\libxml2\bin\libxml2.dll" "%RELEASE_DIR%\" >nul
        echo    + Copied: libxml2.dll
    )
    if exist "!DEPS_BASE!\curl\bin\libcurl.dll" (
        copy /Y "!DEPS_BASE!\curl\bin\libcurl.dll" "%RELEASE_DIR%\" >nul
        echo    + Copied: libcurl.dll
    )
    if exist "!DEPS_BASE!\vorbis\bin\vorbisfile.dll" (
        copy /Y "!DEPS_BASE!\vorbis\bin\vorbisfile.dll" "%RELEASE_DIR%\" >nul
        echo    + Copied: vorbisfile.dll
    )
    if exist "!DEPS_BASE!\vorbis\bin\vorbis.dll" (
        copy /Y "!DEPS_BASE!\vorbis\bin\vorbis.dll" "%RELEASE_DIR%\" >nul
        echo    + Copied: vorbis.dll
    )
    if exist "!DEPS_BASE!\ogg\bin\ogg.dll" (
        copy /Y "!DEPS_BASE!\ogg\bin\ogg.dll" "%RELEASE_DIR%\" >nul
        echo    + Copied: ogg.dll
    )
    if exist "!DEPS_BASE!\openal-soft\bin\OpenAL32.dll" (
        copy /Y "!DEPS_BASE!\openal-soft\bin\OpenAL32.dll" "%RELEASE_DIR%\" >nul
        echo    + Copied: OpenAL32.dll
    )
    if exist "!DEPS_BASE!\openssl\bin\libcrypto-1_1-x64.dll" (
        copy /Y "!DEPS_BASE!\openssl\bin\libcrypto-1_1-x64.dll" "%RELEASE_DIR%\" >nul
        echo    + Copied: libcrypto-1_1-x64.dll
    )
    if exist "!DEPS_BASE!\openssl\bin\libssl-1_1-x64.dll" (
        copy /Y "!DEPS_BASE!\openssl\bin\libssl-1_1-x64.dll" "%RELEASE_DIR%\" >nul
        echo    + Copied: libssl-1_1-x64.dll
    )
)

echo.
set /a STEP+=1

:skip_deps_copy

REM Level files (Shared)
echo %STEP%. Copying level files...
if not exist "%RELEASE_DIR%\data\level" mkdir "%RELEASE_DIR%\data\level"
if exist "%PROJECT_DIR%\data\level" (
    copy /Y "%PROJECT_DIR%\data\level\*.lua" "%RELEASE_DIR%\data\level\" >nul 2>nul
    for /f %%a in ('dir /b "%RELEASE_DIR%\data\level\*.lua" 2^>nul ^| find /c /v ""') do set LEVEL_COUNT=%%a
    echo    + Copied !LEVEL_COUNT! level files
) else (
    echo    ! Warning: Level files not found
)
echo.
set /a STEP+=1

REM Skybox (Shared)
echo %STEP%. Copying skybox...
if not exist "%RELEASE_DIR%\data\shape" mkdir "%RELEASE_DIR%\data\shape"
if exist "%PROJECT_DIR%\data\shape\sky.shape" (
    copy /Y "%PROJECT_DIR%\data\shape\sky.shape" "%RELEASE_DIR%\data\shape\" >nul
    echo    + Copied: sky.shape (snow variant)
) else (
    echo    ! Warning: Corrected skybox not found
)
echo.
set /a STEP+=1

REM ============================================
REM VERIFICATION
REM ============================================
echo %STEP%. Verifying executables...
if %SERVER_ONLY%==0 (
    if exist "%RELEASE_DIR%\tux-target.exe" (
        echo    + Client: tux-target.exe
    ) else (
        echo    ! Client executable not found
    )
)

if %CLIENT_ONLY%==0 (
    if exist "%RELEASE_DIR%\tux-target-srv.exe" (
        echo    + Server: tux-target-srv.exe
    ) else (
        echo    ! Server executable not found
    )
)
echo.

REM ============================================
REM SUMMARY
REM ============================================
echo =========================================
echo Post-Build Setup Complete! (%MODE%)
echo =========================================
echo.
echo Build directory: %RELEASE_DIR%
echo.

if %SERVER_ONLY%==0 (
    echo To run the client:
    echo   cd %RELEASE_DIR%
    echo   tux-target.exe
    echo   Or: scripts\run-client.bat
    echo.
)

if %CLIENT_ONLY%==0 (
    echo To run the server:
    echo   cd %RELEASE_DIR%
    echo   tux-target-srv.exe
    echo   Or: scripts\run-server.bat
    echo.
)

echo For troubleshooting, see: docs\RUNTIME_FIXES.md

endlocal

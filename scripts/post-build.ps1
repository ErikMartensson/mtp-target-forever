#
# MTP Target Forever Post-Build Script (PowerShell)
#
# Copies all required runtime files to the build directory after compiling.
# Used by both local builds and CI.
#
# Usage:
#   .\scripts\post-build.ps1 -BuildType Client
#   .\scripts\post-build.ps1 -BuildType Server
#   .\scripts\post-build.ps1 -BuildType Both
#
# Parameters:
#   -BuildType      Client, Server, or Both (default: Both)
#   -BuildDir       Override default build output directory
#   -DepsDir        Path to dependencies (default: from deps-manifest.ps1)
#   -RyzomCoreDir   Path to RyzomCore build (default: C:\ryzomcore)
#   -UseNinjaPaths  Use Ninja output paths (bin/ instead of bin/Release/)
#

param(
    [ValidateSet("Client", "Server", "Both")]
    [string]$BuildType = "Both",

    [string]$BuildDir = $null,
    [string]$DepsDir = $null,
    [string]$RyzomCoreDir = "C:\ryzomcore",
    [switch]$UseNinjaPaths
)

$ErrorActionPreference = "Stop"

# Load manifests
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$scriptDir/deps-manifest.ps1"
. "$scriptDir/assets-manifest.ps1"

# Determine paths
$repoRoot = Get-RepoRoot
if (!$DepsDir) {
    $DepsDir = Get-DepsPath
}

# Determine RyzomCore driver paths
if ($UseNinjaPaths) {
    $nelDriverPath = "$RyzomCoreDir/build/bin"
} else {
    $nelDriverPath = "$RyzomCoreDir/build/bin/Release"
}

Write-Host "==========================================="
Write-Host "  MTP Target Forever Post-Build Setup"
Write-Host "==========================================="
Write-Host ""
Write-Host "Build type: $BuildType"
Write-Host "Dependencies: $DepsDir"
Write-Host "RyzomCore: $RyzomCoreDir"
Write-Host "NeL drivers: $nelDriverPath"
Write-Host ""

function Copy-ClientFiles {
    param([string]$DestDir)

    Write-Host "=== Setting up Client ==="
    Write-Host "Destination: $DestDir"
    Write-Host ""

    # Ensure destination exists
    if (!(Test-Path $DestDir)) {
        New-Item -ItemType Directory -Force -Path $DestDir | Out-Null
    }

    # 1. Copy NeL driver DLLs
    Write-Host "1. Copying NeL driver DLLs..."
    $nelDrivers = @(
        "nel_drv_opengl_win_r.dll",
        "nel_drv_openal_win_r.dll"
    )
    foreach ($driver in $nelDrivers) {
        $src = "$nelDriverPath/$driver"
        if (Test-Path $src) {
            Copy-Item $src "$DestDir/" -Force
            Write-Host "   + $driver"
        } else {
            Write-Host "   ! Missing: $driver" -ForegroundColor Yellow
        }
    }
    Write-Host ""

    # 2. Copy runtime DLLs from dependencies
    Write-Host "2. Copying dependency DLLs..."
    $dlls = Get-RequiredDLLs
    foreach ($dll in $dlls) {
        $src = Join-Path $DepsDir $dll
        if (Test-Path $src) {
            $dllName = Split-Path -Leaf $dll
            Copy-Item $src "$DestDir/$dllName" -Force
            Write-Host "   + $dllName"
        } else {
            Write-Host "   ! Missing: $dll" -ForegroundColor Yellow
        }
    }
    Write-Host ""

    # 3. Copy game assets using manifest
    Write-Host "3. Copying game assets..."
    $dataDir = "$DestDir/data"
    $srcDataDir = Join-Path $repoRoot "data"
    Copy-ClientAssets -DataPath $srcDataDir -DestPath $dataDir
    Write-Host ""

    # 4. Copy fonts from RyzomCore samples
    Write-Host "4. Copying RyzomCore sample fonts..."
    $fontDir = "$DestDir/data/font"
    if (!(Test-Path $fontDir)) {
        New-Item -ItemType Directory -Force -Path $fontDir | Out-Null
    }

    $pfbPath = "$RyzomCoreDir/nel/samples/3d/cegui/datafiles/n019003l.pfb"
    if (Test-Path $pfbPath) {
        Copy-Item $pfbPath "$fontDir/" -Force
        Write-Host "   + n019003l.pfb"
    }

    $ttfPath = "$RyzomCoreDir/nel/samples/3d/font/beteckna.ttf"
    if (Test-Path $ttfPath) {
        Copy-Item $ttfPath "$fontDir/bigfont.ttf" -Force
        Write-Host "   + bigfont.ttf (from beteckna.ttf)"
    }
    Write-Host ""

    # 5. Copy GUI files
    Write-Host "5. Copying GUI files..."
    $guiDir = "$DestDir/data/gui"
    if (!(Test-Path $guiDir)) {
        New-Item -ItemType Directory -Force -Path $guiDir | Out-Null
    }

    $clientGuiDir = "$repoRoot/client/data/gui"
    if (Test-Path $clientGuiDir) {
        Copy-Item -Path "$clientGuiDir/*" -Destination $guiDir -Recurse -Force
        Write-Host "   + Copied v1.2.2a GUI files"
    }
    Write-Host ""

    # 6. Copy and create config files
    Write-Host "6. Setting up config files..."
    $configSrc = "$repoRoot/data/config/mtp_target_default.cfg"
    if (Test-Path $configSrc) {
        Copy-Item $configSrc "$DestDir/" -Force
        Write-Host "   + mtp_target_default.cfg"
    } elseif (Test-Path "$repoRoot/client/mtp_target_default.cfg") {
        Copy-Item "$repoRoot/client/mtp_target_default.cfg" "$DestDir/" -Force
        Write-Host "   + mtp_target_default.cfg (from client/)"
    }

    # Create mtp-target.cfg wrapper if needed
    $wrapperCfg = "$DestDir/mtp-target.cfg"
    if (!(Test-Path $wrapperCfg)) {
        @"
// This file tells the client where to find the main config
RootConfigFilename = "mtp_target_default.cfg";
"@ | Set-Content $wrapperCfg
        Write-Host "   + Created mtp-target.cfg"
    }
    Write-Host ""

    # 7. Create additional directories
    Write-Host "7. Creating additional directories..."
    @("cache", "replay", "logs") | ForEach-Object {
        $dir = "$DestDir/$_"
        if (!(Test-Path $dir)) {
            New-Item -ItemType Directory -Force -Path $dir | Out-Null
        }
    }
    Write-Host "   + cache/, replay/, logs/"
    Write-Host ""

    Write-Host "Client setup complete!" -ForegroundColor Green
    Write-Host ""
}

function Copy-ServerFiles {
    param([string]$DestDir)

    Write-Host "=== Setting up Server ==="
    Write-Host "Destination: $DestDir"
    Write-Host ""

    # Ensure destination exists
    if (!(Test-Path $DestDir)) {
        New-Item -ItemType Directory -Force -Path $DestDir | Out-Null
    }

    # 1. Copy server-specific runtime DLLs
    Write-Host "1. Copying server dependency DLLs..."
    # Server needs fewer DLLs (no audio/graphics)
    $serverDlls = @(
        "lua/bin/lua.dll",
        "zlib/bin/zlib.dll",
        "freetype/bin/freetype.dll",
        "libpng/bin/libpng16.dll",
        "libjpeg/bin/jpeg62.dll"
    )
    foreach ($dll in $serverDlls) {
        $src = Join-Path $DepsDir $dll
        if (Test-Path $src) {
            $dllName = Split-Path -Leaf $dll
            Copy-Item $src "$DestDir/$dllName" -Force
            Write-Host "   + $dllName"
        } else {
            Write-Host "   ! Missing: $dll" -ForegroundColor Yellow
        }
    }
    Write-Host ""

    # 2. Copy game assets using manifest
    Write-Host "2. Copying game assets..."
    $dataDir = "$DestDir/data"
    $srcDataDir = Join-Path $repoRoot "data"
    Copy-ServerAssets -DataPath $srcDataDir -DestPath $dataDir
    Write-Host ""

    # 3. Copy helpers.lua
    Write-Host "3. Copying helpers.lua..."
    $helpersPath = "$repoRoot/server/data/misc/helpers.lua"
    if (Test-Path $helpersPath) {
        Copy-Item $helpersPath "$DestDir/data/" -Force
        Write-Host "   + helpers.lua"
    } else {
        Write-Host "   ! helpers.lua not found" -ForegroundColor Yellow
    }
    Write-Host ""

    # 4. Copy server config
    Write-Host "4. Setting up server config..."
    $serverCfgDest = "$DestDir/mtp_target_service.cfg"
    if (!(Test-Path $serverCfgDest)) {
        $serverCfgSrc = "$repoRoot/server/mtp_target_service_default.cfg"
        if (Test-Path $serverCfgSrc) {
            Copy-Item $serverCfgSrc $serverCfgDest -Force
            Write-Host "   + mtp_target_service.cfg"
        }
    } else {
        Write-Host "   + Server config already exists"
    }
    Write-Host ""

    # 5. Create additional directories
    Write-Host "5. Creating additional directories..."
    @("logs") | ForEach-Object {
        $dir = "$DestDir/$_"
        if (!(Test-Path $dir)) {
            New-Item -ItemType Directory -Force -Path $dir | Out-Null
        }
    }
    Write-Host "   + logs/"
    Write-Host ""

    Write-Host "Server setup complete!" -ForegroundColor Green
    Write-Host ""
}

# Main execution
if ($BuildType -eq "Client" -or $BuildType -eq "Both") {
    if ($BuildDir) {
        $clientDir = $BuildDir
    } else {
        # Default: Ninja outputs to bin/, VS outputs to bin/Release/
        $clientDir = "$repoRoot/build-client/bin"
        if (!(Test-Path "$clientDir/mtp-target-forever.exe") -and (Test-Path "$repoRoot/build-client/bin/Release/mtp-target-forever.exe")) {
            $clientDir = "$repoRoot/build-client/bin/Release"
        }
    }
    Copy-ClientFiles -DestDir $clientDir
}

if ($BuildType -eq "Server" -or $BuildType -eq "Both") {
    if ($BuildDir) {
        $serverDir = $BuildDir
    } else {
        # Default: Ninja outputs to bin/, VS outputs to bin/Release/
        $serverDir = "$repoRoot/build-server/bin"
        if (!(Test-Path "$serverDir/mtp-target-forever-srv.exe") -and (Test-Path "$repoRoot/build-server/bin/Release/mtp-target-forever-srv.exe")) {
            $serverDir = "$repoRoot/build-server/bin/Release"
        }
    }
    Copy-ServerFiles -DestDir $serverDir
}

Write-Host "==========================================="
Write-Host "  Post-Build Setup Complete!"
Write-Host "==========================================="

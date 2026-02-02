#
# MTP Target Forever RyzomCore/NeL Setup
#
# Clones and builds the RyzomCore NeL libraries required for MTP Target Forever.
# Uses Ninja for fast builds and consistent output paths.
#
# Usage:
#   .\scripts\setup-ryzomcore.ps1              # Build to ./ryzomcore/
#   .\scripts\setup-ryzomcore.ps1 -Force       # Re-clone and rebuild
#   .\scripts\setup-ryzomcore.ps1 -BuildOnly   # Rebuild without re-cloning
#
# Prerequisites:
#   - Visual Studio 2022 Build Tools (for MSVC compiler)
#   - CMake 3.20+
#   - Ninja (install via: choco install ninja)
#   - Dependencies installed (run setup-deps.ps1 first)
#

param(
    [string]$RyzomCorePath = $null,
    [switch]$Force,
    [switch]$BuildOnly,
    [switch]$SkipDrivers
)

$ErrorActionPreference = "Stop"

# Load deps manifest to get paths
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$scriptDir/deps-manifest.ps1"

$repoRoot = Get-RepoRoot
$depsPath = Get-DepsPath

# Default RyzomCore path
if (!$RyzomCorePath) {
    $RyzomCorePath = Join-Path $repoRoot "ryzomcore"
}

$buildPath = Join-Path $RyzomCorePath "build"

Write-Host "==========================================="
Write-Host "  MTP Target Forever RyzomCore/NeL Setup"
Write-Host "==========================================="
Write-Host ""
Write-Host "RyzomCore path: $RyzomCorePath"
Write-Host "Dependencies:   $depsPath"
Write-Host ""

# Check prerequisites
Write-Host "=== Checking prerequisites ==="
Write-Host ""

# Check for Ninja
$ninjaPath = (Get-Command ninja -ErrorAction SilentlyContinue).Source
if (!$ninjaPath) {
    Write-Error "Ninja not found. Install it with: choco install ninja"
    exit 1
}
Write-Host "[OK] Ninja: $ninjaPath"

# Check for CMake
$cmakePath = (Get-Command cmake -ErrorAction SilentlyContinue).Source
if (!$cmakePath) {
    Write-Error "CMake not found. Install CMake 3.20+ and add to PATH."
    exit 1
}
Write-Host "[OK] CMake: $cmakePath"

# Check for cl.exe (MSVC compiler) - set up environment if needed
$clPath = (Get-Command cl -ErrorAction SilentlyContinue).Source
if (!$clPath) {
    Write-Host "MSVC compiler not in PATH, searching for Visual Studio..." -ForegroundColor Yellow

    # Find VS installation using vswhere
    $vswherePaths = @(
        "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe",
        "${env:ProgramFiles}\Microsoft Visual Studio\Installer\vswhere.exe"
    )
    $vswhere = $vswherePaths | Where-Object { Test-Path $_ } | Select-Object -First 1

    if ($vswhere) {
        $vsPath = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
        if ($vsPath) {
            $vcvarsPath = Join-Path $vsPath "VC\Auxiliary\Build\vcvars64.bat"
            if (Test-Path $vcvarsPath) {
                Write-Host "Found Visual Studio at: $vsPath"
                Write-Host "Setting up MSVC environment..."

                # Run vcvars64.bat and capture environment changes
                $envBefore = @{}
                Get-ChildItem env: | ForEach-Object { $envBefore[$_.Name] = $_.Value }

                cmd /c "`"$vcvarsPath`" && set" | ForEach-Object {
                    if ($_ -match "^([^=]+)=(.*)$") {
                        $name = $matches[1]
                        $value = $matches[2]
                        if ($envBefore[$name] -ne $value) {
                            Set-Item -Path "env:$name" -Value $value
                        }
                    }
                }

                $clPath = (Get-Command cl -ErrorAction SilentlyContinue).Source
            }
        }
    }

    if (!$clPath) {
        Write-Host ""
        Write-Host "Could not find or set up MSVC compiler." -ForegroundColor Red
        Write-Host "Please install Visual Studio 2022 Build Tools with C++ workload."
        Write-Host "Download from: https://visualstudio.microsoft.com/downloads/"
        Write-Error "MSVC compiler not found"
        exit 1
    }
}
Write-Host "[OK] MSVC:  $clPath"

# Check dependencies are installed (verify lua.lib exists as a proxy for all deps)
if (!(Test-Path "$depsPath/lua/lib/lua.lib") -and !(Test-Path "$depsPath/lua/lib/lua51.lib")) {
    Write-Error "Dependencies not found at $depsPath. Run setup-deps.ps1 first."
    exit 1
}
Write-Host "[OK] Dependencies installed"
Write-Host ""

# Clone RyzomCore if needed
if (!$BuildOnly) {
    if ((Test-Path $RyzomCorePath) -and !$Force) {
        Write-Host "RyzomCore already exists at $RyzomCorePath"
        Write-Host "Use -Force to re-clone, or -BuildOnly to just rebuild."
        Write-Host ""
    } else {
        if (Test-Path $RyzomCorePath) {
            Write-Host "Removing existing RyzomCore directory..."
            Remove-Item -Recurse -Force $RyzomCorePath
        }

        Write-Host "=== Cloning RyzomCore ==="
        Write-Host ""
        git clone --depth 1 https://github.com/ryzom/ryzomcore.git $RyzomCorePath
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to clone RyzomCore"
            exit 1
        }
        Write-Host ""
    }
}

# Patch RyzomCore CMakeLists.txt for CMake 3.24+ compatibility
# The INTERFACE_LINK_LIBRARIES property no longer accepts "optimized"/"debug" keywords
Write-Host "=== Patching RyzomCore for CMake compatibility ==="
$cmakeFile = Join-Path $RyzomCorePath "CMakeLists.txt"
$content = Get-Content $cmakeFile -Raw

# CMake's FindOpenSSL sets OPENSSL_SSL_LIBRARY with "optimized;lib;debug;libd" format
# which is incompatible with INTERFACE_LINK_LIBRARIES in CMake 3.24+
# We add code after FIND_PACKAGE(OpenSSL) to force the release-only library paths

$findOpenSSLPattern = 'FIND_PACKAGE\(OpenSSL REQUIRED\)'
$replacement = @"
FIND_PACKAGE(OpenSSL REQUIRED)

# CMake 3.24+ fix: Force release-only library paths
# The optimized/debug keywords are not allowed in INTERFACE_LINK_LIBRARIES
GET_FILENAME_COMPONENT(_OPENSSL_DIR "`${OPENSSL_INCLUDE_DIR}" DIRECTORY)
SET(OPENSSL_SSL_LIBRARY "`${_OPENSSL_DIR}/lib/VC/libssl64MD.lib")
SET(OPENSSL_CRYPTO_LIBRARY "`${_OPENSSL_DIR}/lib/VC/libcrypto64MD.lib")
SET(OPENSSL_LIBRARIES "`${OPENSSL_SSL_LIBRARY};`${OPENSSL_CRYPTO_LIBRARY}")
"@

$content = $content -replace $findOpenSSLPattern, $replacement
Set-Content $cmakeFile $content
Write-Host "[OK] Patched CMakeLists.txt"
Write-Host ""

# Create build directory
if (!(Test-Path $buildPath)) {
    New-Item -ItemType Directory -Force -Path $buildPath | Out-Null
}

# Build CMAKE_PREFIX_PATH
$cmakePrefixPath = @(
    "$depsPath/zlib",
    "$depsPath/libpng",
    "$depsPath/libjpeg",
    "$depsPath/curl",
    "$depsPath/openssl",
    "$depsPath/freetype",
    "$depsPath/ogg",
    "$depsPath/vorbis",
    "$depsPath/openal-soft",
    "$depsPath/boost",
    "$depsPath/lua",
    "$depsPath/luabind",
    "$depsPath/libxml2"
) -join ";"

Write-Host "=== Configuring RyzomCore ==="
Write-Host ""

Push-Location $buildPath
try {
    # Configure with CMake using Ninja
    cmake .. -G Ninja `
        -DCMAKE_MAKE_PROGRAM="$ninjaPath" `
        -DCMAKE_C_COMPILER="$clPath" `
        -DCMAKE_CXX_COMPILER="$clPath" `
        -DCMAKE_BUILD_TYPE=Release `
        -DWITH_SOUND=ON `
        -DWITH_NEL=ON `
        -DWITH_NEL_TOOLS=OFF `
        -DWITH_NEL_TESTS=OFF `
        -DWITH_NEL_SAMPLES=OFF `
        -DWITH_RYZOM=OFF `
        -DWITH_RYZOM_CLIENT=OFF `
        -DWITH_RYZOM_SERVER=OFF `
        -DWITH_RYZOM_TOOLS=OFF `
        -DWITH_NELNS=OFF `
        -DWITH_SNOWBALLS=OFF `
        -DWITH_STATIC=ON `
        -DWITH_STATIC_LIBXML2=OFF `
        -DLIBXML2_DEFINITIONS="" `
        "-DCMAKE_PREFIX_PATH=$cmakePrefixPath" `
        -DLUA_INCLUDE_DIR="$depsPath/lua/include" `
        -DLUA_LIBRARIES="$depsPath/lua/lib/lua51.lib" `
        -DLUABIND_INCLUDE_DIR="$depsPath/luabind/include" `
        -DLUABIND_LIBRARY="$depsPath/luabind/lib/luabind.lib" `
        -DLUABIND_LIBRARIES="$depsPath/luabind/lib/luabind.lib" `
        -DLIBXML2_INCLUDE_DIR="$depsPath/libxml2/include/libxml2" `
        -DLIBXML2_LIBRARY="$depsPath/libxml2/lib/libxml2.lib" `
        -DLIBXML2_LIBRARIES="$depsPath/libxml2/lib/libxml2.lib" `
        -DZLIB_INCLUDE_DIR="$depsPath/zlib/include" `
        -DZLIB_LIBRARIES="$depsPath/zlib/lib/zlib.lib" `
        -DZLIB_LIBRARY="$depsPath/zlib/lib/zlib.lib" `
        -DPNG_PNG_INCLUDE_DIR="$depsPath/libpng/include" `
        -DPNG_LIBRARY="$depsPath/libpng/lib/libpng16.lib" `
        -DJPEG_INCLUDE_DIR="$depsPath/libjpeg/include" `
        -DJPEG_LIBRARY="$depsPath/libjpeg/lib/jpeg.lib" `
        -DFREETYPE_INCLUDE_DIRS="$depsPath/freetype/include/freetype2" `
        -DFREETYPE_LIBRARY="$depsPath/freetype/lib/freetype.lib" `
        -DOPENAL_INCLUDE_DIR="$depsPath/openal-soft/include" `
        -DOPENAL_LIBRARY="$depsPath/openal-soft/lib/OpenAL32.lib" `
        -DOGG_INCLUDE_DIR="$depsPath/ogg/include" `
        -DOGG_LIBRARY="$depsPath/ogg/lib/ogg.lib" `
        -DVORBIS_INCLUDE_DIR="$depsPath/vorbis/include" `
        -DVORBIS_LIBRARY="$depsPath/vorbis/lib/vorbis.lib" `
        -DVORBISFILE_LIBRARY="$depsPath/vorbis/lib/vorbisfile.lib" `
        -DBoost_INCLUDE_DIR="$depsPath/boost/include" `
        -DCURL_INCLUDE_DIR="$depsPath/curl/include" `
        -DCURL_LIBRARY="$depsPath/curl/lib/libcurl_imp.lib" `
        -DOPENSSL_ROOT_DIR="$depsPath/openssl" `
        -DOPENSSL_INCLUDE_DIR="$depsPath/openssl/include" `
        -DOPENSSL_CRYPTO_LIBRARY="$depsPath/openssl/lib/VC/libcrypto64MD.lib" `
        -DOPENSSL_SSL_LIBRARY="$depsPath/openssl/lib/VC/libssl64MD.lib" `
        -DOPENSSL_LIBRARIES="$depsPath/openssl/lib/VC/libcrypto64MD.lib;$depsPath/openssl/lib/VC/libssl64MD.lib" `
        -DCMAKE_POLICY_DEFAULT_CMP0111=OLD `
        -DCMAKE_FIND_USE_SYSTEM_ENVIRONMENT_PATH=FALSE

    if ($LASTEXITCODE -ne 0) {
        Write-Error "CMake configuration failed"
        exit 1
    }

    Write-Host ""
    Write-Host "=== Building NeL Libraries ==="
    Write-Host ""

    # Build core NeL libraries
    cmake --build . --parallel 4 --target nelmisc nelnet nel3d nelsound nelsnd_lowlevel nelgeorges nelligo
    if ($LASTEXITCODE -ne 0) {
        Write-Error "NeL library build failed"
        exit 1
    }

    # Build drivers (OpenGL, OpenAL)
    if (!$SkipDrivers) {
        Write-Host ""
        Write-Host "=== Building NeL Drivers ==="
        Write-Host ""
        cmake --build . --parallel 2 --target nel_drv_opengl_win nel_drv_openal_win
        if ($LASTEXITCODE -ne 0) {
            Write-Error "NeL driver build failed"
            exit 1
        }
    }

} finally {
    Pop-Location
}

# Verify build
Write-Host ""
Write-Host "=== Verifying Build ==="
Write-Host ""

$requiredFiles = @(
    "$buildPath/lib/nelmisc_r.lib",
    "$buildPath/lib/nel3d_r.lib",
    "$buildPath/lib/nelnet_r.lib",
    "$buildPath/lib/nelsound_r.lib",
    "$buildPath/lib/nelsnd_lowlevel_r.lib",
    "$buildPath/lib/nelgeorges_r.lib",
    "$buildPath/lib/nelligo_r.lib"
)

if (!$SkipDrivers) {
    $requiredFiles += @(
        "$buildPath/bin/nel_drv_opengl_win_r.dll",
        "$buildPath/bin/nel_drv_openal_win_r.dll"
    )
}

$missing = @()
foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "[OK] $(Split-Path -Leaf $file)"
    } else {
        $missing += $file
        Write-Host "[MISSING] $file" -ForegroundColor Red
    }
}

if ($missing.Count -gt 0) {
    Write-Error "Build incomplete - $($missing.Count) files missing"
    exit 1
}

Write-Host ""
Write-Host "==========================================="
Write-Host "  RyzomCore/NeL Build Complete!"
Write-Host "==========================================="
Write-Host ""
Write-Host "Libraries: $buildPath/lib/"
Write-Host "Drivers:   $buildPath/bin/"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  .\scripts\build-client.bat"
Write-Host "  .\scripts\build-server.bat"
Write-Host ""

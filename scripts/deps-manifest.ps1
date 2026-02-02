#
# MTP Target Forever Dependencies Manifest
#
# This is the single source of truth for all required dependency files.
# Used by: setup-deps.ps1, build.yml (CI), build scripts
#

# Default installation path: deps/ directory inside repo (can be overridden via $env:MTPDEPS_PATH or $env:TUXDEPS_PATH)
# Determine repo root from script location
$script:ScriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$script:RepoRoot = Split-Path -Parent $script:ScriptRoot
$script:DefaultDepsPath = Join-Path $script:RepoRoot "deps"

function Get-DepsPath {
    # Check new env var first, fall back to old
    if ($env:MTPDEPS_PATH) {
        return $env:MTPDEPS_PATH
    } elseif ($env:TUXDEPS_PATH) {
        return $env:TUXDEPS_PATH
    }
    return $script:DefaultDepsPath
}

function Get-RepoRoot {
    return $script:RepoRoot
}

# Required library files (.lib) for linking
$script:RequiredLibs = @(
    # Core libraries
    "libxml2/lib/libxml2.lib",
    "zlib/lib/zlib.lib",
    "lua/lib/lua.lib",
    "luabind/lib/luabind.lib",
    # Networking
    "curl/lib/libcurl_imp.lib",
    "openssl/lib/VC/libcrypto64MD.lib",
    "openssl/lib/VC/libssl64MD.lib",
    # Graphics
    "freetype/lib/freetype.lib",
    "libpng/lib/libpng16.lib",
    "libjpeg/lib/jpeg.lib",
    # Audio
    "ogg/lib/ogg.lib",
    "vorbis/lib/vorbis.lib",
    "vorbis/lib/vorbisfile.lib",
    "openal-soft/lib/OpenAL32.lib"
)

# Required DLL files for runtime
$script:RequiredDLLs = @(
    "lua/bin/lua.dll",
    "libxml2/bin/libxml2.dll",
    "zlib/bin/zlib.dll",
    "curl/bin/libcurl.dll",
    "openssl/bin/libcrypto-1_1-x64.dll",
    "openssl/bin/libssl-1_1-x64.dll",
    "freetype/bin/freetype.dll",
    "libpng/bin/libpng16.dll",
    "libjpeg/bin/jpeg62.dll",
    "ogg/bin/ogg.dll",
    "vorbis/bin/vorbis.dll",
    "vorbis/bin/vorbisfile.dll",
    "openal-soft/bin/OpenAL32.dll"
)

# Required header files (spot-check to verify include dirs)
$script:RequiredHeaders = @(
    "libxml2/include/libxml2/libxml/xmlversion.h",
    "lua/include/lua.h",
    "luabind/include/luabind/luabind.hpp",
    "curl/include/curl/curl.h",
    "openssl/include/openssl/ssl.h",
    "zlib/include/zlib.h",
    "freetype/include/freetype2/ft2build.h",
    "libpng/include/png.h",
    "libjpeg/include/jpeglib.h",
    "ogg/include/ogg/ogg.h",
    "vorbis/include/vorbis/vorbisfile.h",
    "openal-soft/include/AL/al.h",
    "boost/include/boost/version.hpp"
)

# Server-specific: ODE physics library
$script:ServerLibs = @(
    "ode/lib/ode_doubles.lib"
)

# Libraries NOT needed by MTP Target Forever (can be removed to save ~3.4GB)
# These are part of the Ryzom external package but unused by this project
$script:UnusedLibraries = @(
    "assimp",           # 3D model importer (25MB)
    "cegui",            # GUI library (47MB)
    "ffmpeg",           # Video encoding (120MB)
    "gl",               # OpenGL headers (1.3MB) - come with Windows SDK
    "gles",             # OpenGL ES (680KB)
    "mariadb-connector-c",  # Database (1.7MB)
    "msquic",           # QUIC protocol (528KB)
    "protobuf",         # Protocol buffers (240MB)
    "python310",        # Python (109MB)
    "qt5",              # Qt5 (634MB)
    "qt5_static",       # Qt5 static (621MB)
    "qt6",              # Qt6 (904MB)
    "qt6_static",       # Qt6 static (724MB)
    "squish",           # Texture compression (564KB)
    "tinycc"            # Tiny C compiler (2.1MB)
)

$script:ServerHeaders = @(
    "ode/include/ode/ode.h"
)

# Client-specific DLLs (audio, graphics)
$script:ClientDLLs = @(
    "openal-soft/bin/OpenAL32.dll",
    "vorbis/bin/vorbis.dll",
    "vorbis/bin/vorbisfile.dll",
    "ogg/bin/ogg.dll"
)

function Get-RequiredLibs { return $script:RequiredLibs }
function Get-RequiredDLLs { return $script:RequiredDLLs }
function Get-RequiredHeaders { return $script:RequiredHeaders }
function Get-ServerLibs { return $script:ServerLibs }
function Get-ServerHeaders { return $script:ServerHeaders }
function Get-ClientDLLs { return $script:ClientDLLs }
function Get-UnusedLibraries { return $script:UnusedLibraries }

function Get-AllRequiredFiles {
    return $script:RequiredLibs + $script:RequiredDLLs + $script:RequiredHeaders
}

function Test-DepsInstalled {
    param(
        [string]$DepsPath = (Get-DepsPath),
        [switch]$IncludeServer,
        [switch]$Quiet
    )

    $allFiles = Get-AllRequiredFiles
    if ($IncludeServer) {
        $allFiles += $script:ServerLibs + $script:ServerHeaders
    }

    $missing = @()
    foreach ($file in $allFiles) {
        $fullPath = Join-Path $DepsPath $file
        if (!(Test-Path $fullPath)) {
            $missing += $file
            if (!$Quiet) {
                Write-Host "[MISSING] $file" -ForegroundColor Red
            }
        } elseif (!$Quiet) {
            Write-Host "[OK] $file" -ForegroundColor Green
        }
    }

    if ($missing.Count -gt 0) {
        if (!$Quiet) {
            Write-Host "`nMissing $($missing.Count) required files!" -ForegroundColor Red
        }
        return $false
    }

    if (!$Quiet) {
        Write-Host "`nAll $($allFiles.Count) required files present" -ForegroundColor Green
    }
    return $true
}

# Export functions if used as module (only works when imported as module, not dot-sourced)
try {
    Export-ModuleMember -Function Get-DepsPath, Get-RepoRoot, Get-RequiredLibs, Get-RequiredDLLs, Get-RequiredHeaders, Get-ServerLibs, Get-ServerHeaders, Get-ClientDLLs, Get-UnusedLibraries, Get-AllRequiredFiles, Test-DepsInstalled
} catch {
    # Silently ignore - this is expected when dot-sourced instead of imported as module
}

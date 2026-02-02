#
# MTP Target Forever CMake Configuration
#
# Single source of truth for CMake variables used by both local builds and CI.
# This ensures consistent paths between environments.
#
# Usage (PowerShell):
#   . .\scripts\cmake-config.ps1
#   $args = Get-ClientCMakeArgs -Deps "C:/external" -Nel "C:/ryzomcore/build"
#   cmake .. -G Ninja @args
#
# Usage (from batch file):
#   for /f "delims=" %%a in ('powershell -File scripts\cmake-config.ps1 -OutputArgs Client -DepsPath "%DEPS_PATH%" -NelPath "%NEL_PATH%"') do set CMAKE_ARGS=%%a
#   cmake .. %CMAKE_ARGS%
#

param(
    [string]$DepsPath = $null,
    [string]$NelPath = $null,
    [ValidateSet("", "Client", "Server")]
    [string]$OutputArgs = ""
)

# Load manifest for path defaults
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$scriptDir/deps-manifest.ps1"

# Determine paths
if (!$DepsPath) {
    $DepsPath = Get-DepsPath
}
if (!$NelPath) {
    $NelPath = if ($env:NEL_PREFIX_PATH) { $env:NEL_PREFIX_PATH } else { Join-Path (Get-RepoRoot) "ryzomcore/build" }
}

# Normalize paths (forward slashes for CMake)
$DepsPath = $DepsPath -replace '\\', '/'
$NelPath = $NelPath -replace '\\', '/'

function Get-CommonCMakeArgs {
    param([string]$Deps = $script:DepsPath, [string]$Nel = $script:NelPath)

    return @(
        "-DNEL_PREFIX_PATH=$Nel",
        "-DCMAKE_PREFIX_PATH=$Deps",
        "-DLUA_INCLUDE_DIR:PATH=$Deps/lua/include",
        "-DLUA_LIBRARIES:FILEPATH=$Deps/lua/lib/lua.lib",
        "-DLIBXML2_INCLUDE_DIR:PATH=$Deps/libxml2/include/libxml2",
        "-DLIBXML2_LIBRARY:FILEPATH=$Deps/libxml2/lib/libxml2.lib",
        "-DZLIB_ROOT=$Deps/zlib",
        "-DZLIB_LIBRARY:FILEPATH=$Deps/zlib/lib/zlib.lib",
        "-DFREETYPE_INCLUDE_DIRS:PATH=$Deps/freetype/include/freetype2",
        "-DFREETYPE_LIBRARY:FILEPATH=$Deps/freetype/lib/freetype.lib",
        "-DPNG_PNG_INCLUDE_DIR:PATH=$Deps/libpng/include",
        "-DPNG_LIBRARY:FILEPATH=$Deps/libpng/lib/libpng16.lib",
        "-DJPEG_INCLUDE_DIR:PATH=$Deps/libjpeg/include",
        "-DJPEG_LIBRARY:FILEPATH=$Deps/libjpeg/lib/jpeg.lib"
    )
}

function Get-ClientCMakeArgs {
    param([string]$Deps = $script:DepsPath, [string]$Nel = $script:NelPath)

    $common = Get-CommonCMakeArgs -Deps $Deps -Nel $Nel
    $client = @(
        "-DBUILD_CLIENT=ON",
        "-DBUILD_SERVER=OFF",
        "-DWITH_STATIC=ON",
        "-DWITH_STATIC_CURL=ON",
        "-DCURL_ROOT=$Deps/curl",
        "-DCURL_INCLUDE_DIR:PATH=$Deps/curl/include",
        "-DCURL_LIBRARY:FILEPATH=$Deps/curl/lib/libcurl_imp.lib",
        "-DCURL_LIBRARIES:FILEPATH=$Deps/curl/lib/libcurl_imp.lib",
        "-DOPENSSL_ROOT_DIR=$Deps/openssl",
        "-DVORBIS_LIBRARY:FILEPATH=$Deps/vorbis/lib/vorbis.lib",
        "-DVORBISFILE_LIBRARY:FILEPATH=$Deps/vorbis/lib/vorbisfile.lib",
        "-DOGG_LIBRARY:FILEPATH=$Deps/ogg/lib/ogg.lib"
    )

    return $common + $client
}

function Get-ServerCMakeArgs {
    param([string]$Deps = $script:DepsPath, [string]$Nel = $script:NelPath)

    $common = Get-CommonCMakeArgs -Deps $Deps -Nel $Nel
    $server = @(
        "-DBUILD_CLIENT=OFF",
        "-DBUILD_SERVER=ON",
        "-DODE_INCLUDE_DIR=$Deps/ode/include",
        "-DODE_LIBRARY=$Deps/ode/lib/ode_doubles.lib"
    )

    return $common + $server
}

# Convert args array to single-line string for batch file consumption
function Get-CMakeArgsString {
    param(
        [ValidateSet("Client", "Server")]
        [string]$BuildType,
        [string]$Deps = $script:DepsPath,
        [string]$Nel = $script:NelPath
    )

    if ($BuildType -eq "Client") {
        $args = Get-ClientCMakeArgs -Deps $Deps -Nel $Nel
    } else {
        $args = Get-ServerCMakeArgs -Deps $Deps -Nel $Nel
    }

    return ($args -join " ")
}

# If -OutputArgs is specified, print args string and exit (for batch file use)
if ($OutputArgs) {
    Get-CMakeArgsString -BuildType $OutputArgs -Deps $DepsPath -Nel $NelPath
    exit 0
}

# Print configuration when run directly without -OutputArgs
if ($MyInvocation.InvocationName -ne '.') {
    Write-Host "MTP Target Forever CMake Configuration"
    Write-Host "==============================="
    Write-Host ""
    Write-Host "Dependencies path: $DepsPath"
    Write-Host "NeL path: $NelPath"
    Write-Host ""
    Write-Host "Client CMake args:"
    Get-ClientCMakeArgs | ForEach-Object { Write-Host "  $_" }
    Write-Host ""
    Write-Host "Server CMake args:"
    Get-ServerCMakeArgs | ForEach-Object { Write-Host "  $_" }
}

# Export functions (for module use)
try {
    Export-ModuleMember -Function Get-CommonCMakeArgs, Get-ClientCMakeArgs, Get-ServerCMakeArgs, Get-CMakeArgsString -ErrorAction SilentlyContinue
} catch {
    # Expected when dot-sourced
}

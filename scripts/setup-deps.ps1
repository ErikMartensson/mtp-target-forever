#
# MTP Target Forever Dependencies Setup
#
# Downloads and configures all dependencies needed for building.
# This uses the same Ryzom external package as the CI builds.
#
# Usage:
#   .\scripts\setup-deps.ps1                    # Install to deps/ in repo
#   .\scripts\setup-deps.ps1 -DepsPath D:\deps  # Custom path
#   .\scripts\setup-deps.ps1 -SkipODE           # Skip ODE (client-only build)
#   .\scripts\setup-deps.ps1 -Force             # Re-download even if exists
#

param(
    [string]$DepsPath = $null,  # Default set below after loading manifest
    [switch]$SkipODE,
    [switch]$SkipCleanup,
    [switch]$Force,
    [switch]$Verify
)

$ErrorActionPreference = "Stop"

# Load manifest
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$scriptDir/deps-manifest.ps1"

# Set default path from manifest if not specified
if (!$DepsPath) {
    $DepsPath = Get-DepsPath
}

Write-Host "==========================================="
Write-Host "  MTP Target Forever Dependencies Setup"
Write-Host "==========================================="
Write-Host ""
Write-Host "Install path: $DepsPath"
Write-Host ""

# Verify-only mode
if ($Verify) {
    Write-Host "Verifying existing installation..."
    $result = Test-DepsInstalled -DepsPath $DepsPath -IncludeServer:(!$SkipODE)
    if ($result) {
        Write-Host "`nDependencies are correctly installed." -ForegroundColor Green
        exit 0
    } else {
        Write-Host "`nDependencies are missing or incomplete." -ForegroundColor Red
        exit 1
    }
}

# Check if already installed
if ((Test-Path "$DepsPath/CMakeLists.txt") -and !$Force) {
    Write-Host "Dependencies already exist at $DepsPath"
    Write-Host "Verifying installation..."

    $valid = Test-DepsInstalled -DepsPath $DepsPath -IncludeServer:(!$SkipODE) -Quiet
    if ($valid) {
        Write-Host "All dependencies verified. Use -Force to re-download." -ForegroundColor Green
        exit 0
    } else {
        Write-Host "Some files are missing. Re-downloading..." -ForegroundColor Yellow
    }
}

# Download Ryzom external package
$url = "https://cdn.ryzom.dev/core/2022q2_external_v143_x64.7z"
$archivePath = "$env:TEMP/ryzom_external.7z"

Write-Host "Downloading Ryzom external dependencies (~1.3GB)..."
Write-Host "URL: $url"
Write-Host ""

$ProgressPreference = 'SilentlyContinue'  # Faster download
try {
    Invoke-WebRequest -Uri $url -OutFile $archivePath -UseBasicParsing
} catch {
    Write-Error "Download failed: $_"
    exit 1
}
$ProgressPreference = 'Continue'

Write-Host "Download complete: $archivePath"
Write-Host ""

# Extract
Write-Host "Extracting to $DepsPath..."
if (Test-Path $DepsPath) {
    Write-Host "Removing existing directory..."
    Remove-Item -Recurse -Force $DepsPath
}
New-Item -ItemType Directory -Force -Path $DepsPath | Out-Null

# Check for 7z
$7zPath = $null
$7zLocations = @(
    "C:\Program Files\7-Zip\7z.exe",
    "C:\Program Files (x86)\7-Zip\7z.exe",
    (Get-Command 7z -ErrorAction SilentlyContinue).Source
)
foreach ($loc in $7zLocations) {
    if ($loc -and (Test-Path $loc)) {
        $7zPath = $loc
        break
    }
}

if (!$7zPath) {
    Write-Error "7-Zip not found. Please install 7-Zip and try again."
    Write-Host "Download from: https://www.7-zip.org/"
    exit 1
}

& $7zPath x $archivePath "-o$DepsPath" -y | Out-Null

# Handle nested directory structure
if (!(Test-Path "$DepsPath/CMakeLists.txt")) {
    $nested = Get-ChildItem $DepsPath -Directory | Where-Object {
        Test-Path "$($_.FullName)/CMakeLists.txt"
    } | Select-Object -First 1

    if ($nested) {
        Write-Host "Moving contents from nested folder: $($nested.Name)"
        Get-ChildItem $nested.FullName | Move-Item -Destination $DepsPath -Force
        Remove-Item $nested.FullName -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# Cleanup archive
Remove-Item $archivePath -Force

Write-Host "Extraction complete."
Write-Host ""

# Verify extraction
Write-Host "=== Verifying required files after extraction ==="
$allRequired = Get-AllRequiredFiles
$missing = @()
foreach ($file in $allRequired) {
    $fullPath = Join-Path $DepsPath $file
    if (!(Test-Path $fullPath)) {
        $missing += $file
        Write-Host "[MISSING] $file" -ForegroundColor Red
    }
}
if ($missing.Count -gt 0) {
    Write-Error "Missing $($missing.Count) required files after extraction!"
    exit 1
}
Write-Host "All $($allRequired.Count) required files present" -ForegroundColor Green
Write-Host ""

# Install ODE via vcpkg (unless skipped)
if (!$SkipODE) {
    Write-Host "=== Installing ODE physics library ==="

    if (Test-Path "$DepsPath/ode/include/ode/ode.h") {
        Write-Host "ODE already installed, skipping..."
    } else {
        # Find vcpkg
        $vcpkgRoot = $env:VCPKG_ROOT
        if (!$vcpkgRoot) {
            $vcpkgRoot = $env:VCPKG_INSTALLATION_ROOT
        }
        if (!$vcpkgRoot -and (Test-Path "C:\vcpkg")) {
            $vcpkgRoot = "C:\vcpkg"
        }

        if (!$vcpkgRoot -or !(Test-Path "$vcpkgRoot/vcpkg.exe")) {
            Write-Warning "vcpkg not found. ODE will not be installed."
            Write-Host "To install vcpkg: https://vcpkg.io/en/getting-started.html"
            Write-Host "Or install ODE manually to $DepsPath/ode"
        } else {
            Write-Host "Using vcpkg at: $vcpkgRoot"
            Write-Host "Installing ode:x64-windows-static-md..."

            & "$vcpkgRoot/vcpkg.exe" install ode:x64-windows-static-md

            # Copy to deps directory
            $installedDir = "$vcpkgRoot/installed/x64-windows-static-md"
            if (Test-Path $installedDir) {
                New-Item -ItemType Directory -Force -Path "$DepsPath/ode/include" | Out-Null
                New-Item -ItemType Directory -Force -Path "$DepsPath/ode/lib" | Out-Null

                if (Test-Path "$installedDir/include/ode") {
                    Copy-Item -Recurse "$installedDir/include/ode" "$DepsPath/ode/include/"
                    Write-Host "Copied ODE headers"
                }

                Get-ChildItem "$installedDir/lib" -Filter "ode*.lib" | ForEach-Object {
                    Copy-Item $_.FullName "$DepsPath/ode/lib/"
                    Write-Host "Copied: $($_.Name)"
                    if ($_.Name -ne "ode_doubles.lib") {
                        Copy-Item $_.FullName "$DepsPath/ode/lib/ode_doubles.lib"
                    }
                }

                Write-Host "ODE installation complete" -ForegroundColor Green
            }
        }
    }
    Write-Host ""
}

# Cleanup to reduce size (unless skipped)
if (!$SkipCleanup) {
    Write-Host "=== Cleaning up to reduce size ==="
    $beforeSize = (Get-ChildItem $DepsPath -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
    Write-Host "Size before cleanup: $([math]::Round($beforeSize, 2)) MB"

    # Remove unused library directories (saves ~3.4GB)
    Write-Host "`nRemoving unused libraries..."
    $unusedLibs = Get-UnusedLibraries
    foreach ($lib in $unusedLibs) {
        $libPath = Join-Path $DepsPath $lib
        if (Test-Path $libPath) {
            $libSize = (Get-ChildItem $libPath -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
            Remove-Item $libPath -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "  Removed: $lib ($([math]::Round($libSize, 1)) MB)"
        }
    }

    # Remove debug symbols
    Write-Host "`nRemoving debug symbols..."
    Get-ChildItem $DepsPath -Recurse -Filter "*.pdb" -ErrorAction SilentlyContinue |
        Remove-Item -Force -ErrorAction SilentlyContinue

    # Remove docs, samples, tests
    Write-Host "Removing docs, samples, tests..."
    Get-ChildItem $DepsPath -Recurse -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match "^(doc|docs|sample|samples|test|tests|example|examples)$" } |
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

    # Remove boost debug libraries (saves ~500MB)
    Write-Host "Removing boost debug libraries..."
    $boostDebugLibs = Get-ChildItem "$DepsPath/boost/lib" -Filter "*-gd-*.lib" -ErrorAction SilentlyContinue
    if ($boostDebugLibs) {
        $boostDebugSize = ($boostDebugLibs | Measure-Object -Property Length -Sum).Sum / 1MB
        $boostDebugLibs | Remove-Item -Force -ErrorAction SilentlyContinue
        Write-Host "  Removed $($boostDebugLibs.Count) boost debug libs ($([math]::Round($boostDebugSize, 1)) MB)"
    }

    # Remove known debug libraries explicitly (don't use pattern matching to avoid false positives like luabind.lib)
    $debugLibsToRemove = @(
        "luabind/lib/luabindd.lib",
        "libxml2/lib/libxml2d.lib"
    )
    foreach ($lib in $debugLibsToRemove) {
        $fullPath = Join-Path $DepsPath $lib
        if (Test-Path $fullPath) {
            Remove-Item $fullPath -Force -ErrorAction SilentlyContinue
            Write-Host "Removed debug lib: $lib"
        }
    }

    # Remove cmake/pkgconfig dirs
    Get-ChildItem $DepsPath -Recurse -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -eq "cmake" -or $_.Name -eq "pkgconfig" } |
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

    # Remove unnecessary executables
    $keepExes = @("lua.exe", "luac.exe")
    Get-ChildItem $DepsPath -Recurse -Filter "*.exe" -ErrorAction SilentlyContinue |
        Where-Object { $keepExes -notcontains $_.Name } |
        Remove-Item -Force -ErrorAction SilentlyContinue

    $afterSize = (Get-ChildItem $DepsPath -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
    Write-Host "`nSize after cleanup: $([math]::Round($afterSize, 2)) MB"
    Write-Host "Saved: $([math]::Round($beforeSize - $afterSize, 2)) MB" -ForegroundColor Green
    Write-Host ""
}

# Final verification
Write-Host "=== Final verification ==="
$valid = Test-DepsInstalled -DepsPath $DepsPath -IncludeServer:(!$SkipODE)

if ($valid) {
    Write-Host ""
    Write-Host "==========================================="
    Write-Host "  Dependencies installed successfully!"
    Write-Host "==========================================="
    Write-Host ""
    Write-Host "Dependencies path: $DepsPath"
    Write-Host ""
    Write-Host "To build:"
    Write-Host "  .\scripts\build-client.bat"
    Write-Host "  .\scripts\build-server.bat"
    Write-Host ""
} else {
    Write-Error "Verification failed after cleanup! Some required files are missing."
    exit 1
}

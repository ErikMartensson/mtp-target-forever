#
# MTP Target Forever Assets Manifest
#
# Cross-platform asset management for client and server builds.
# Works on Windows PowerShell 5.1+ and PowerShell Core (Linux/macOS).
#
# Usage:
#   . .\scripts\assets-manifest.ps1
#   Test-ClientAssets -DataPath "data"
#   Test-ServerAssets -DataPath "data"
#   Copy-ClientAssets -DataPath "data" -DestPath "build-client/bin/Release/data"
#

param(
    [string]$DataPath = $null
)

# Determine script and repo paths
$script:ScriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$script:RepoRoot = Split-Path -Parent $script:ScriptRoot
$script:ManifestPath = Join-Path $script:ScriptRoot "assets-manifest.json"

# Default data path
if (!$DataPath) {
    $DataPath = Join-Path $script:RepoRoot "data"
}

# Load manifest
function Get-AssetManifest {
    if (!(Test-Path $script:ManifestPath)) {
        throw "Asset manifest not found: $script:ManifestPath"
    }
    return Get-Content $script:ManifestPath -Raw | ConvertFrom-Json
}

# Get data path
function Get-DataPath {
    return $script:DataPath
}

function Get-RepoRoot {
    return $script:RepoRoot
}

# Get list of required directories for a build type
function Get-RequiredDirectories {
    param(
        [Parameter(Mandatory)][ValidateSet("client", "server")][string]$BuildType
    )

    $manifest = Get-AssetManifest
    return $manifest.directories.$BuildType.required
}

# Get list of optional directories for a build type
function Get-OptionalDirectories {
    param(
        [Parameter(Mandatory)][ValidateSet("client", "server")][string]$BuildType
    )

    $manifest = Get-AssetManifest
    return $manifest.directories.$BuildType.optional
}

# Get critical files that must exist
function Get-CriticalFiles {
    param(
        [Parameter(Mandatory)][ValidateSet("client", "server")][string]$BuildType
    )

    $manifest = Get-AssetManifest
    $files = @()

    # Get build-type specific files
    $buildTypeFiles = $manifest.criticalFiles.$BuildType
    foreach ($category in $buildTypeFiles.PSObject.Properties) {
        foreach ($file in $category.Value) {
            if ($category.Name -eq "config") {
                # Config files are at root level
                $files += $file
            } else {
                $files += "$($category.Name)/$file"
            }
        }
    }

    # Add shared files
    $sharedFiles = $manifest.criticalFiles.shared
    if ($sharedFiles) {
        foreach ($category in $sharedFiles.PSObject.Properties) {
            foreach ($file in $category.Value) {
                $files += "$($category.Name)/$file"
            }
        }
    }

    return $files
}

# Get runtime DLLs/shared libraries
function Get-RuntimeDependencies {
    param(
        [Parameter(Mandatory)][ValidateSet("client", "server")][string]$BuildType,
        [ValidateSet("windows", "linux")][string]$Platform = "windows"
    )

    $manifest = Get-AssetManifest
    $deps = @()

    $platformDeps = $manifest.runtimeDependencies.$BuildType.$Platform
    if ($platformDeps) {
        if ($platformDeps.nelDrivers) {
            $deps += $platformDeps.nelDrivers
        }
        if ($platformDeps.libs) {
            $deps += $platformDeps.libs
        }
    }

    return $deps
}

# Validate that required assets exist
function Test-Assets {
    param(
        [Parameter(Mandatory)][ValidateSet("client", "server")][string]$BuildType,
        [string]$DataPath = (Get-DataPath),
        [switch]$Quiet
    )

    $manifest = Get-AssetManifest
    $missing = @()
    $warnings = @()

    if (!$Quiet) {
        Write-Host "Validating $BuildType assets in: $DataPath" -ForegroundColor Cyan
    }

    # Check required directories exist and have files
    $requiredDirs = Get-RequiredDirectories -BuildType $BuildType
    foreach ($dir in $requiredDirs) {
        $dirPath = Join-Path $DataPath $dir
        if (!(Test-Path $dirPath)) {
            $missing += "Directory: $dir"
            continue
        }

        $fileCount = (Get-ChildItem $dirPath -File -Recurse -ErrorAction SilentlyContinue | Measure-Object).Count
        if ($fileCount -eq 0) {
            $warnings += "Directory empty: $dir"
        } elseif (!$Quiet) {
            Write-Host "  [OK] $dir ($fileCount files)" -ForegroundColor Green
        }
    }

    # Check optional directories
    $optionalDirs = Get-OptionalDirectories -BuildType $BuildType
    foreach ($dir in $optionalDirs) {
        $dirPath = Join-Path $DataPath $dir
        if (Test-Path $dirPath) {
            $fileCount = (Get-ChildItem $dirPath -File -Recurse -ErrorAction SilentlyContinue | Measure-Object).Count
            if (!$Quiet) {
                Write-Host "  [OK] $dir ($fileCount files) [optional]" -ForegroundColor DarkGreen
            }
        }
    }

    # Check critical files
    $criticalFiles = Get-CriticalFiles -BuildType $BuildType
    foreach ($file in $criticalFiles) {
        $filePath = Join-Path $DataPath $file
        if (!(Test-Path $filePath)) {
            # Check if it's a config file at project root
            $rootPath = Join-Path (Split-Path $DataPath -Parent) $file
            $configPath = Join-Path $DataPath "config/$file"

            if ((Test-Path $rootPath) -or (Test-Path $configPath)) {
                if (!$Quiet) {
                    Write-Host "  [OK] $file (in alternate location)" -ForegroundColor Green
                }
            } else {
                $missing += "Critical file: $file"
            }
        } elseif (!$Quiet) {
            Write-Host "  [OK] $file" -ForegroundColor Green
        }
    }

    # Report results
    if ($warnings.Count -gt 0) {
        if (!$Quiet) {
            Write-Host ""
            Write-Host "Warnings:" -ForegroundColor Yellow
            foreach ($warn in $warnings) {
                Write-Host "  ! $warn" -ForegroundColor Yellow
            }
        }
    }

    if ($missing.Count -gt 0) {
        if (!$Quiet) {
            Write-Host ""
            Write-Host "Missing:" -ForegroundColor Red
            foreach ($item in $missing) {
                Write-Host "  X $item" -ForegroundColor Red
            }
        }
        return $false
    }

    if (!$Quiet) {
        Write-Host ""
        Write-Host "All required $BuildType assets present" -ForegroundColor Green
    }
    return $true
}

# Convenience functions
function Test-ClientAssets {
    param(
        [string]$DataPath = (Get-DataPath),
        [switch]$Quiet
    )
    return Test-Assets -BuildType "client" -DataPath $DataPath -Quiet:$Quiet
}

function Test-ServerAssets {
    param(
        [string]$DataPath = (Get-DataPath),
        [switch]$Quiet
    )
    return Test-Assets -BuildType "server" -DataPath $DataPath -Quiet:$Quiet
}

# Copy assets for a build
function Copy-Assets {
    param(
        [Parameter(Mandatory)][ValidateSet("client", "server")][string]$BuildType,
        [string]$DataPath = (Get-DataPath),
        [Parameter(Mandatory)][string]$DestPath,
        [switch]$IncludeOptional
    )

    $manifest = Get-AssetManifest

    Write-Host "Copying $BuildType assets to: $DestPath" -ForegroundColor Cyan

    # Create destination if needed
    if (!(Test-Path $DestPath)) {
        New-Item -ItemType Directory -Path $DestPath -Force | Out-Null
    }

    # Copy required directories
    $requiredDirs = Get-RequiredDirectories -BuildType $BuildType
    foreach ($dir in $requiredDirs) {
        $srcDir = Join-Path $DataPath $dir
        $dstDir = Join-Path $DestPath $dir

        if (Test-Path $srcDir) {
            if (!(Test-Path $dstDir)) {
                New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
            }

            $files = Get-ChildItem $srcDir -File -Recurse
            $count = 0
            foreach ($file in $files) {
                $relativePath = $file.FullName.Substring($srcDir.Length + 1)
                $destFile = Join-Path $dstDir $relativePath
                $destFileDir = Split-Path $destFile -Parent

                if (!(Test-Path $destFileDir)) {
                    New-Item -ItemType Directory -Path $destFileDir -Force | Out-Null
                }

                Copy-Item $file.FullName $destFile -Force
                $count++
            }
            Write-Host "  + $dir ($count files)" -ForegroundColor Green
        } else {
            Write-Host "  ! $dir (not found)" -ForegroundColor Yellow
        }
    }

    # Copy optional directories if requested
    if ($IncludeOptional) {
        $optionalDirs = Get-OptionalDirectories -BuildType $BuildType
        foreach ($dir in $optionalDirs) {
            $srcDir = Join-Path $DataPath $dir
            $dstDir = Join-Path $DestPath $dir

            if (Test-Path $srcDir) {
                if (!(Test-Path $dstDir)) {
                    New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
                }

                Copy-Item -Path "$srcDir\*" -Destination $dstDir -Recurse -Force
                $count = (Get-ChildItem $srcDir -File -Recurse | Measure-Object).Count
                Write-Host "  + $dir ($count files) [optional]" -ForegroundColor DarkGreen
            }
        }
    }

    Write-Host ""
    Write-Host "Asset copy complete" -ForegroundColor Green
}

# Convenience functions for copying
function Copy-ClientAssets {
    param(
        [string]$DataPath = (Get-DataPath),
        [Parameter(Mandatory)][string]$DestPath,
        [switch]$IncludeOptional
    )
    Copy-Assets -BuildType "client" -DataPath $DataPath -DestPath $DestPath -IncludeOptional:$IncludeOptional
}

function Copy-ServerAssets {
    param(
        [string]$DataPath = (Get-DataPath),
        [Parameter(Mandatory)][string]$DestPath,
        [switch]$IncludeOptional
    )
    Copy-Assets -BuildType "server" -DataPath $DataPath -DestPath $DestPath -IncludeOptional:$IncludeOptional
}

# Get asset statistics
function Get-AssetStats {
    param(
        [string]$DataPath = (Get-DataPath)
    )

    $manifest = Get-AssetManifest
    $stats = @{}

    $allDirs = @()
    $allDirs += $manifest.directories.client.required
    $allDirs += $manifest.directories.client.optional
    $allDirs = $allDirs | Select-Object -Unique

    foreach ($dir in $allDirs) {
        $dirPath = Join-Path $DataPath $dir
        if (Test-Path $dirPath) {
            $files = Get-ChildItem $dirPath -File -Recurse -ErrorAction SilentlyContinue
            $stats[$dir] = @{
                Count = $files.Count
                SizeMB = [math]::Round(($files | Measure-Object -Property Length -Sum).Sum / 1MB, 2)
            }
        } else {
            $stats[$dir] = @{
                Count = 0
                SizeMB = 0
            }
        }
    }

    return $stats
}

# Print asset summary
function Show-AssetSummary {
    param(
        [string]$DataPath = (Get-DataPath)
    )

    Write-Host "Asset Summary for: $DataPath" -ForegroundColor Cyan
    Write-Host "=" * 50

    $stats = Get-AssetStats -DataPath $DataPath
    $totalFiles = 0
    $totalSize = 0

    foreach ($dir in $stats.Keys | Sort-Object) {
        $count = $stats[$dir].Count
        $size = $stats[$dir].SizeMB
        $totalFiles += $count
        $totalSize += $size

        if ($count -gt 0) {
            Write-Host ("{0,-15} {1,5} files  {2,8:N2} MB" -f $dir, $count, $size)
        } else {
            Write-Host ("{0,-15} {1,5} files  (empty)" -f $dir, $count) -ForegroundColor DarkGray
        }
    }

    Write-Host "-" * 50
    Write-Host ("{0,-15} {1,5} files  {2,8:N2} MB" -f "TOTAL", $totalFiles, $totalSize) -ForegroundColor Green
}

# Main execution when run directly
if ($MyInvocation.InvocationName -ne '.') {
    Write-Host "MTP Target Forever Asset Manifest" -ForegroundColor Cyan
    Write-Host "========================="
    Write-Host ""
    Show-AssetSummary -DataPath $DataPath
    Write-Host ""
    Write-Host "Validation:"
    Write-Host "-----------"
    Test-ClientAssets -DataPath $DataPath | Out-Null
    Write-Host ""
    Test-ServerAssets -DataPath $DataPath | Out-Null
}

# Export functions (only works when imported as module)
try {
    Export-ModuleMember -Function Get-AssetManifest, Get-DataPath, Get-RepoRoot,
        Get-RequiredDirectories, Get-OptionalDirectories, Get-CriticalFiles, Get-RuntimeDependencies,
        Test-Assets, Test-ClientAssets, Test-ServerAssets,
        Copy-Assets, Copy-ClientAssets, Copy-ServerAssets,
        Get-AssetStats, Show-AssetSummary
} catch {
    # Silently ignore - expected when dot-sourced
}

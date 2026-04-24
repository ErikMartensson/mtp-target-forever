# Resolve a playlist argument and write build-server/bin/mtp_target_service.cfg
# from the canonical template, substituting the LevelPlaylist block.
#
# Argument forms:
#   level_name            single level
#   a,b,c                 comma-separated inline list
#   preset-name           reads scripts/playlists/<preset-name>.txt
#   last                  reads scripts/playlists/last-session.txt
#   ""  /  $null          empty playlist (normal rotation)
#
# Side effects:
#   - Writes build-server/bin/mtp_target_service.cfg
#   - Writes scripts/playlists/last-session.txt with resolved level list
#
# Exit codes:
#   0 success
#   1 template missing or build dir missing
#   2 preset file not found
#   3 no levels resolved (after parsing)

param(
    [Parameter(Mandatory=$false, Position=0)]
    [string]$Playlist = ""
)

$ErrorActionPreference = "Stop"

# Resolve project paths relative to this script
$scriptDir   = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectDir  = Resolve-Path (Join-Path $scriptDir "..")
$templateCfg = Join-Path $projectDir "server/mtp_target_service_default.cfg"
$buildBin    = Join-Path $projectDir "build-server/bin"
$targetCfg   = Join-Path $buildBin "mtp_target_service.cfg"
$playlistDir = Join-Path $scriptDir "playlists"
$lastSession = Join-Path $playlistDir "last-session.txt"

if (-not (Test-Path $templateCfg)) {
    Write-Error "Template config not found: $templateCfg"
    exit 1
}
if (-not (Test-Path $buildBin)) {
    Write-Error "Build directory not found: $buildBin (build the server first)"
    exit 1
}
if (-not (Test-Path $playlistDir)) {
    New-Item -ItemType Directory -Path $playlistDir | Out-Null
}

# ---- Resolve the argument into an ordered list of level names ----

function Resolve-Playlist {
    param([string]$arg)

    if ([string]::IsNullOrWhiteSpace($arg)) {
        return @()
    }

    # "last" -> read last-session.txt
    if ($arg -eq "last") {
        if (-not (Test-Path $lastSession)) {
            Write-Host "Error: No last-session.txt yet. Run with an explicit playlist first." -ForegroundColor Red
            exit 2
        }
        return Read-PresetFile $lastSession
    }

    # Comma in arg -> inline list
    if ($arg -match ",") {
        return $arg.Split(",") | ForEach-Object { $_.Trim() } | Where-Object { $_ }
    }

    # Looks like a level name (starts with "level_") -> single level
    if ($arg.StartsWith("level_")) {
        return @($arg)
    }

    # Otherwise treat as preset name
    $presetFile = Join-Path $playlistDir ($arg + ".txt")
    if (-not (Test-Path $presetFile)) {
        Write-Host "Error: preset not found: $presetFile" -ForegroundColor Red
        Write-Host ""
        Write-Host "Available presets:" -ForegroundColor Yellow
        Get-ChildItem $playlistDir -Filter "*.txt" -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -ne "last-session.txt" } |
            ForEach-Object { Write-Host "  $($_.BaseName)" }
        exit 2
    }
    return Read-PresetFile $presetFile
}

function Read-PresetFile {
    param([string]$path)
    Get-Content $path |
        ForEach-Object { $_ -replace '#.*$','' } |
        ForEach-Object { $_.Trim() } |
        Where-Object { $_ }
}

$levels = Resolve-Playlist -arg $Playlist

# ---- Build the LevelPlaylist block ----

if ($levels.Count -eq 0) {
    $playlistBlock = "LevelPlaylist        = { };"
    $resolvedDesc  = "(empty - normal rotation)"
} else {
    $quoted = $levels | ForEach-Object { "  `"$_`"" }
    $playlistBlock = "LevelPlaylist        = {`r`n" + ($quoted -join ",`r`n") + "`r`n};"
    $resolvedDesc  = "$($levels.Count) level(s): " + ($levels -join ", ")
}

# ---- Substitute in the template ----

$templateContent = Get-Content $templateCfg -Raw

# Match LevelPlaylist = { ... } including multi-line. Non-greedy.
$pattern = '(?ms)^LevelPlaylist\s*=\s*\{[^}]*\};'
if ($templateContent -notmatch $pattern) {
    Write-Error "Could not find LevelPlaylist block in template. Pattern: $pattern"
    exit 1
}

$newContent = [regex]::Replace($templateContent, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{
    param($m)
    return $playlistBlock
})

# ---- Write target cfg ----

# Use UTF8 without BOM (NeL parser is byte-oriented; BOM can confuse it)
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($targetCfg, $newContent, $utf8NoBom)

# ---- Update last-session.txt (only if non-empty playlist) ----

if ($levels.Count -gt 0) {
    $sessionLines = @(
        "# Last session playlist - auto-written by set-playlist.ps1",
        "# Replay with: scripts\run-server.bat -p last",
        ""
    ) + $levels
    Set-Content -Path $lastSession -Value $sessionLines -Encoding UTF8
}

Write-Host "Playlist set: $resolvedDesc" -ForegroundColor Green
Write-Host "Wrote: $targetCfg"

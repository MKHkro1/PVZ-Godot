# Toggle editor_plugins/enabled in project.godot for headless exports.
# Usage:
#   set_plugins.ps1 -Off      : backup project.godot and clear plugin list (before export)
#   set_plugins.ps1 -On       : restore project.godot from backup (after export / on failure)
#   set_plugins.ps1 -Recover  : restore only if an orphan backup exists (crash self-heal)
# NOTE: keep this file ASCII-only so Windows PowerShell 5.1 parses it under any codepage.
param(
    [switch]$Off,
    [switch]$On,
    [switch]$Recover
)

$ErrorActionPreference = 'Stop'
$proj = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\project.godot'))
$bak = "$proj.plugins_bak"

function Restore-Backup {
    if (Test-Path -LiteralPath $bak) {
        Move-Item -LiteralPath $bak -Destination $proj -Force
        Write-Host "[plugins] project.godot restored from backup"
        return $true
    }
    return $false
}

if ($Recover) {
    if (-not (Restore-Backup)) { Write-Host "[plugins] no orphan backup, skip" }
    exit 0
}

if ($Off) {
    if (Test-Path -LiteralPath $bak) { Restore-Backup | Out-Null }  # never overwrite a good backup
    Copy-Item -LiteralPath $proj -Destination $bak -Force
    $raw = [System.IO.File]::ReadAllText($proj)
    $new = [regex]::Replace($raw, '(?m)^enabled=PackedStringArray\([^\r\n]*\)', 'enabled=PackedStringArray()')
    if ($new -eq $raw) { Write-Host "[plugins] WARNING: enabled= line not found, nothing changed"; Remove-Item -LiteralPath $bak -Force; exit 1 }
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($proj, $new, $utf8NoBom)
    Write-Host "[plugins] editor plugins temporarily disabled for headless export"
    exit 0
}

if ($On) {
    if (Restore-Backup) { Write-Host "[plugins] editor plugins restored" }
    else { Write-Host "[plugins] no backup to restore (probably never disabled)" }
    exit 0
}

Write-Host "Usage: set_plugins.ps1 [-Off | -On | -Recover]"
exit 1

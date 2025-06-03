# REFLECT Update Script (Internal Use Only)
# Onboards new chat logs from /private/Staging/, redacts high-sensitivity PII, and outputs processed files to /pcshowme/ai-chat/misc/ and journal snippets to /private/Journal/entries/
# Do NOT reference or expose this script or the Journal folder in public documentation.

Set-Location -Path "D:\Documents\_Data-Vault\Code\GitHub\Grounding"

# Fix: Ensure $MiscDir is always correct relative to project root
$Root = Split-Path -Parent $PSScriptRoot
$StagingDir = Join-Path $Root "private\Staging"
$MiscDir = Join-Path $Root "pcshowme\ai-chat\misc"
$Date = Get-Date -Format "yyyy-MM-dd"
$IdCounter = 65 # ASCII 'A'

# Ensure output directories exist
foreach ($dir in @($MiscDir)) { if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null } }

# Only process files in /private/Staging/ with .raw extension (never .cht or .md)
$Files = Get-ChildItem -Path $StagingDir -Recurse -Include *.raw | Where-Object { !$_.PSIsContainer }

# Debug: Print resolved paths and files being processed
Write-Host "[DEBUG] StagingDir: $StagingDir"
Write-Host "[DEBUG] MiscDir: $MiscDir"
Write-Host "[DEBUG] Files found: $($Files.Count)"
foreach ($f in $Files) { Write-Host "[DEBUG] Processing: $($f.FullName)" }

foreach ($File in $Files) {
    $Content = Get-Content $File.FullName -Raw
    $BaseName = [System.IO.Path]::GetFileNameWithoutExtension($File.Name)
    # Simple redaction for Financial PII
    $Redacted = $Content `
        -replace '\b\d{3}-\d{2}-\d{4}\b', '[ssn]' `
        -replace '\b(?:\d[ -]*?){13,16}\b', '[credit_card]' `
        -replace '(?i)api[_-]?key\s*[:=]\s*\S+', '[api_key]' `
        -replace '(?i)secret[_-]?key\s*[:=]\s*\S+', '[secret_key]' `
        -replace '(?i)bank\s*account\s*[:=]?\s*\d+', '[bank_account]' `
        -replace '\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b', '[email]'
    $ChtFile = Join-Path $MiscDir ($BaseName + ".cht")
    $MdFile = Join-Path $MiscDir ($BaseName + ".md")
    $MapFile = Join-Path $MiscDir ($BaseName + ".map")
    Set-Content -Path $ChtFile -Value $Redacted
    Set-Content -Path $MdFile -Value $Redacted
    Set-Content -Path $MapFile -Value "map: $BaseName"
    # Append to index.md
    $IndexFile = Join-Path $MiscDir "..\index.md"
    $ChtRel = "misc/$BaseName.cht"
    $MdRel = "misc/$BaseName.md"
    $MapRel = "misc/$BaseName.map"
    $Date = Get-Date -Format "yyyy-MM-dd"
    $IndexEntry = "- [$BaseName]($ChtRel) | [summary]($MdRel) | [map]($MapRel) | $Date"
    if (!(Test-Path $IndexFile)) {
        Set-Content -Path $IndexFile -Value "# AI Chat Knowledge Base Index`n`n| Chat | Summary | Map | Date |`n|---|---|---|---|`n$IndexEntry"
    }
    else {
        Add-Content -Path $IndexFile -Value $IndexEntry
    }
}
Write-Host "Redaction and copy complete. .cht, .md, .map files created in /pcshowme/ai-chat/misc/ and index updated."

# End of REFLECT Update Script

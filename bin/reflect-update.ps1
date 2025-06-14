# REFLECT Update Script (Internal Use Only)
# Onboards new chat logs from /private/Staging/, redacts high-sensitivity PII, and outputs processed files to /pcshowme/ai-chat/misc/ and journal snippets to /private/Journal/entries/
# Do NOT reference or expose this script or the Journal folder in public documentation.
<#  

1) Jim will upload the NEW AI Chat transcript (*.raw) to the /private/Staging/ folder.
2) This script will run to process the files in /private/Staging/ and redact sensitive information.
3) The script will create (Redacted) .cht file in /pcshowme/ai-chat/NewChats/
4) Copilot will then create the .md & map files in the appropriate directory and move the *.cht file there as well.
5) This will ensure that the file has been onboarded properly & copilot is tracking it

#>

Set-Location -Path "D:\Documents\_Data-Vault\Code\GitHub\Grounding"

# Fix: Ensure $NewChatsDir is always correct relative to project root
$Root = Split-Path -Parent $PSScriptRoot
$StagingDir = Join-Path $Root "private\Staging"
$NewChatsDir = Join-Path $Root "pcshowme\ai-chat\NewChats"
$Date = Get-Date -Format "yyyy-MM-dd"
$IdCounter = 65 # ASCII 'A'

# Ensure output directories exist
foreach ($dir in @($NewChatsDir)) { if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null } }

# Only process files in /private/Staging/ with .raw extension (never .cht or .md)
$Files = Get-ChildItem -Path $StagingDir -Recurse -Include *.raw | Where-Object { !$_.PSIsContainer }

# Debug: Print resolved paths and files being processed
Write-Host "[DEBUG] StagingDir: $StagingDir"
Write-Host "[DEBUG] NewChatsDir: $NewChatsDir"
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
    $ChtFile = Join-Path $NewChatsDir ($BaseName + ".cht")
    Set-Content -Path $ChtFile -Value $Redacted
    # Append to index.md
    $IndexFile = Join-Path $NewChatsDir "..\index.md"
    $ChtRel = "NewChats/$BaseName.cht"
    $Date = Get-Date -Format "yyyy-MM-dd"
    $IndexEntry = "- [$BaseName]($ChtRel) | [summary]($MdRel) | [map]($MapRel) | $Date"
    if (!(Test-Path $IndexFile)) {
        Set-Content -Path $IndexFile -Value "# AI Chat Knowledge Base Index`n`n| Chat | Summary | Map | Date |`n|---|---|---|---|`n$IndexEntry"
    }
    else {
        Add-Content -Path $IndexFile -Value $IndexEntry
    }
}
Write-Host "Redaction and copy complete." 
Write-Host ".cht file created in /pcshowme/ai-chat/NewChats/ and index updated."
Write-Host "Please Verify, Delete the RAW files in the stagging folder, and notify copilot to finalize onboarding."

# End of REFLECT Update Script

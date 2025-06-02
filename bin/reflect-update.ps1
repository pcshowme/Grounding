# REFLECT Update Script (Internal Use Only)
# Onboards new chat logs from /private/Staging/, redacts high-sensitivity PII, and outputs processed files to /pcshowme/ai-chat/misc/ and journal snippets to /private/Journal/entries/
# Do NOT reference or expose this script or the Journal folder in public documentation.

Set-Location -Path "D:\Documents\_Data-Vault\Code\GitHub\Grounding"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$StagingDir = Join-Path $Root "..\..\private\Staging"
$JournalDir = Join-Path $Root "..\..\private\Journal\entries"
$MiscDir = Join-Path $Root "pcshowme\ai-chat\misc"
$MapAnchor = "journal_ref:"
$SentimentTerms = @("felt", "prayer", "grateful", "struggling", "thankful", "blessed", "hope", "faith", "joy", "peace", "forgive", "healing")
$MilestoneTerms = @("launched", "released", "talked with", "breakthrough", "milestone", "finished", "completed", "started", "ended")
$RedactionMarkerPattern = "\[See Journal Entry \d{4}-\d{2}-\d{2}-[A-Z]\]"
$Date = Get-Date -Format "yyyy-MM-dd"
$IdCounter = 65 # ASCII 'A'

# Ensure output directories exist
foreach ($dir in @($JournalDir, $MiscDir)) { if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null } }

# Only process files in /private/Staging/
$Files = Get-ChildItem -Path $StagingDir -Recurse -Include *.cht, *.md | Where-Object { !$_.PSIsContainer }

foreach ($File in $Files) {
    $Content = Get-Content $File.FullName -Raw

    # Skip if already redacted
    if ($Content -match $RedactionMarkerPattern) { continue }

    # Find lines with sentiment or milestone triggers
    $Lines = $Content -split "`r?`n"
    $ReflectLines = $Lines | Where-Object {
        $line = $_.ToLower()
        ($SentimentTerms + $MilestoneTerms) | Where-Object { $line -like "*$_*" }
    }

    if ($ReflectLines.Count -eq 0) { continue }

    # Redact only high-sensitivity PII (bank, SSN, API keys, credit card, etc.)
    $Redacted = $ReflectLines | ForEach-Object {
        $_ `
            -replace '\b\d{3}-\d{2}-\d{4}\b', '[ssn]' `
            -replace '\b(?:\d[ -]*?){13,16}\b', '[credit_card]' `
            -replace '(?i)api[_-]?key\s*[:=]\s*\S+', '[api_key]' `
            -replace '(?i)secret[_-]?key\s*[:=]\s*\S+', '[secret_key]' `
            -replace '(?i)bank\s*account\s*[:=]?\s*\d+', '[bank_account]' `
            -replace '\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b', '[email]' # Optional: comment out if you want to keep emails
    }

    # Create unique journal entry filename
    $Id = [char]$IdCounter
    $JournalFile = "journal-$Date-$Id.md"
    $JournalPath = Join-Path $JournalDir $JournalFile
    while (Test-Path $JournalPath) {
        $IdCounter++
        $Id = [char]$IdCounter
        $JournalFile = "journal-$Date-$Id.md"
        $JournalPath = Join-Path $JournalDir $JournalFile
    }

    # Write journal entry
    $Tags = "#reflection #personal"
    $Yaml = "---`nupdated: $Date`ntags: [$Tags]`nsource: $($File.Name)`n---"
    $RedactedText = $Redacted -join "`n"
    $Entry = "$Yaml`n`n$RedactedText"
    Set-Content -Path $JournalPath -Value $Entry

    # Replace original lines with redaction marker
    $Marker = "[See Journal Entry $Date-$Id]"
    $NewLines = $Lines | ForEach-Object {
        if ($ReflectLines -contains $_) { $Marker } else { $_ }
    }

    # Output processed file to /pcshowme/ai-chat/misc/ with same filename
    $OutFile = Join-Path $MiscDir $File.Name
    Set-Content -Path $OutFile -Value ($NewLines -join "`n")

    # Optionally update .map file in misc/
    $MapFile = $File.FullName -replace '\.(cht|md)$', '.map'
    $MiscMapFile = Join-Path $MiscDir ([System.IO.Path]::GetFileName($MapFile))
    if (Test-Path $MapFile) {
        if (!(Test-Path $MiscMapFile)) {
            Copy-Item $MapFile $MiscMapFile
        }
        $MapContent = Get-Content $MiscMapFile -Raw
        if ($MapContent -notmatch "journal_ref:") {
            Add-Content -Path $MiscMapFile -Value "`njournal_ref: $JournalFile"
        }
    }
    $IdCounter++
}

Write-Host "REFLECT onboarding complete. Processed files in /pcshowme/ai-chat/misc/ and journal entries in /private/Journal/entries/."

# End of REFLECT Update Script

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

# Only process files in /private/Staging/ with .raw, .cht, or .md extensions
$Files = Get-ChildItem -Path $StagingDir -Recurse -Include *.raw, *.cht, *.md | Where-Object { !$_.PSIsContainer }

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

    # Determine base name for output files (strip .raw, .cht, .md extension)
    $BaseName = [System.IO.Path]::GetFileNameWithoutExtension($File.Name)

    # Output filtered chat as .cht
    $ChtFile = Join-Path $MiscDir ($BaseName + ".cht")
    Set-Content -Path $ChtFile -Value ($NewLines -join "`n")

    # Output summary as .md
    $MdFile = Join-Path $MiscDir ($BaseName + ".md")
    $Summary = "# Summary for $BaseName`n`n" + ($Redacted -join "`n")
    Set-Content -Path $MdFile -Value $Summary

    # Output semantic map as .map
    $MapFile = Join-Path $MiscDir ($BaseName + ".map")
    if (!(Test-Path $MapFile)) {
        Set-Content -Path $MapFile -Value "journal_ref: $JournalFile"
    }
    elseif ((Get-Content $MapFile -Raw) -notmatch "journal_ref:") {
        Add-Content -Path $MapFile -Value "`njournal_ref: $JournalFile"
    }

    $IdCounter++
}

Write-Host "REFLECT onboarding complete. Processed .raw, .cht, .md files to .cht, .md, .map in /pcshowme/ai-chat/misc/ and journal entries in /private/Journal/entries/."

# End of REFLECT Update Script

# REFLECT Update Script (Internal Use Only)
# Scans .cht and .md files for journal-worthy reflections, redacts sensitive info, and archives to /Journal/entries/
# Do NOT reference or expose this script or the Journal folder in public documentation.

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$JournalDir = Join-Path $Root "..\\..\\Journal\\entries"
$MapAnchor = "journal_ref:"
$SentimentTerms = @("felt", "prayer", "grateful", "struggling", "thankful", "blessed", "hope", "faith", "joy", "peace", "forgive", "healing")
$MilestoneTerms = @("launched", "released", "talked with", "breakthrough", "milestone", "finished", "completed", "started", "ended")
$RedactionMarkerPattern = "\[See Journal Entry \d{4}-\d{2}-\d{2}-[A-Z]\]"
$Date = Get-Date -Format "yyyy-MM-dd"
$IdCounter = 65 # ASCII 'A'

# Ensure Journal directory exists
if (!(Test-Path $JournalDir)) { New-Item -ItemType Directory -Path $JournalDir | Out-Null }

$Files = Get-ChildItem -Path $Root -Recurse -Include *.cht, *.md | Where-Object {
    $_.FullName -notmatch "Journal\\system"
}


foreach ($File in $Files) {
    $Content = Get-Content $File.FullName -Raw

    # Skip if already redacted
    if ($Content -match $RedactionMarkerPattern) { continue }

    # Find lines with sentiment or milestone triggers
    $Lines = $Content -split "`r?`n"
    $Matches = $Lines | Where-Object {
        $line = $_.ToLower()
        ($SentimentTerms + $MilestoneTerms) | Where-Object { $line -like "*$_*" }
    }

    if ($Matches.Count -eq 0) { continue }

    # Redact PII and sensitive info
    $Redacted = $Matches | ForEach-Object {
        $_ -replace '\b([A-Z][a-z]+)\b', '[name redacted]' `
            -replace '\b\d{4}-\d{2}-\d{2}\b', '[date]' `
            -replace '\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b', '[ip]' `
            -replace '\b\d{1,5} [A-Za-z ]+ (Ave|St|Rd|Blvd|Dr|Ln|Way)\b', '[location]'
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
    $Entry = "$Yaml`n`n$($Redacted -join \"`n\")"
    Set-Content -Path $JournalPath -Value $Entry

    # Replace original lines with redaction marker
    $Marker = "[See Journal Entry $Date-$Id]"
    $NewLines = $Lines | ForEach-Object {
        if ($Matches -contains $_) { $Marker } else { $_ }
    }
    Set-Content -Path $File.FullName -Value ($NewLines -join "`n")

    # Optionally update .map file
    $MapFile = $File.FullName -replace '\.(cht|md)$', '.map'
    if (Test-Path $MapFile) {
        $MapContent = Get-Content $MapFile -Raw
        if ($MapContent -notmatch "$MapAnchor") {
            Add-Content -Path $MapFile -Value "`n$MapAnchor $JournalFile"
        }
    }

    $IdCounter++
}

Write-Host "REFLECT update complete. Journal entries created and source files redacted as needed."

# End of REFLECT Update Script

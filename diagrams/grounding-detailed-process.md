# Detailed File/Automation Flow (Mermaid)

```mermaid
flowchart TD
    subgraph Content_Creation
        A1[User/AI creates or edits .cht (chat), .md (summary), or project files]
    end

    subgraph Indexing_and_Structure
        B1[PowerShell/Script Automation]
        B2[Generate .md summary with YAML frontmatter]
        B3[Generate .map semantic map (topics, anchors, tags)]
        B4[Create .cht transcript/stub]
    end

    subgraph Knowledge_Base
        C1[All indexed files with updated timestamps]
        C2[AI-StartHERE.md and onboarding docs]
    end

    subgraph Privacy_and_Reflection
        D1[reflect-update.ps1 script]
        D2[Scan for triggers (sentiment, milestone)]
        D3[Redact PII/emotional content]
        D4[Archive to /Journal/entries/]
        D5[Insert redaction marker in source]
        D6[Update .map with journal_ref]
    end

    A1 --> B1
    B1 --> B2
    B1 --> B3
    B1 --> B4
    B2 --> C1
    B3 --> C1
    B4 --> C1
    C1 --> D1
    D1 --> D2
    D2 --> D3
    D3 --> D4
    D3 --> D5
    D5 --> D6
    D4 --> C1
    D6 --> C1
    C1 --> C2
```

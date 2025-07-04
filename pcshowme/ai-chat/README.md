# Chat Archive Processing Plan

This document outlines the safe, non-destructive workflow for extracting value from your chat archive.

## Immutable Source
- All `.cht` files are left untouched and serve as the canonical backup of your chat data.
- All new data (indexes, digests, idea banks, etc.) are generated from these files.

---

## Full Chat Onboarding & Processing Workflow

### 1. Raw Capture
- **Raw**: Export or save new chat logs/conversations in their original format.

### 2. Staging
- **Staging**: Move raw files to a staging area for review and initial organization.

### 3. Redaction
- **Redacted**: Remove or mask any sensitive/private information as needed.

### 4. NewChats
- **NewChats**: Place redacted, ready-to-process chats here for further action.

### 5. Summarization & Indexing
- **Summarized/Indexed**: Generate summaries, semantic maps, and metadata (date, tags, participants, topics, etc.).
- Update or create a master index (CSV/JSON/Markdown) for search and retrieval.

### 6. Miscellaneous & Archival
- **Misc**: Move processed chats here for long-term storage or further mining.
- **Clean up**: Archive or delete temporary/intermediate files as needed (never the original `.cht` files).

### 7. Automated Post-Onboarding Processing
- Run scripts (e.g., `process_chats.py`) to:
  - Build or update the master index
  - Extract ideas, TODOs, and action items into an idea bank
  - Optionally generate digests or highlight reels

---

## Processing Steps
1. **Indexing**: Scan `.cht` files and extract metadata (date, participants, summary, tags).
2. **Idea Mining**: Extract lines/blocks marked as TODO, IDEA, ACTION, or similar into a central log.
3. **Digest Generation**: Create Markdown/HTML digests of highlights, best ideas, and action items.
4. **Search/Filter**: Build a simple search/filter tool for tags, dates, or keywords.

## Safety Principles
- Never modify or delete `.cht` files.
- All scripts are additive: new outputs are written to new files.
- If you need to reprocess, simply rerun scripts on the `.cht` files.
- Back up `.cht` files regularly for disaster recovery.

## Next Steps
- Implement Python scripts for indexing and idea mining.
- Optionally, add digest and search tools.

---

_This README ensures your workflow is safe, repeatable, and future-proof._

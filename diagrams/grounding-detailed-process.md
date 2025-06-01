# Detailed File/Automation Flow (ASCII)

#
#  +-----------------------------+
#  | User/AI creates or edits    |
#  | .cht, .md, or project files |
#  +-----------------------------+
#                |
#                v
#  +-----------------------------+
#  | PowerShell/Script Automation|
#  +-----------------------------+
#      /      |        \
#     v       v         v
#  +--------+ +--------+ +--------+
#  | .md    | | .map   | | .cht   |
#  |Summary | |Semantic| |Transcript|
#  +--------+ +--------+ +--------+
#      \      |        /
#        \    |      /
#          v  v    v
#      +-----------------------------+
#      | All indexed files            |
#      | (with updated timestamps)    |
#      +-----------------------------+
#                |
#                v
#      +-----------------------------+
#      | reflect-update.ps1 script    |
#      +-----------------------------+
#                |
#      +-----------------------------+
#      | Scan for triggers            |
#      | (sentiment, milestone)       |
#      +-----------------------------+
#                |
#      +-----------------------------+
#      | Redact PII/emotional content |
#      +-----------------------------+
#         /                 \
#        v                   v
#  +-------------------+   +-------------------+
#  | Archive to Journal|   | Insert redaction  |
#  | /Journal/entries/ |   | marker in source  |
#  +-------------------+   +-------------------+
#         \                   /
#          v                 v
#      +-----------------------------+
#      | Update .map with journal_ref |
#      +-----------------------------+
#                |
#                v
#      +-----------------------------+
#      | AI-StartHERE.md and docs     |
#      +-----------------------------+
#
```

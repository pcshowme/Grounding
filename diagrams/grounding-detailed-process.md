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
#  |(master | |(master | |Transcript|
#  | idea   | | index) | |         |
#  | bank)  | |        | |         |
#  +--------+ +--------+ +--------+
#      \      |        /
#        \    |      /
#          v  v    v
#      +-----------------------------+
#      | All indexed files            |
#      | (with updated timestamps)    |
#      +-----------------------------+
#
#  Note: As of July 2025, the workflow uses a single master index (.map/.json) and idea bank (.md) for all chats, instead of per-chat .map/.md files. This improves efficiency and scalability. All documentation and automation should reference this approach.
#
#  (Legacy per-chat .map/.md files are no longer generated for new chats.)
#
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

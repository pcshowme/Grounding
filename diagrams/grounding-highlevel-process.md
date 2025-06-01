# High-Level Process Flow (Mermaid)

```mermaid
flowchart TD
    A[Create/Edit Content<br>(.cht, .md, source files)] --> B[Run Indexing/Automation]
    B --> C[Generate/Update .md Summaries]
    B --> D[Generate/Update .map Semantic Maps]
    B --> E[Create/Update .cht Transcripts]
    C & D & E --> F[Knowledge Base Ready for Query]
    F --> G[User/AI Query or Review]
    F --> H[Run reflect-update.ps1<br>(Redaction/Journal)]
    H --> I[Redact Sensitive Info<br>in Source]
    H --> J[Archive Reflection<br>to /Journal/entries/]
    I & J --> K[Knowledge Base Remains Private & Safe]
```

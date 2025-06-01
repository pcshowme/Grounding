# High-Level Process Flow (Mermaid)

```mermaid
flowchart TD
    A[Create/Edit Content (.cht, .md, source files)] --> B[Run Indexing/Automation]
    B --> C[Generate or Update md Summaries]
    B --> D[Generate or Update map Semantic Maps]
    B --> E[Create or Update cht Transcripts]
    C --> F[Knowledge Base Ready for Query]
    D --> F
    E --> F
    F --> G[User/AI Query or Review]
    F --> H[Run reflect-update.ps1 (Redaction/Journal)]
    H --> I[Redact Sensitive Info in Source]
    H --> J[Archive Reflection to Journal/entries]
    I --> K[Knowledge Base Remains Private and Safe]
    J --> K
```

import os
import re
import glob
import datetime
import json

# Directory containing .cht files
CHAT_DIR = os.path.join(os.path.dirname(__file__), 'misc')
OUTPUT_INDEX = os.path.join(os.path.dirname(__file__), 'chat_index.json')
OUTPUT_IDEA_BANK = os.path.join(os.path.dirname(__file__), 'idea_bank.md')

# Patterns for idea/action mining
IDEA_PATTERNS = [r'\bTODO\b', r'\bIDEA\b', r'\bACTION\b', r'\bNOTE\b', r'\bQUESTION\b']

index = []
idea_bank = []

for chat_file in glob.glob(os.path.join(CHAT_DIR, '*.cht')):
    with open(chat_file, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    # Metadata extraction
    filename = os.path.basename(chat_file)
    date_match = re.search(r'(\d{4}-\d{2}-\d{2})', filename)
    date = date_match.group(1) if date_match else ''
    summary = ''
    # Try to extract a summary from the first 20 lines
    lines = content.splitlines()
    for line in lines[:20]:
        if 'summary' in line.lower() or 'recap' in line.lower():
            summary = line.strip()
            break
    # Tag extraction (simple keyword scan)
    tags = set()
    for tag in ['AI', 'music', 'health', 'workflow', 'video', 'script', 'worship', 'podcast', 'mic', 'routine', 'food', 'Meta', 'YouTube', 'lyric', 'song', 'project']:
        if tag.lower() in content.lower():
            tags.add(tag)
    # Idea/action mining
    for pattern in IDEA_PATTERNS:
        for match in re.finditer(pattern, content, re.IGNORECASE):
            # Grab the line and a few lines of context
            start = content.rfind('\n', 0, match.start())
            end = content.find('\n', match.end())
            idea_line = content[start+1:end].strip()
            idea_bank.append(f'[{filename}] {idea_line}')
    # Build index entry
    index.append({
        'file': filename,
        'date': date,
        'summary': summary,
        'tags': sorted(list(tags)),
        'size': len(content)
    })

# Write outputs
with open(OUTPUT_INDEX, 'w', encoding='utf-8') as f:
    json.dump(index, f, indent=2)

with open(OUTPUT_IDEA_BANK, 'w', encoding='utf-8') as f:
    f.write('# Idea Bank\n\n')
    for idea in idea_bank:
        f.write(f'- {idea}\n')

print(f'Index written to {OUTPUT_INDEX}')
print(f'Idea bank written to {OUTPUT_IDEA_BANK}')

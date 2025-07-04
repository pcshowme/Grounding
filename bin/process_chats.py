import os
import re
import glob
import json
import hashlib

# Directory containing .cht files (relative to bin/)
CHAT_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'misc')
OUTPUT_INDEX = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'chat_index.json')
OUTPUT_IDEA_BANK = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'idea_bank.md')
PROCESSED_RECORD = os.path.join(os.path.dirname(os.path.dirname(__file__)), '.processed_chats.json')

# Patterns for idea/action mining
IDEA_PATTERNS = [r'\bTODO\b', r'\bIDEA\b', r'\bACTION\b', r'\bNOTE\b', r'\bQUESTION\b']

# Load processed record
if os.path.exists(PROCESSED_RECORD):
    with open(PROCESSED_RECORD, 'r', encoding='utf-8') as f:
        processed = json.load(f)
else:
    processed = {}

# Load existing outputs if present
if os.path.exists(OUTPUT_INDEX):
    with open(OUTPUT_INDEX, 'r', encoding='utf-8') as f:
        index = json.load(f)
else:
    index = []

if os.path.exists(OUTPUT_IDEA_BANK):
    with open(OUTPUT_IDEA_BANK, 'r', encoding='utf-8') as f:
        idea_bank = f.read().splitlines()[1:]  # skip header
else:
    idea_bank = []

index_files = {entry['file']: entry for entry in index}

new_index = []
new_idea_bank = []

for chat_file in glob.glob(os.path.join(CHAT_DIR, '*.cht')):
    filename = os.path.basename(chat_file)
    with open(chat_file, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    # Hash for change detection
    file_hash = hashlib.md5(content.encode('utf-8')).hexdigest()
    if filename in processed and processed[filename] == file_hash:
        # Already processed, skip
        continue
    # Metadata extraction
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
            new_idea_bank.append(f'[{filename}] {idea_line}')
    entry = {
        'file': filename,
        'date': date,
        'summary': summary,
        'tags': sorted(list(tags)),
        'size': len(content)
    }
    new_index.append(entry)
    processed[filename] = file_hash

# Merge new entries
index.extend(new_index)
# Remove duplicates by file name (keep latest)
unique_index = {entry['file']: entry for entry in index}
index = list(unique_index.values())

idea_bank.extend(new_idea_bank)
# Remove duplicates
idea_bank = list(dict.fromkeys(idea_bank))

# Write outputs
with open(OUTPUT_INDEX, 'w', encoding='utf-8') as f:
    json.dump(index, f, indent=2)

with open(OUTPUT_IDEA_BANK, 'w', encoding='utf-8') as f:
    f.write('# Idea Bank\n\n')
    for idea in idea_bank:
        f.write(f'- {idea}\n')

with open(PROCESSED_RECORD, 'w', encoding='utf-8') as f:
    json.dump(processed, f, indent=2)

print(f'Index updated: {len(new_index)} new/changed files processed.')
print(f'Idea bank updated: {len(new_idea_bank)} new ideas found.')

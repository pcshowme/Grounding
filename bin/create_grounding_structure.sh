#!/bin/bash

# Absolute base directory
BASE_DIR="/D/Documents/_Data-Vault/Code/Github/Grounding/pcshowme"

# Create directory structure
mkdir -p "$BASE_DIR"/{audience-insights,creative-guides,content-plans,marketing-playbook,ai-tools-workflow,grounding-prompts}

# Create placeholder README and markdown files
cat <<EOF > "$BASE_DIR/README.md"
# pcSHOWme Grounding

This repository contains reference data, audience insights, creative guidelines, and workflow patterns used to support strategic music/video production and monetization for the pcSHOWme ecosystem.
EOF

touch "$BASE_DIR"/audience-insights/{us_male_35-64_notes.md,yt-meta-observations.md}
touch "$BASE_DIR"/creative-guides/{song_themes.md,style-reference.md}
touch "$BASE_DIR"/content-plans/{above-the-fear.md,future-songs.md}
touch "$BASE_DIR"/marketing-playbook/{meta-ads.md,yt-growth-strategy.md}
touch "$BASE_DIR"/ai-tools-workflow/{comfyui-templates.md,magi1-notes.md}
touch "$BASE_DIR"/grounding-prompts/{jim-style-story-template.md,ai-scene-vibes.md}

echo "✅ Grounding structure created at: $BASE_DIR"

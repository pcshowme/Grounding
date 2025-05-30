#!/bin/bash
BASE_DIR="/D/Documents/_Data-Vault/Code/Github/Grounding/pcshowme"

mkdir -p "$BASE_DIR/audience-insights"
cat << EOF > "$BASE_DIR/audience-insights/README.md"
# Audience Insights

This folder contains research, notes, and analytics on audience behavior, especially focused on U.S. males aged 35–64. Includes watch patterns, clickthrough trends, and resonance analysis from YouTube and Meta Ads.
EOF

mkdir -p "$BASE_DIR/creative-guides"
cat << EOF > "$BASE_DIR/creative-guides/README.md"
# Creative Guides

Templates, tone guides, and style references used to shape storytelling and songwriting to match our key demographic. Aligned with inspirational rock, cinematic theming, and faith-forward messaging.
EOF

mkdir -p "$BASE_DIR/content-plans"
cat << EOF > "$BASE_DIR/content-plans/README.md"
# Content Plans

Outlines for upcoming content, including music videos, behind-the-scenes features, message-driven shorts, and longform audience engagement strategies.
EOF

mkdir -p "$BASE_DIR/marketing-playbook"
cat << EOF > "$BASE_DIR/marketing-playbook/README.md"
# Marketing Playbook

Strategic documentation for ad targeting, campaign metrics, performance breakdowns, and monetization planning. Includes platform-specific insights for Meta, YouTube, and more.
EOF

mkdir -p "$BASE_DIR/ai-tools-workflow"
cat << EOF > "$BASE_DIR/ai-tools-workflow/README.md"
# AI Tools Workflow

Breakdown of AI model usage, ComfyUI templates, generation workflows, and prompt-testing notes. Focused on locally run tools like LTXV, Wan 2.1, Suno, and Hedra integrations.
EOF

mkdir -p "$BASE_DIR/grounding-prompts"
cat << EOF > "$BASE_DIR/grounding-prompts/README.md"
# Grounding Prompts

Custom storytelling prompts, visual/musical inspiration cues, and Jim-style AI generation structures. Designed to help maintain clarity, consistency, and brand tone across all projects.
EOF

echo "✅ README.md files created for all subdirectories."

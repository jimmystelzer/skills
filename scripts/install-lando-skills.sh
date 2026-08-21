#!/bin/bash

# Install all skills using Lando
# Usage: ./scripts/install-lando-skills.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
PLUGIN_JSON="$ROOT_DIR/.claude-plugin/plugin.json"

if [ ! -f "$PLUGIN_JSON" ]; then
    echo "Error: plugin.json not found at $PLUGIN_JSON"
    exit 1
fi

# Extract skills from plugin.json and remove ./skills/ prefix
SKILLS=$(grep -oP '"\./skills/\K[^"]+' "$PLUGIN_JSON")

if [ -z "$SKILLS" ]; then
    echo "No skills found in plugin.json"
    exit 1
fi

echo "Installing skills from jimmy/skills..."
echo ""

count=0
total=$(echo "$SKILLS" | wc -l)

while IFS= read -r skill; do
    count=$((count + 1))
    echo "[$count/$total] Installing $skill..."
    lando artisan boost:add-skill jimmy/skills --skill "$skill"
    echo ""
done <<< "$SKILLS"

echo "Done! Installed $count skills."

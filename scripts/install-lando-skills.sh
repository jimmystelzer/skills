#!/bin/bash

# Install all skills using Lando
# Usage: ./scripts/install-lando-skills.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
SKILLS_DIR="$ROOT_DIR/skills"

if [ ! -d "$SKILLS_DIR" ]; then
    echo "Error: skills directory not found at $SKILLS_DIR"
    exit 1
fi

# Find all SKILL.md files and extract relative paths
SKILLS=$(find "$SKILLS_DIR" -name "SKILL.md" -printf "%P\n" | sed 's|/SKILL.md||' | sort)

if [ -z "$SKILLS" ]; then
    echo "No skills found"
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

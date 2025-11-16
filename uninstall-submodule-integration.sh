#!/bin/bash
# Kintsugi Agent - Submodule Integration Cleanup
# This script removes all kintsugi-agent symlinks from the parent project

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Detect if we're running from within a submodule
if git rev-parse --show-superproject-working-tree > /dev/null 2>&1; then
    PARENT_ROOT="$(git rev-parse --show-superproject-working-tree)"
else
    echo -e "${RED}Error: This script should be run from within a git submodule${NC}"
    exit 1
fi

echo -e "${YELLOW}Kintsugi Agent Submodule Cleanup${NC}"
echo "Parent project: $PARENT_ROOT"
echo ""

# Find and remove all kintsugi-prefixed symlinks
removed=0

# Check .claude directory
if [ -d "$PARENT_ROOT/.claude" ]; then
    for dir in agents commands output-styles status_lines hooks; do
        if [ -d "$PARENT_ROOT/.claude/$dir" ]; then
            for link in "$PARENT_ROOT/.claude/$dir"/kintsugi-*; do
                if [ -L "$link" ]; then
                    echo -e "${GREEN}Removing: .claude/$dir/$(basename "$link")${NC}"
                    rm "$link"
                    ((removed++))
                fi
            done
        fi
    done
fi

# Check ai_docs directory
if [ -d "$PARENT_ROOT/ai_docs" ]; then
    for link in "$PARENT_ROOT/ai_docs"/kintsugi-*; do
        if [ -L "$link" ]; then
            echo -e "${GREEN}Removing: ai_docs/$(basename "$link")${NC}"
            rm "$link"
            ((removed++))
        fi
    done
fi

echo ""
if [ $removed -gt 0 ]; then
    echo -e "${GREEN}Removed $removed kintsugi-agent symlink(s)${NC}"
else
    echo -e "${YELLOW}No kintsugi-agent symlinks found${NC}"
fi
echo ""

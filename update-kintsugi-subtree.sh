#!/bin/bash
# Kintsugi Agent - Update Subtree Integration
# Quick script to update kintsugi-agent subtree and re-integrate files

set -e

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

REPO_URL="${KINTSUGI_REPO_URL:-https://github.com/ThePharmer/kintsugi-agent.git}"
BRANCH="${KINTSUGI_BRANCH:-main}"
SUBTREE_DIR=".claude/kintsugi-source"

echo -e "${CYAN}Updating kintsugi-agent subtree...${NC}"
git subtree pull --prefix="$SUBTREE_DIR" "$REPO_URL" "$BRANCH" --squash -m "Update kintsugi-agent subtree"

echo ""
echo -e "${GREEN}✓ Subtree updated!${NC}"
echo ""
echo "Re-run setup script to copy updated files:"
echo "  ./setup-subtree-integration.sh"

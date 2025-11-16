#!/bin/bash
# Kintsugi Agent - Git Subtree Integration Setup
# This script integrates kintsugi-agent into a parent project using git subtree

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="${KINTSUGI_REPO_URL:-https://github.com/ThePharmer/kintsugi-agent.git}"
BRANCH="${KINTSUGI_BRANCH:-main}"
PREFIX="${KINTSUGI_PREFIX:-kintsugi-}"
SUBTREE_DIR=".claude/kintsugi-source"

echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   Kintsugi Agent - Git Subtree Integration Setup      ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Error: Not in a git repository${NC}"
    echo "Please run this script from the root of your git repository"
    exit 1
fi

PROJECT_ROOT="$(git rev-parse --show-toplevel)"
cd "$PROJECT_ROOT"

echo -e "${BLUE}Project root:${NC} $PROJECT_ROOT"
echo -e "${BLUE}Repository:${NC} $REPO_URL"
echo -e "${BLUE}Branch:${NC} $BRANCH"
echo -e "${BLUE}Prefix:${NC} $PREFIX"
echo ""

# Ask user for integration mode
echo -e "${YELLOW}Choose integration mode:${NC}"
echo "  1) Direct merge - Copy agents/commands directly into .claude/ (RECOMMENDED)"
echo "  2) Subtree directory - Keep in separate directory with symlinks (like submodule)"
echo ""
read -p "Enter choice [1]: " INTEGRATION_MODE
INTEGRATION_MODE="${INTEGRATION_MODE:-1}"

if [ "$INTEGRATION_MODE" = "1" ]; then
    echo -e "${GREEN}Using direct merge mode${NC}"
    USE_DIRECT_MERGE=true
else
    echo -e "${GREEN}Using subtree directory mode${NC}"
    USE_DIRECT_MERGE=false
fi
echo ""

# Function to copy files with prefix
copy_with_prefix() {
    local source_dir=$1
    local target_dir=$2
    local resource_name=$3

    if [ ! -d "$source_dir" ]; then
        echo -e "${YELLOW}  ⊘ Skipping $resource_name (not found)${NC}"
        return
    fi

    mkdir -p "$target_dir"
    local copied=0

    for item in "$source_dir"/*; do
        if [ -e "$item" ]; then
            local item_name="$(basename "$item")"
            local target="$target_dir/${PREFIX}${item_name}"

            if [ -e "$target" ]; then
                echo -e "${YELLOW}  ↻ Updating: ${PREFIX}${item_name}${NC}"
                cp -r "$item" "$target"
            else
                echo -e "${GREEN}  ✓ Copying: ${PREFIX}${item_name}${NC}"
                cp -r "$item" "$target"
                ((copied++))
            fi
        fi
    done

    if [ $copied -eq 0 ]; then
        echo -e "${YELLOW}  ⊘ No new items copied${NC}"
    fi
}

# Check if subtree already exists
if git log --all --oneline | grep -q "git-subtree-dir: $SUBTREE_DIR"; then
    echo -e "${YELLOW}Subtree already exists. Pulling latest changes...${NC}"
    git subtree pull --prefix="$SUBTREE_DIR" "$REPO_URL" "$BRANCH" --squash -m "Update kintsugi-agent subtree"
else
    echo -e "${GREEN}Adding kintsugi-agent as subtree...${NC}"
    git subtree add --prefix="$SUBTREE_DIR" "$REPO_URL" "$BRANCH" --squash -m "Add kintsugi-agent subtree"
fi

echo ""

if [ "$USE_DIRECT_MERGE" = true ]; then
    # Direct merge mode - copy files into .claude/
    echo -e "${GREEN}Integrating resources into .claude/...${NC}"
    echo ""

    # Copy agents
    echo -e "${CYAN}Copying Agents...${NC}"
    copy_with_prefix "$SUBTREE_DIR/.claude/agents" ".claude/agents" "Agents"

    # Handle crypto subdirectory
    if [ -d "$SUBTREE_DIR/.claude/agents/crypto" ]; then
        mkdir -p ".claude/agents/crypto"
        for agent in "$SUBTREE_DIR/.claude/agents/crypto"/*; do
            if [ -f "$agent" ]; then
                agent_name="$(basename "$agent")"
                target=".claude/agents/crypto/${PREFIX}${agent_name}"
                if [ -e "$target" ]; then
                    echo -e "${YELLOW}  ↻ Updating: crypto/${PREFIX}${agent_name}${NC}"
                else
                    echo -e "${GREEN}  ✓ Copying: crypto/${PREFIX}${agent_name}${NC}"
                fi
                cp "$agent" "$target"
            fi
        done
    fi

    echo ""

    # Copy commands
    echo -e "${CYAN}Copying Commands...${NC}"
    copy_with_prefix "$SUBTREE_DIR/.claude/commands" ".claude/commands" "Commands"
    echo ""

    # Copy output styles
    echo -e "${CYAN}Copying Output Styles...${NC}"
    copy_with_prefix "$SUBTREE_DIR/.claude/output-styles" ".claude/output-styles" "Output Styles"
    echo ""

    # Copy status lines (optional)
    echo -e "${CYAN}Copying Status Lines (optional)...${NC}"
    copy_with_prefix "$SUBTREE_DIR/.claude/status_lines" ".claude/status_lines" "Status Lines"
    echo ""

    # Copy documentation
    echo -e "${CYAN}Copying Documentation...${NC}"
    if [ -d "$SUBTREE_DIR/ai_docs" ]; then
        mkdir -p "ai_docs"
        for doc in "$SUBTREE_DIR/ai_docs"/*; do
            if [ -f "$doc" ]; then
                doc_name="$(basename "$doc")"
                target="ai_docs/${PREFIX}${doc_name}"
                if [ -e "$target" ]; then
                    echo -e "${YELLOW}  ↻ Updating: ${PREFIX}${doc_name}${NC}"
                else
                    echo -e "${GREEN}  ✓ Copying: ${PREFIX}${doc_name}${NC}"
                fi
                cp "$doc" "$target"
            fi
        done
    fi

    echo ""
    echo -e "${GREEN}Staging changes to git...${NC}"
    git add .claude/agents .claude/commands .claude/output-styles .claude/status_lines ai_docs 2>/dev/null || true

else
    # Subtree directory mode - create symlinks
    echo -e "${GREEN}Creating symlinks from $SUBTREE_DIR...${NC}"
    echo ""

    # This is similar to submodule approach but using subtree
    echo -e "${CYAN}Linking Agents...${NC}"
    mkdir -p ".claude/agents"
    for agent in "$SUBTREE_DIR/.claude/agents"/*.md; do
        if [ -f "$agent" ]; then
            agent_name="$(basename "$agent")"
            target=".claude/agents/${PREFIX}${agent_name}"
            if [ -L "$target" ]; then
                echo -e "${YELLOW}  ↻ Already linked: ${PREFIX}${agent_name}${NC}"
            else
                rel_path="$(realpath --relative-to=".claude/agents" "$agent")"
                ln -s "$rel_path" "$target"
                echo -e "${GREEN}  ✓ Linked: ${PREFIX}${agent_name}${NC}"
            fi
        fi
    done
fi

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Integration Complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""

if [ "$USE_DIRECT_MERGE" = true ]; then
    echo "All kintsugi-agent resources have been copied into your .claude/ directory"
    echo "with '${PREFIX}' prefix to avoid naming conflicts."
    echo ""
    echo -e "${CYAN}Next steps:${NC}"
    echo "  1. Review the changes: git status"
    echo "  2. Commit the integration: git commit -m 'Integrate kintsugi-agent via subtree'"
    echo "  3. Use the resources: Agents, commands, and styles are now available!"
    echo ""
    echo -e "${CYAN}To update later:${NC}"
    echo "  ./setup-subtree-integration.sh  # Re-run this script to pull updates"
else
    echo "Symlinks created from $SUBTREE_DIR to .claude/ directories"
    echo ""
    echo -e "${CYAN}To update later:${NC}"
    echo "  git subtree pull --prefix='$SUBTREE_DIR' '$REPO_URL' '$BRANCH' --squash"
fi

echo ""
echo -e "${YELLOW}Note: Hooks are not auto-integrated for safety.${NC}"
echo "Review $SUBTREE_DIR/.claude/hooks/ and manually integrate if needed."
echo ""

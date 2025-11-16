#!/bin/bash
# Kintsugi Agent - Submodule Integration Setup
# This script integrates the kintsugi-agent submodule into a parent project's Claude Code setup

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Detect if we're running from within a submodule
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUBMODULE_NAME="$(basename "$SCRIPT_DIR")"

# Try to find the parent repo root
if git rev-parse --show-superproject-working-tree > /dev/null 2>&1; then
    PARENT_ROOT="$(git rev-parse --show-superproject-working-tree)"
    IS_SUBMODULE=true
else
    echo -e "${RED}Error: This script should be run from within a git submodule${NC}"
    echo "Usage: Add this repo as a submodule first, then run this script from within the submodule directory"
    exit 1
fi

echo -e "${GREEN}Kintsugi Agent Submodule Integration${NC}"
echo "Parent project: $PARENT_ROOT"
echo "Submodule path: $SCRIPT_DIR"
echo ""

# Ensure parent has .claude directory
mkdir -p "$PARENT_ROOT/.claude"

# Resources to integrate
declare -A RESOURCES=(
    ["agents"]="Agents"
    ["commands"]="Slash Commands"
    ["output-styles"]="Output Styles"
)

# Optional resources (may not exist in parent)
declare -A OPTIONAL_RESOURCES=(
    ["status_lines"]="Status Lines"
    ["hooks"]="Hooks"
)

echo "Starting integration..."
echo ""

# Function to create symlink or copy
integrate_resource() {
    local resource=$1
    local display_name=$2
    local source="$SCRIPT_DIR/.claude/$resource"
    local target_base="$PARENT_ROOT/.claude/$resource"

    if [ ! -d "$source" ]; then
        echo -e "${YELLOW}⊘ Skipping $display_name (not found in submodule)${NC}"
        return
    fi

    # Create target directory if it doesn't exist
    mkdir -p "$target_base"

    # Link each item from submodule into parent
    local linked=0
    for item in "$source"/*; do
        if [ -e "$item" ]; then
            local item_name="$(basename "$item")"
            local target="$target_base/kintsugi-$item_name"

            # Check if already linked
            if [ -L "$target" ]; then
                echo -e "${YELLOW}  ↻ Already linked: $resource/kintsugi-$item_name${NC}"
            elif [ -e "$target" ]; then
                echo -e "${YELLOW}  ⚠ File exists (skipping): $resource/kintsugi-$item_name${NC}"
            else
                # Create relative symlink
                local rel_path="$(realpath --relative-to="$(dirname "$target")" "$item")"
                ln -s "$rel_path" "$target"
                echo -e "${GREEN}  ✓ Linked: $resource/kintsugi-$item_name${NC}"
                ((linked++))
            fi
        fi
    done

    if [ $linked -eq 0 ]; then
        echo -e "${YELLOW}  ⊘ No new items linked${NC}"
    fi
}

# Integrate main resources
for resource in "${!RESOURCES[@]}"; do
    echo -e "${GREEN}Integrating ${RESOURCES[$resource]}...${NC}"
    integrate_resource "$resource" "${RESOURCES[$resource]}"
done

# Integrate optional resources
echo ""
for resource in "${!OPTIONAL_RESOURCES[@]}"; do
    echo -e "${GREEN}Integrating ${OPTIONAL_RESOURCES[$resource]} (optional)...${NC}"
    integrate_resource "$resource" "${OPTIONAL_RESOURCES[$resource]}"
done

# Copy ai_docs if desired (documentation reference)
echo ""
echo -e "${GREEN}Documentation Integration...${NC}"
if [ -d "$SCRIPT_DIR/ai_docs" ]; then
    mkdir -p "$PARENT_ROOT/ai_docs"

    for doc in "$SCRIPT_DIR/ai_docs"/*; do
        if [ -f "$doc" ]; then
            doc_name="$(basename "$doc")"
            target="$PARENT_ROOT/ai_docs/kintsugi-$doc_name"

            if [ -L "$target" ]; then
                echo -e "${YELLOW}  ↻ Already linked: ai_docs/kintsugi-$doc_name${NC}"
            elif [ -e "$target" ]; then
                echo -e "${YELLOW}  ⚠ File exists (skipping): ai_docs/kintsugi-$doc_name${NC}"
            else
                rel_path="$(realpath --relative-to="$PARENT_ROOT/ai_docs" "$doc")"
                ln -s "$rel_path" "$target"
                echo -e "${GREEN}  ✓ Linked: ai_docs/kintsugi-$doc_name${NC}"
            fi
        fi
    done
else
    echo -e "${YELLOW}  ⊘ No ai_docs found in submodule${NC}"
fi

echo ""
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}Integration Complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo ""
echo "All kintsugi-agent resources are now available in your parent project with 'kintsugi-' prefix."
echo ""
echo "Examples:"
echo "  • Agents: Use any kintsugi-prefixed agent from Claude Code"
echo "  • Commands: Run /kintsugi-<command-name>"
echo "  • Output Styles: /output-style kintsugi-<style-name>"
echo ""
echo "To update: Just pull changes in the submodule - symlinks will reflect updates automatically!"
echo ""
echo -e "${YELLOW}Note: Hooks are not auto-enabled. Review and manually integrate if needed.${NC}"

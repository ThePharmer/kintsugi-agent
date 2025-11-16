# Kintsugi Agent - Git Submodule Integration Guide

This guide explains how to use the kintsugi-agent repository as a **git submodule** in your own projects, allowing you to leverage all the agents, commands, and Claude Code configurations while keeping them updated from the source.

## Why Use as a Submodule?

✅ **Benefits:**
- Keep agents and commands updated automatically (just `git pull` the submodule)
- Share configurations across multiple projects
- Avoid code duplication
- Maintain a single source of truth for agent definitions
- Easy to update - changes propagate to all projects using the submodule

⚠️ **Challenge:**
Claude Code looks for `.claude/`, `ai_docs/`, and other directories in the **root** of your project. When you add kintsugi-agent as a submodule, these directories are nested inside the submodule path.

✨ **Solution:**
Use **selective symlinks** to integrate only the resources you want into your parent project's structure.

---

## Quick Start

### 1. Add as Submodule

Navigate to your project root and add kintsugi-agent as a submodule:

```bash
# Add submodule (choose your preferred location)
git submodule add https://github.com/ThePharmer/kintsugi-agent.git .claude/modules/kintsugi-agent

# Or in a different location
git submodule add https://github.com/ThePharmer/kintsugi-agent.git submodules/kintsugi-agent

# Initialize and update
git submodule update --init --recursive
```

### 2. Run Integration Script

Navigate into the submodule directory and run the setup script:

```bash
cd .claude/modules/kintsugi-agent  # or wherever you placed it
./setup-submodule-integration.sh
```

This will create symlinks in your parent project's `.claude/` directory for:
- ✓ Agents (`.claude/agents/kintsugi-*`)
- ✓ Commands (`.claude/commands/kintsugi-*`)
- ✓ Output Styles (`.claude/output-styles/kintsugi-*`)
- ✓ Status Lines (`.claude/status_lines/kintsugi-*`) [optional]
- ✓ Documentation (`ai_docs/kintsugi-*`)

**Note:** Hooks are NOT automatically integrated for safety. See "Hooks Integration" below.

### 3. Use the Resources

All kintsugi-agent resources are now available with a `kintsugi-` prefix:

```bash
# Use agents (Claude Code will see them)
"Use the kintsugi-crypto-coin-analyzer-sonnet agent to analyze BTC"

# Use slash commands
/kintsugi-crypto_research BTC

# Use output styles
/output-style kintsugi-genui
```

---

## Directory Structure After Integration

```
your-project/
├── .claude/
│   ├── modules/kintsugi-agent/          # Submodule directory
│   │   ├── .claude/
│   │   │   ├── agents/
│   │   │   ├── commands/
│   │   │   ├── hooks/
│   │   │   └── ...
│   │   └── ...
│   ├── agents/
│   │   ├── your-agent.md                # Your custom agents
│   │   ├── kintsugi-meta-agent.md       # Symlink to submodule
│   │   ├── kintsugi-crypto-*.md         # Symlinks to submodule
│   │   └── ...
│   ├── commands/
│   │   ├── your-command.md              # Your custom commands
│   │   ├── kintsugi-prime.md            # Symlink to submodule
│   │   └── ...
│   └── output-styles/
│       ├── kintsugi-genui.md            # Symlink to submodule
│       └── ...
└── ai_docs/
    ├── your-docs.md                     # Your documentation
    └── kintsugi-cc_hooks_docs.md        # Symlink to submodule
```

---

## Updating the Submodule

When kintsugi-agent releases updates, pull them into your project:

```bash
cd .claude/modules/kintsugi-agent
git pull origin main  # or whatever branch you're tracking

# Commit the submodule update in parent repo
cd ../../..  # back to parent root
git add .claude/modules/kintsugi-agent
git commit -m "Update kintsugi-agent submodule"
```

**No need to re-run setup script!** Symlinks automatically reflect the updated content.

---

## Hooks Integration

**⚠️ Hooks are NOT automatically integrated** because they can modify Claude Code's behavior significantly and may conflict with your existing hooks.

### Option A: Review and Cherry-Pick

1. Review available hooks:
   ```bash
   ls -la .claude/modules/kintsugi-agent/.claude/hooks/
   ```

2. Read the hook source code to understand what it does

3. Manually copy or symlink specific hooks you want:
   ```bash
   # Example: Use the session_start hook
   ln -s ../modules/kintsugi-agent/.claude/hooks/session_start.py .claude/hooks/kintsugi-session_start.py
   ```

4. Update `.claude/settings.json` to enable the hook:
   ```json
   {
     "hooks": {
       "session_start": {
         "command": [".claude/hooks/kintsugi-session_start.py"],
         "enabled": true
       }
     }
   }
   ```

### Option B: Merge Hook Logic

If you already have hooks, merge the kintsugi-agent hook logic into your existing hooks:

1. Read both your hook and the kintsugi hook
2. Combine the logic in your existing hook file
3. Test thoroughly

---

## Advanced Integration Patterns

### Pattern 1: Selective Integration

Only integrate specific resources you need:

```bash
# Link only crypto agents
ln -s ../../modules/kintsugi-agent/.claude/agents/crypto-*.md .claude/agents/

# Link only specific commands
ln -s ../../modules/kintsugi-agent/.claude/commands/prime.md .claude/commands/kintsugi-prime.md
```

### Pattern 2: Multiple Submodules

Use multiple agent repositories as submodules:

```
.claude/modules/
├── kintsugi-agent/      # This repo
├── security-agents/     # Another agent library
└── data-agents/         # Another agent library
```

Run each submodule's integration script - they'll coexist with appropriate prefixes.

### Pattern 3: Fork and Customize

1. Fork kintsugi-agent to your own GitHub
2. Add your fork as the submodule
3. Customize agents/commands as needed
4. Pull upstream updates when desired:
   ```bash
   git remote add upstream https://github.com/ThePharmer/kintsugi-agent.git
   git fetch upstream
   git merge upstream/main
   ```

---

## Cleanup / Uninstallation

To remove all kintsugi-agent integrations:

```bash
cd .claude/modules/kintsugi-agent
./uninstall-submodule-integration.sh
```

To completely remove the submodule:

```bash
# Remove symlinks first
cd .claude/modules/kintsugi-agent
./uninstall-submodule-integration.sh

# Remove submodule
cd ../../..  # back to parent root
git submodule deinit -f .claude/modules/kintsugi-agent
git rm -f .claude/modules/kintsugi-agent
rm -rf .git/modules/.claude/modules/kintsugi-agent
git commit -m "Remove kintsugi-agent submodule"
```

---

## Troubleshooting

### Issue: Agents not showing up in Claude Code

**Cause:** Symlinks may not have been created correctly.

**Solution:**
1. Check if symlinks exist:
   ```bash
   ls -la .claude/agents/kintsugi-*
   ```
2. Verify symlinks point to correct location:
   ```bash
   readlink .claude/agents/kintsugi-meta-agent.md
   ```
3. Re-run setup script:
   ```bash
   cd .claude/modules/kintsugi-agent
   ./setup-submodule-integration.sh
   ```

### Issue: Setup script fails with "not in a submodule"

**Cause:** Script must be run from within the submodule directory.

**Solution:**
```bash
# Correct - run FROM submodule directory
cd .claude/modules/kintsugi-agent
./setup-submodule-integration.sh

# Wrong - don't run from parent
./claude/modules/kintsugi-agent/setup-submodule-integration.sh
```

### Issue: Commands have name conflicts

**Cause:** Your project already has a command with the same name.

**Solution:**
The script uses `kintsugi-` prefix to avoid conflicts. If you still have issues:
1. Rename your existing command, or
2. Manually symlink with a different prefix:
   ```bash
   ln -s ../../modules/kintsugi-agent/.claude/commands/prime.md .claude/commands/ka-prime.md
   ```

### Issue: Updates to submodule not reflecting

**Cause:** You didn't pull the latest changes in the submodule.

**Solution:**
```bash
cd .claude/modules/kintsugi-agent
git pull origin main
```

Symlinks automatically reflect the updated files.

---

## Best Practices

1. **Use prefixes**: Keep the `kintsugi-` prefix to avoid naming conflicts
2. **Commit submodule updates**: Always commit submodule pointer updates in your parent repo
3. **Document your integration**: Note which kintsugi resources you're using in your project docs
4. **Test hooks carefully**: Never blindly enable hooks - review their code first
5. **Pin to commits for stability**: In production, pin submodule to specific commits rather than tracking `main`
   ```bash
   cd .claude/modules/kintsugi-agent
   git checkout <specific-commit-sha>
   cd ../../..
   git add .claude/modules/kintsugi-agent
   git commit -m "Pin kintsugi-agent to stable version"
   ```

---

## FAQ

**Q: Can I modify the agents in the submodule?**
A: You can, but those changes might be overwritten when you pull updates. Better to fork the repo or create your own agents that extend kintsugi agents.

**Q: Do I need to run the setup script after every submodule update?**
A: No! Symlinks automatically point to the latest content. Only re-run if you want to integrate newly added resources.

**Q: Can I use this on Windows?**
A: Symlinks work on Windows 10+ with Developer Mode enabled. Alternatively, use WSL2.

**Q: What if I want different agents in different projects?**
A: The setup script links ALL agents. For selective integration, manually create only the symlinks you want instead of using the script.

**Q: How do I contribute improvements back to kintsugi-agent?**
A: Make changes in your submodule, push to your fork, and open a PR to the main repo!

---

## Resources

- [Git Submodules Documentation](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
- [Claude Code Hooks Documentation](https://docs.anthropic.com/en/docs/claude-code/hooks)
- [Kintsugi Agent README](./README.md)
- [Claude Code Sub-Agents Guide](https://docs.anthropic.com/en/docs/claude-code/subagents)

---

## Support

For issues or questions:
- Open an issue on GitHub: https://github.com/ThePharmer/kintsugi-agent/issues
- Review the main [README.md](./README.md)
- Check the [CLAUDE.md](./CLAUDE.md) project notes

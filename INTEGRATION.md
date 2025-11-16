# Kintsugi Agent - Integration Guide

This guide explains how to integrate kintsugi-agent into your projects using either **git submodules** or **git subtrees**. Both approaches let you leverage all the agents, commands, and Claude Code configurations while keeping them updated from the source.

## Quick Decision: Which Approach?

| Factor | Git Subtree ⭐ | Git Submodule |
|--------|---------------|---------------|
| **Simplicity** | ✅ Simpler - files are just copied | ⚠️ Requires `git submodule` commands |
| **Clone experience** | ✅ Just `git clone` works | ⚠️ Requires `git clone --recursive` or init |
| **File integration** | ✅ Files copied directly, no symlinks | ⚠️ Requires symlinks (Windows issues) |
| **Updates** | ⚠️ Manual `git subtree pull` + re-run script | ✅ Just `git pull` in submodule |
| **Repository size** | ⚠️ Adds history to parent repo | ✅ Keeps histories separate |
| **Contributing back** | ⚠️ More complex (`git subtree push`) | ✅ Standard git workflow |
| **Cross-platform** | ✅ Works everywhere | ⚠️ Symlinks require Windows Dev Mode |
| **Recommended for** | Most users, simpler setup | Power users, active development |

**🎯 Recommendation:** Use **Git Subtree** for simpler setup and better cross-platform support. Use **Git Submodule** if you plan to contribute changes back to kintsugi-agent frequently.

---

## Approach 1: Git Subtree (Recommended)

**Best for:** Most users, simpler integration, cross-platform compatibility

Git subtree merges the kintsugi-agent repository into your project, allowing direct copying of files into your `.claude/` directory without symlinks.

### Quick Start (Subtree)

```bash
# Clone your project (nothing special needed!)
git clone your-project-url
cd your-project

# Run the subtree integration script
curl -O https://raw.githubusercontent.com/ThePharmer/kintsugi-agent/main/setup-subtree-integration.sh
chmod +x setup-subtree-integration.sh
./setup-subtree-integration.sh

# Follow prompts - choose "Direct merge" mode (recommended)
# This copies all agents, commands, and styles into your .claude/ directory

# Commit the integration
git add .
git commit -m "Integrate kintsugi-agent via subtree"
```

### What Happens (Subtree)

1. Creates `.claude/kintsugi-source/` containing the full kintsugi-agent repository
2. **Direct merge mode (recommended):** Copies agents, commands, and styles into your `.claude/` with `kintsugi-` prefix
3. Files are actual copies (not symlinks) - works on all platforms
4. Everything is tracked in your git repository

### Updating (Subtree)

```bash
# Pull latest changes from kintsugi-agent
./update-kintsugi-subtree.sh

# Re-run setup to copy updated files
./setup-subtree-integration.sh

# Commit updates
git add .
git commit -m "Update kintsugi-agent integration"
```

### Subtree Pros & Cons

✅ **Advantages:**
- **No symlinks** - Works on Windows without Developer Mode
- **Self-contained** - Everything in one repository
- **Simple cloning** - Team members just `git clone` normally
- **Direct file access** - Files are real copies in `.claude/`

⚠️ **Disadvantages:**
- **Manual updates** - Must run scripts to pull and copy new files
- **Larger repository** - Full kintsugi-agent history added (use `--squash` to minimize)
- **Duplication** - Files exist in both `.claude/kintsugi-source/` and `.claude/agents/`, etc.

---

## Approach 2: Git Submodule

**Best for:** Active developers, frequent contributors, those comfortable with git

Git submodule links to kintsugi-agent as a separate repository, using symlinks to integrate files into your `.claude/` directory.

### Quick Start (Submodule)

```bash
# Add submodule (choose your preferred location)
git submodule add https://github.com/ThePharmer/kintsugi-agent.git .claude/modules/kintsugi-agent

# Initialize and update
git submodule update --init --recursive

# Navigate into submodule and run setup
cd .claude/modules/kintsugi-agent
./setup-submodule-integration.sh

# Back to project root and commit
cd ../../..
git add .
git commit -m "Integrate kintsugi-agent via submodule"
```

### What Happens (Submodule)

1. `.claude/modules/kintsugi-agent/` added as linked repository
2. Symlinks created from your `.claude/agents/`, `.claude/commands/`, etc. to submodule files
3. All resources available with `kintsugi-` prefix
4. Changes to submodule automatically reflect via symlinks

### Updating (Submodule)

```bash
# Pull latest changes in the submodule
cd .claude/modules/kintsugi-agent
git pull origin main

# Commit submodule pointer update in parent
cd ../../..
git add .claude/modules/kintsugi-agent
git commit -m "Update kintsugi-agent submodule"
```

### Submodule Pros & Cons

✅ **Advantages:**
- **Easy updates** - Just `git pull` in submodule directory
- **Separate histories** - Parent repo stays smaller
- **Live updates** - Symlinks automatically reflect changes
- **Easy contribution** - Standard git workflow for contributing back

⚠️ **Disadvantages:**
- **Requires symlinks** - Windows needs Developer Mode enabled
- **Clone complexity** - Team needs `git clone --recursive` or `git submodule update --init`
- **Learning curve** - Submodules can be confusing for git beginners

---

## Detailed Submodule Instructions

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

### Removing Subtree Integration

```bash
# Remove copied files (with kintsugi- prefix)
git rm .claude/agents/kintsugi-*
git rm .claude/commands/kintsugi-*
git rm .claude/output-styles/kintsugi-*
git rm ai_docs/kintsugi-*

# Remove subtree source
git rm -r .claude/kintsugi-source

# Commit removal
git commit -m "Remove kintsugi-agent subtree integration"
```

### Removing Submodule Integration

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

**For Subtree:**
```bash
# Check if files were copied
ls -la .claude/agents/kintsugi-*

# Re-run setup to copy files again
./setup-subtree-integration.sh
```

**For Submodule:**
```bash
# Check if symlinks exist
ls -la .claude/agents/kintsugi-*

# Verify symlinks point correctly
readlink .claude/agents/kintsugi-meta-agent.md

# Re-run setup script
cd .claude/modules/kintsugi-agent
./setup-submodule-integration.sh
```

### Issue: Symlinks broken on Windows (Submodule only)

**Cause:** Windows requires Developer Mode for symlinks.

**Solution:**
1. Enable Windows Developer Mode:
   - Settings → Update & Security → For Developers → Developer Mode
2. Re-clone with symlink support:
   ```bash
   git clone -c core.symlinks=true <your-repo-url>
   ```
3. Or use Git Subtree instead (no symlinks needed!)

### Issue: git subtree command not found

**Cause:** Some git installations don't include git-subtree by default.

**Solution:**
```bash
# macOS
brew install git

# Ubuntu/Debian
sudo apt-get install git-subtree

# Or manually copy git-subtree script from git contrib
```

### Issue: Updates not reflecting (Subtree)

**Cause:** Subtree files are copies, not links.

**Solution:**
```bash
# Pull latest subtree changes
./update-kintsugi-subtree.sh

# Re-run setup to copy updated files
./setup-subtree-integration.sh

# Commit the updates
git add .
git commit -m "Update kintsugi-agent integration"
```

### Issue: Updates not reflecting (Submodule)

**Cause:** Didn't pull latest changes in submodule.

**Solution:**
```bash
cd .claude/modules/kintsugi-agent
git pull origin main
# Symlinks automatically reflect updated files!
```

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

**Q: Which approach should I use - subtree or submodule?**
A: Use **subtree** for simplicity and cross-platform support. Use **submodule** if you plan to contribute back to kintsugi-agent frequently or prefer smaller repos.

**Q: Can I modify the integrated agents?**
A:
- **Subtree:** Yes! They're copies in your repo. But updates will overwrite unless you handle merges carefully.
- **Submodule:** You can modify in the submodule directory and commit there, but updates may conflict.
- **Better:** Fork kintsugi-agent or create your own custom agents that build on these.

**Q: Do I need to re-run setup after updates?**
A:
- **Subtree:** YES - must re-run `setup-subtree-integration.sh` to copy updated files
- **Submodule:** NO - symlinks automatically reflect changes after `git pull`

**Q: Can I use this on Windows?**
A:
- **Subtree:** ✅ Yes! Works everywhere, no special setup needed
- **Submodule:** ⚠️ Requires Developer Mode for symlinks, or use WSL2

**Q: What if I only want specific agents, not all of them?**
A:
- **Subtree:** Edit the setup script or manually copy only the files you want
- **Submodule:** Manually create only the symlinks you need instead of using the automated script

**Q: How do I contribute improvements back to kintsugi-agent?**
A:
- **Subtree:** Use `git subtree push` (more complex) or manually create PRs from copied code
- **Submodule:** Standard workflow - commit in submodule, push to fork, open PR

**Q: Can I use both approaches?**
A: Technically yes, but don't! Choose one to avoid confusion and duplication.

**Q: What about team members cloning the repo?**
A:
- **Subtree:** ✅ `git clone` just works - everything is already there
- **Submodule:** ⚠️ Need `git clone --recursive` or `git submodule update --init`

---

## Resources

- [Git Submodules Documentation](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
- [Git Subtree Documentation](https://www.atlassian.com/git/tutorials/git-subtree)
- [Claude Code Hooks Documentation](https://docs.anthropic.com/en/docs/claude-code/hooks)
- [Kintsugi Agent README](./README.md)
- [Claude Code Sub-Agents Guide](https://docs.anthropic.com/en/docs/claude-code/subagents)

---

## Support

For issues or questions:
- Open an issue on GitHub: https://github.com/ThePharmer/kintsugi-agent/issues
- Review the main [README.md](./README.md)
- Check the [CLAUDE.md](./CLAUDE.md) project notes

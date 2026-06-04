---
name: openwolf
description: Automate OpenWolf project management tasks. Check anatomy.md freshness, detect unlogged bugs, suggest cerebrum updates, generate session summaries. Use when the user says "openwolf" or when you've been working on a project for a while and need to sync the knowledge base.
metadata:
  short-description: Automate OpenWolf — anatomy, buglog, cerebrum, memory
---

# OpenWolf — Context Management Automation

Automate the tedious parts of OpenWolf so you don't have to remember them.

## Commands

### `/openwolf check`

Scan for things that are out of sync:

| Check | How |
|-------|-----|
| **Anatomy stale?** | Compare file listing vs anatomy.md entries — files exist but not in anatomy? anatomy references deleted files? |
| **Unlogged bugs?** | Scan conversation: did you edit a file ≥2 times? did a command fail? did the user say "错了"/"不对"/"broken"? → suggest buglog entries |
| **Unlearned lessons?** | Did the user correct your approach? did you discover a new pattern? → suggest cerebrum entries |
| **Memory gap?** | Count significant actions since last memory.md entry → report how many are missing |

Output: a checklist with specific suggestions. Nothing auto-written, everything needs confirmation.

### `/openwolf update`

Execute the approved fixes from `check`:

1. **Anatomy**: add missing files, remove deleted ones, update token estimates
2. **Buglog**: write confirmed bug entries to `.wolf/buglog.json`
3. **Cerebrum**: add confirmed learnings/preferences/decisions to `.wolf/cerebrum.md`
4. **Memory**: append timestamped entries to `.wolf/memory.md`

### `/openwolf summary`

Generate and write session summary to `.wolf/memory.md`. Format:

```
| HH:MM | description | file(s) | outcome | ~tokens |
```

## Auto-Triggers (no command needed)

These should happen automatically during normal work:

**After every Edit/Write to a project file:**
- Count edits to the same file this session. If ≥2, mentally flag as potential bug.

**After creating/deleting/renaming a file:**
- Remind yourself: "anatomy.md needs update." Don't interrupt the user — just note it for the next `/openwolf check`.

**When user corrects you ("不对", "错了", "不要这样"):**
- Immediately flag this for cerebrum Do-Not-Repeat. After fixing, proactively suggest: "要不要记到 cerebrum 里？"

**Session end / user says "收工" / "wrap up":**
- Run `/openwolf check` silently, report findings in one sentence.
- If there are unlogged bugs or unlearned lessons, ask the user once. Don't nag.

## Rules

- **Never write to OpenWolf files without user confirmation** — check mode is read-only, update mode asks before writing
- **Buglog threshold is LOW** — edit same file ≥2 times = potential bug. Command failed = potential bug. User says "不对" = potential bug. Err on the side of logging.
- **Cerebrum threshold is LOW** — when in doubt, suggest it. A redundant entry costs nothing.
- **Don't interrupt the user** for anatomy or memory updates — batch them up
- **Don't be annoying** — one reminder at session end, not after every edit

# TestPostHook

A Claude Code project hook that automatically runs `pytest` after Claude edits any Python file, blocking the response if tests fail so Claude can fix the errors immediately.

## How It Works

Whenever Claude uses the `Edit` tool on a `.py` file, a `PostToolUse` hook fires and runs `pytest` against the project. If any tests fail, Claude's response is blocked and the full pytest output is injected back into the model's context — so Claude sees the failures and fixes them before continuing.

```
Claude edits foo.py
        ↓
PostToolUse hook fires
        ↓
pytest runs
        ↓
Pass → Claude continues normally
Fail → Claude is blocked, receives pytest output, fixes the code
```

## Files

```
.claude/
├── settings.json          # Registers the PostToolUse hook on the Edit matcher
└── hooks/
    └── pytest_check.sh    # Hook script: runs pytest and blocks on failure
```

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI
- Python with `pytest` installed (`pip install pytest`)
- `jq` available on `$PATH`

## Setup

Clone the repo and open it in Claude Code — the hook is active automatically via `.claude/settings.json`.

```bash
git clone <repo-url>
cd TestPostHook
claude
```

No additional configuration needed.

## Hook Behavior

| Situation | Hook output |
|---|---|
| Edited file is not `.py` | Silent pass (exit 0) |
| Tests pass | Silent pass (exit 0) |
| No tests collected (exit 5) | Silent pass (treated as passing) |
| Tests fail | Blocks Claude, injects pytest output as context |

## Customization

**Change the test command** — edit `.claude/hooks/pytest_check.sh` and replace `pytest` with your command (e.g. `pytest tests/ -x`).

**Also trigger on new files** — add `Write` to the matcher in `.claude/settings.json`:

```json
"matcher": "Write|Edit"
```

**Increase the timeout** — the default is 60 seconds. Adjust the `timeout` field in `.claude/settings.json` for slower test suites.

**Disable the hook** — open `/hooks` inside Claude Code or remove the `PostToolUse` entry from `.claude/settings.json`.

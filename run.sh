#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# run.sh — Claude Intelligence Dashboard
#
# Prerequisites:
#   Run 'brew install coreutils' to give you gtimeout
#
# Responsibilities:
#   1. Call Claude Code to fetch all 9 sources and write data.json
#      - use cheaper model claude-haiku-4-5-20251001 when calling Claude Code
#      - use --dangerously-skip-permissions to let Claude Code write data.json to disk
#   2. Validate and inject data.json into template.html → index.html
#   3. Commit and push to GitHub Pages
#   4. Delete data.json on success (keep on failure for inspection)
#
# Cron setup (twice daily, 8am and 6pm local time):
#   crontab -e
#   0 8,18 * * * /path/to/claude-pulse/run.sh >> /path/to/claude-pulse/run.log 2>&1
#
# Manual run:
#   cd /path/to/claude-pulse && ./run.sh
# ------------------------------------------------------------------------------

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo ""
echo "=== Claude Dashboard — $TIMESTAMP ==="

# ── 1. Ensure template exists ──────────────────────────────────────────────────
if [[ ! -f template.html ]]; then
  echo "ERROR: template.html not found. Aborting." >&2
  exit 1
fi

# ── 2. Clean up stale files from previous runs ─────────────────────────────────
rm -f index.html data.json

# ── 3. Run Claude Code — injects timestamp, streams progress, writes data.json ─
# Timeout at 900s (15 min) — generous for an ~8 min run; exits non-zero on expiry.
echo "Fetching sources..."
gtimeout 900s claude --dangerously-skip-permissions --model claude-haiku-4-5-20251001 --print "$(printf 'Current UTC timestamp: %s\n\n' "$TIMESTAMP"; cat PROMPT.md)"

# ── 4. Check data.json was written ────────────────────────────────────────────
if [[ ! -f data.json ]]; then
  echo "ERROR: data.json not found — Claude Code did not write output." >&2
  exit 1
fi
 
# ── 5. Validate JSON and print summary ────────────────────────────────────────
python3 -c "
import sys, json
data = json.load(open('data.json', encoding='utf-8'))
sources = data.get('sources', [])
ok   = sum(1 for s in sources if s.get('status') == 'ok')
err  = sum(1 for s in sources if s.get('status') == 'error')
items = sum(len(s.get('items', [])) for s in sources)
print(f'  Sources OK: {ok}  Errors: {err}  Items: {items}')
for s in sources:
    if s.get('status') == 'error':
        print(f'  ERROR [{s[\"abbr\"]}] {s.get(\"error\", \"unknown\")}')
"
 
# ── 6. Inject JSON into template → index.html ──────────────────────────────────
python3 -c "
import sys, json
template = open('template.html', encoding='utf-8').read()
json_data = open('data.json', encoding='utf-8').read()
# Validate it's parseable before injecting
json.loads(json_data)
marker = '/* INJECT */null/* /INJECT */'
count = template.count(marker)
if count != 1:
    sys.exit(f'ERROR: inject marker must appear exactly once in template.html (found {count})')
result = template.replace(marker, '/* INJECT */' + json_data.strip() + '/* /INJECT */')
open('index.html', 'w', encoding='utf-8').write(result)
print('  Written: index.html')
"

# ── 7. Commit and push to GitHub Pages ────────────────────────────────────────
# Remove commments if you want to have auto commit&push
# git add index.html
# git commit -m "dashboard: update $TIMESTAMP"
# git push

# ── 8. Clean up data.json on success ──────────────────────────────────────────
rm -f data.json
echo "=== Done ==="

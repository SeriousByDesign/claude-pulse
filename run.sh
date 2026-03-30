#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# run.sh — Claude Intelligence Dashboard data agent
#
# Runs Claude Code in non-interactive mode to fetch all 8 sources and write
# dashboard.html into the current directory.
#
# Cron setup (runs every hour):
#   crontab -e
#   0 * * * * /path/to/claude-dashboard-v2/run.sh >> /path/to/claude-dashboard-v2/run.log 2>&1
#
# Manual run:
#   cd /path/to/claude-dashboard-v2
#   ./run.sh
# ------------------------------------------------------------------------------

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo ""
echo "=== Claude Dashboard Agent — $(date -u '+%Y-%m-%dT%H:%M:%SZ') ==="

claude --print \
  --no-notifications \
  "$(cat PROMPT.md)"

echo "=== Done ==="

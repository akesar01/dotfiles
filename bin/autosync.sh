#!/usr/bin/env bash
# Commits and pushes any change in ~/dotfiles. Run every 5 min by launchd.
set -euo pipefail
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"
cd "$(dirname "$0")/.."
[ -z "$(git status --porcelain)" ] && exit 0
git add -A
git commit -q -m "auto-sync: $(date '+%Y-%m-%d %H:%M')"
git pull -q --rebase --autostash
git push -q
echo "$(date '+%F %T') pushed $(git rev-parse --short HEAD)"

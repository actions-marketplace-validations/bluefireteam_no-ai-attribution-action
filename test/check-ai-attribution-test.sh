#!/usr/bin/env bash

set -uo pipefail

script="$(dirname "$0")/../check-ai-attribution.sh"
failures=0

expect_flagged() {
  if printf '%s\n' "$1" | "$script" 2>/dev/null; then
    echo "Should have been flagged: $1"
    failures=$((failures + 1))
  fi
}

expect_allowed() {
  if ! printf '%s\n' "$1" | "$script" 2>/dev/null; then
    echo "Should have been allowed: $1"
    failures=$((failures + 1))
  fi
}

expect_flagged 'Co-authored-by: Claude <noreply@anthropic.com>'
expect_flagged 'co-authored-by: Codex <codex@openai.com>'
expect_flagged 'Co-authored-by: Copilot <175728472+Copilot@users.noreply.github.com>'
expect_flagged 'Co-authored-by: claude[bot] <209825114+claude[bot]@users.noreply.github.com>'
expect_flagged 'Co-authored-by: Cursor Agent <cursoragent@cursor.com>'
expect_flagged 'Author: Claude <noreply@anthropic.com>'
expect_flagged '🤖 Generated with [Claude Code](https://claude.ai/code)'
expect_flagged 'Made with Cursor'
expect_flagged 'https://claude.ai/code/session_01ABC'

expect_allowed 'Co-authored-by: Claude Shannon <claude@example.com>'
expect_allowed 'Author: Jane Doe <jane@example.com>'
expect_allowed 'This fixes a bug that Claude found in the collision code.'
expect_allowed 'Generated with a script'
expect_allowed ''

if [ "$failures" -gt 0 ]; then
  exit 1
fi
echo 'All tests passed'

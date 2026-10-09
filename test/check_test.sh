#!/usr/bin/env bash
set -uo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
fixture=$(mktemp)
trap 'rm -f "$fixture"' EXIT
failures=0

# writes a fixture with one commit whose author and committer are both $1
commit() {
  jq -n --arg author "$1" --arg message "$2" '
    ($author | capture("^(?<name>.*) <(?<email>.*)>$")) as $person
    | [{sha: "0123456789abcdef", commit: {author: $person, committer: $person, message: $message}}]
  ' > "$fixture"
}

run_check() {
  env PATH="$root/test/bin:$PATH" FIXTURE="$fixture" REPOSITORY=owner/repo \
    PR_NUMBER=1 COMMIT_COUNT=1 "$@" bash "$root/scripts/check.sh" 2>&1
}

# expect NAME STATUS OUTPUT_PATTERN [ENV...]
expect() {
  local name=$1 expected=$2 pattern=$3 output status
  shift 3
  output=$(run_check "$@")
  status=$?

  if [ "$status" -eq "$expected" ] && grep -Eq -- "$pattern" <<<"$output"; then
    echo "ok - $name"
  else
    echo "not ok - $name (exit $status, expected $expected)"
    while IFS= read -r line; do echo "    $line"; done <<<"$output"
    failures=$((failures + 1))
  fi
}

fails() {
  commit "$2" "$3"
  expect "$1" 1 "::error::commits found with an LLM tool"
}

passes() {
  commit "$2" "$3"
  expect "$1" 0 "No LLM attribution in 1 commits"
}

human="Jane Doe <jane@example.com>"

fails "fails for Claude co-author trailer" "$human" \
  $'fix lookup order\n\nCo-Authored-By: Claude Opus 5.5 (1M context) <noreply@anthropic.com>'
fails "fails for Claude Code footer" "$human" \
  $'fix lookup order\n\n🤖 Generated with [Claude Code](https://claude.com/claude-code)'
fails "fails for Copilot author" \
  "Copilot <198982749+Copilot@users.noreply.github.com>" "fix lookup order"
fails "fails for Jules author" \
  "google-labs-jules[bot] <161369871+google-labs-jules[bot]@users.noreply.github.com>" "fix lookup order"
fails "fails for Cursor co-author trailer" "$human" \
  $'fix lookup order\n\nCo-authored-by: Cursor Agent <cursoragent@cursor.com>'
fails "fails for Codex sign-off" "$human" \
  $'fix lookup order\n\nSigned-off-by: Codex <noreply@openai.com>'
fails "fails for Assisted-by trailer" "$human" \
  $'fix lookup order\n\nAssisted-by: Gemini'
fails "fails for aider prefix" "$human" "aider: fix lookup order"
fails "fails for aider author suffix" \
  "Jane Doe (aider) <jane@example.com>" "fix lookup order"
fails "fails for Replit trailer" "$human" \
  $'fix lookup order\n\nReplit-Commit-Author: Agent'

passes "passes for human commit" "$human" "fix lookup order"
passes "passes for tool mentioned in message" "$human" \
  $'add Claude API integration\n\nThe Copilot provider talks to OpenAI.'
passes "passes for human co-author named Devin" "$human" \
  $'fix lookup order\n\nCo-authored-by: Devin Smith <devin@example.com>'
passes "passes for human co-author named Claudette" "$human" \
  $'fix lookup order\n\nCo-authored-by: Claudette Roy <claudette@example.com>'
passes "passes for human sign-off" "$human" \
  $'fix lookup order\n\nSigned-off-by: Jane Doe <jane@example.com>'

commit "$human" $'::warning::injected\n\nCo-authored-by: Claude <noreply@anthropic.com>'
expect "disables workflow commands while printing commit lines" 1 \
  "^::stop-commands::[0-9a-f]{32}$"

commit "$human" "fix lookup order"
expect "fails without pull request" 1 "::error::not a pull request event" PR_NUMBER=
expect "fails for more than 250 commits" 1 "::error::too many commits" COMMIT_COUNT=251

if [ "$failures" -gt 0 ]; then
  echo "$failures failed"
  exit 1
fi

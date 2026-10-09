#!/usr/bin/env bash
set -euo pipefail

PATTERN=$(
  cat <<'EOF'
noreply@anthropic\.com
| cursoragent@cursor\.com
| noreply@cursor\.sh
| noreply@aider\.chat
| copilot@github\.com
| noreply@openai\.com
| @devin\.ai
| google-labs-jules
| github-copilot\[bot\]
| [0-9]+\+(claude|anthropic-claude|claude-code-action|copilot
    |cursor|openai-codex|chatgpt-codex-connector
    |gemini-code-assist|amazon-q-developer|devin-ai-integration
    |cline|continue|sourcegraph-cody|jetbrains-ai|coderabbitai)
  (\[bot\])?@users\.noreply\.github\.com
| ^(co-authored-by|co-developed-by|generated-by|signed-off-by)\s*:.*
  \b(claude|anthropic|copilot|cursor|aider|codex|chatgpt|openai
    |gemini|windsurf|codeium|cline|openhands|tabnine)\b
| ^assisted-by\s*:
| ^replit-commit-author\s*:\s*(agent|assistant)
| ^entire-[a-z-]+\s*:
| ^aider:\s
| ^(author|committer):\s.*(\(aider\)|\[aider\])
| generated\swith\s\[?(claude\scode|cursor|copilot)
EOF
)

if [ -z "${PR_NUMBER:-}" ]; then
  echo "::error::not a pull request event. Use this action in a workflow that runs on pull_request or pull_request_target."
  exit 1
fi

if [ "$COMMIT_COUNT" -gt 250 ]; then
  echo "::error::too many commits to check. The API lists at most 250 commits of a pull request. Split it into smaller pull requests. Got: $COMMIT_COUNT commits."
  exit 1
fi

commits=$(mktemp)
trap 'rm -f "$commits"' EXIT
gh api --paginate --slurp "repos/$REPOSITORY/pulls/$PR_NUMBER/commits?per_page=100" > "$commits"

matches=$(jq -r --arg re "$PATTERN" '
  add[]
  | .sha as $sha
  | ( "author: \(.commit.author.name) <\(.commit.author.email)>",
      "committer: \(.commit.committer.name) <\(.commit.committer.email)>",
      (.commit.message | split("\n")[]) )
  | select(test($re; "ix"))
  | "\($sha[0:12]) \(.)"
' "$commits")

if [ -n "$matches" ]; then
  # prevent commands in commit messages from being run
  token=$(openssl rand -hex 16)
  echo "::stop-commands::$token"
  printf '%s\n' "$matches"
  echo "::$token::"
  echo "::error::commits found with an LLM tool as author, committer or co-author."
  exit 1
fi

echo "No LLM attribution in $(jq 'add | length' "$commits") commits."

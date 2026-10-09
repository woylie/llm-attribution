# LLM attribution

GitHub Action that fails a pull request if one of its commits has an LLM
coding tool as its author, committer or co-author.

## Usage

Use the action in a workflow that runs on `pull_request` or
`pull_request_target`. It reads the commits through the GitHub API and does not
need a checkout.

```yaml
name: LLM attribution

on:
  pull_request:

permissions: {}

jobs:
  llm-attribution:
    name: LLM attribution
    runs-on: ubuntu-latest
    permissions:
      contents: read
      # to list the commits of the pull request
      pull-requests: read
    steps:
      - uses: woylie/llm-attribution@<sha>
```

The action runs with the token of the job it is in. Only give that job the
two permissions above.

To block merging, add the check as a required status check in a ruleset.

## What it detects

Each line of the commit message as well as the author and the committer are
checked. A commit fails the check if it has:

- the bot account or noreply address of a known tool, such as
  `Claude <noreply@anthropic.com>` or
  `Copilot <198982749+Copilot@users.noreply.github.com>`
- a `Co-authored-by`, `Co-developed-by`, `Generated-by` or `Signed-off-by`
  trailer of a known tool
- an `Assisted-by` trailer
- a trailer, footer or prefix that is only written by a known tool, such as
  `Generated with Claude Code`, the `aider:` prefix or `(aider)` after the
  author name

Mentioning a tool in the commit message does not fail the check, so
`Add Claude API integration` passes. A human co-author whose name is also the
name of a tool passes too, such as `Devin Smith`.

## Limitations

The GitHub API lists a maximum of 250 commits. A larger pull request fails the
check.

The check only finds attribution that is left in the commits. Anyone can remove
the trailers before pushing, and a pull request can change the workflow that
uses the action.

This is a test.

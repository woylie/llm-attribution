# Contributing

Thank you for your interest in the project!

## How can I contribute?

### Bug reports

If you encounter a bug, please search the issues for existing bug reports. If
the bug hasn't been reported yet, or in the case of a regression, open an issue
with the `bug report` template.

### Security vulnerabilities

If you discover a security vulnerability, please do not open an issue or a pull
request and refer to the [security policy](SECURITY.md) instead.

### Missed tools and false positives

If the check misses a commit written by an LLM tool, or fails a commit written
by a human, please open an issue. Include the commit line in question, such as
the trailer or the author, and link the documentation of the tool if there is
any.

### Feature requests

I'm open to feature requests, whether you intend to work on the implementation
yourself or not. It is always helpful to hear how you use a project and where
it falls short.

### Pull requests

Pull requests are generally appreciated. If you plan to add a new feature or
change an existing feature, please open an issue first.

A good documentation is essential, so please don't hesitate to open a PR to fix
a typo or to improve the wording of unclear, incomplete or ambiguous
instructions.

Please make sure to:

- Run `test/check_test.sh`, [shellcheck](https://www.shellcheck.net) and
  [zizmor](https://docs.zizmor.sh) locally before you push.
- When you change the pattern, add a test for each commit line it now catches,
  and for the human lines that it still lets through, such as
  `Co-authored-by: Devin Smith <devin@example.com>`.
- Document new and updated features (preferably with examples, if applicable).

Make sure to reference the issue in your PR (e.g. `resolves #123`).

The PR titles or commit messages don't follow any particular convention. Just
try to be concise, descriptive, and limit the first line of your commit message
72 characters or less. Commit messages should be in present tense
(e.g. "add option to set max length").

The changelog follows the format described at
[Keep a changelog](https://keepachangelog.com). If you introduce breaking
changes, upgrade instructions using the `diff` markdown syntax are appreciated.

### General questions

If you have general questions about the usage of the project, please open a
discussion on Github.

## Legal Notice

By contributing to this project, you agree that you have authored 100% of
the content, that you have the necessary rights to the content, and that the
content you contribute may be provided under the project license.

## AI / LLM Policy

Due to concerns about quality, ethics, and copyright, please do not submit
content written with the assistance of large language models (LLMs) or other AI
tools. This policy applies to all content, including but not limited to code,
documentation, issue and pull request descriptions, and comments.

You may use machine translation tools to translate texts from your native
language to English. Please mark such texts as machine-translated.

## Code of Conduct

By participating, you are expected to uphold the
[code of conduct](https://github.com/woylie/.github/blob/main/CODE_OF_CONDUCT.md).

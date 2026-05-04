# AI Usage

This project was developed with AI coding assistance. This document describes how AI tools were used and the policy for contributors.

## Tools Used

- **[Claude Code](https://claude.ai/code) (Anthropic)** — primary development assistant, used throughout the project for feature implementation, refactoring, test writing, and architectural decisions
- **[GitHub Copilot](https://github.com/features/copilot)** — inline code suggestions during editing

## How AI Was Used

- Feature implementation was guided by human design decisions; AI assisted with the code
- All AI-generated code was reviewed and tested before merging
- Tests were written before implementation (TDD), with AI assisting on both

## Policy for Contributors

AI-assisted contributions are welcome. Contributors are responsible for the correctness, security, and quality of code they submit, regardless of how it was produced. Specifically:

- All code must pass the test suite and linting (`bin/ci`) before being submitted
- AI-generated code must be reviewed and understood by the contributor — do not submit code you cannot explain or defend in a review
- Security-sensitive changes (authentication, file uploads, input validation) warrant extra scrutiny

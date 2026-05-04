# Contributing to Board Game Leaderboard

Thank you for your interest in contributing. This document covers how to report bugs, suggest features, and submit code changes.

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating you agree to abide by its terms.

## Reporting Bugs

Open a [GitHub Issue](https://github.com/VoxSecundus/board-game-leaderboard/issues/new?template=bug_report.md) using the bug report template. Please include:

- Steps to reproduce the problem
- What you expected to happen and what actually happened
- Your environment (Ruby version, OS, Docker or local)
- Any relevant log output

## Suggesting Features

Open a [GitHub Issue](https://github.com/VoxSecundus/board-game-leaderboard/issues/new?template=feature_request.md) using the feature request template. Describe the problem you want to solve and your proposed solution.

### Out of scope

To keep the project focused, the following are not planned and PRs for them will not be merged:

- BoardGameGeek API integration for auto-populating game data
- Multi-user authentication or per-user permissions
- At-rest database encryption

## Development Setup

Follow the [local setup instructions in the README](README.md#local-setup).

## Submitting a Pull Request

1. Fork the repository and create a branch from `master`
2. Write tests first — the project uses Minitest; add tests before implementing a change
3. Make your changes and ensure all tests pass
4. Run the full CI suite locally before pushing:

   ```bash
   bin/ci
   ```

5. Keep pull requests focused on a single change — separate unrelated fixes into separate PRs
6. Open a pull request against `master` using the pull request template

## Code Style

This project uses RuboCop with the `rubocop-rails-omakase` style guide. Auto-correct most offences with:

```bash
bin/rubocop -a
```

Fix any remaining offences manually before submitting.

## Commit Messages

- Use the imperative mood in the subject line ("Add feature" not "Added feature")
- Keep the subject line concise
- Do not add `Co-Authored-By` trailers

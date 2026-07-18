# Contributing to My Wallet IDs

Thanks for taking the time to contribute! This document covers everything
you need to get a change from idea to merged PR.

## Setup

1. Fork the repository on GitHub.
2. Clone your fork:
   ```bash
   git clone https://github.com/<your-username>/myWalletIDs-ios.git
   cd myWalletIDs-ios
   ```
3. Install the toolchain:
   ```bash
   brew install xcodegen
   ```
   (You also need Xcode 15+ — the app targets iOS 17.0.)
4. Generate and open the project:
   ```bash
   xcodegen generate
   open MyWalletIDs.xcodeproj
   ```
3. Never commit or hand-edit `MyWalletIDs.xcodeproj` — it is generated and
   gitignored. All project changes go through `project.yml`.

## Branch naming

Create branches from `main` using a type prefix:

| Prefix      | Use for                                  |
| ----------- | ---------------------------------------- |
| `feat/`     | New features (`feat/card-search`)        |
| `fix/`      | Bug fixes (`fix/flip-animation-glitch`)  |
| `docs/`     | Documentation only (`docs/readme-typos`) |
| `refactor/` | Code changes without behavior changes    |
| `chore/`    | Tooling, project config, housekeeping    |
| `test/`     | Adding or fixing tests                   |

## Commit messages — Conventional Commits

We use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<optional scope>): <imperative summary, lowercase, ≤72 chars>

<optional body explaining what and why>
```

Types: `feat`, `fix`, `docs`, `refactor`, `chore`, `test`, `perf`, `style`.

Examples:

```
feat(editor): add pattern picker with mini previews
fix(detail): keep flip state when a field is copied
docs: document imagestore file layout
chore: bump deployment target notes in project.yml
```

Keep one logical change per commit. Reference issues in the body when
relevant (`Fixes #12`).

## Pull request process

1. Make sure `xcodegen generate` runs cleanly and the app builds:
   ```bash
   xcodebuild -project MyWalletIDs.xcodeproj -scheme MyWalletIDs \
     -destination 'generic/platform=iOS Simulator' build
   ```
2. Fill in the PR template (summary, type of change, how it was tested).
3. Keep PRs focused — split unrelated changes into separate PRs.
4. A maintainer reviews, may request changes, and merges with a clean
   history (squash or rebase, no merge commits).

## Code style

- Swift API Design Guidelines; SwiftUI views as small composable structs.
- 4-space indentation, no trailing whitespace, files end with a newline.
- One type per file, file named after the type.
- Prefer `// MARK: -` sections in files with more than one concern.
- SwiftData models store enums as raw values with computed accessors — keep
  that convention for any new stored enum.
- UI strings in English, sentence case for body text, Title Case for
  navigation titles and buttons.
- No third-party dependencies without prior discussion in an issue.

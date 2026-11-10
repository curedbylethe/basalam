# basalam project rules

basalam is a retained-mode terminal user interface (TUI) library for the
[Salam](https://github.com/SalamLang/Salam) programming language. It is a
library, not an application: user programs import it. The repository also holds
the Mintlify documentation site (`*.mdx` at the root, `docs.json`).

These are the rules every change follows, agent or human. Details live in
[CONTRIBUTING.md](https://github.com/curedbylethe/basalam/blob/main/CONTRIBUTING.md),
[RELEASING.md](https://github.com/curedbylethe/basalam/blob/main/RELEASING.md), and
[basalam-api-glossary-fa.md](basalam-api-glossary-fa.md).

## Quality gates

| Command                  | What it proves                                                                                  |
| ------------------------ | ----------------------------------------------------------------------------------------------- |
| `make check`             | Format check, Persian aliases, strict LLVM build, strict LLVM examples, tests, doc examples      |
| `make test-llvm`         | Every test built with `--backend=llvm`; an LLVM codegen failure must fail, not fall back to C    |
| `make release-check`     | `basalam.Version`, `salam.toml`, the changelog headings, and the link definitions agree          |
| `make docs-check`        | MDX and frontmatter validation, then the link and anchor check                                   |
| `make docs-format-check` | `mint format` is idempotent on every committed page                                             |

- `make check` is the library gate. It does not include `test-llvm` or the docs
  job; run those when the change touches them.
- The docs gates compare against the git index. Stage page edits before running
  `make docs-check` or `make docs-format-check`.
- CI (`.github/workflows/ci.yml`) runs `make check` and `make test-llvm` on
  Ubuntu and macOS, with `make release-check` on the Linux leg, plus a docs job
  on Ubuntu. All three status checks (`check (ubuntu-latest)`,
  `check (macos-latest)`, `docs`) must pass before a pull request merges.
- A gate step that skips because a tool is missing on the machine is reported
  as skipped, never as a pass.

## Definition of done

A change is not finished until all of these are true:

- The gates above pass for what the change touched.
- Every file keeps the project header comment block and a module comment that
  says why the file exists, how it fits its neighbors, and what it does not do.
- Every new or changed public declaration carries `@en "English"` then
  `@fa "Persian"`, followed by its `///` doc comment, in that order. Both
  aliases are mandatory. `@fa` is documentation metadata, not an identifier:
  `salam doc --lang=fa` renders it, and code uses the English name.
- The name has a row in `basalam-api-glossary-fa.md` with its English form,
  meaning, and Persian alias. `make fa-aliases` fails when an `@en` has no
  `@fa`, an alias is empty, a `@fa` stands alone, or the glossary row count no
  longer matches the source.
- User-facing behavior changes update the English Mintlify pages, and a new
  page is registered in `docs.json` navigation. `salam doc --lang=fa`
  generates the Persian reference from the annotations.
- `CHANGELOG.md` carries one `[Unreleased]` entry per user-visible change, in
  the same change that introduces it. Moving entries into a dated section,
  bumping `basalam.Version` and the `salam.toml` version, and cutting a tag
  belong to a release change, not a feature change; `RELEASING.md` describes
  the release lane and `make release-check` enforces the agreement.

## Repository invariants

- `basalam/` is the library package. The compiler loads **every** `.salam` file
  in it, so no test, example, or scratch file may live there.
- `tests/` holds one program per test (`std/testing`, ending in
  `ret testing.Summary()`) and its `.out` golden file. `sh tests/run.sh <name>`
  builds it, runs it with empty stdin, and fails on a non-zero exit or a stdout
  difference. Tests never touch a real terminal.
- `examples/` holds runnable programs for newcomers and is built by
  `make examples`.
- `salam.toml` is the package manifest. Its only dependency is
  `github.com/curedbylethe/signal`, pinned by tag; adding a dependency is a
  design decision, not an incidental fix. `salam.lock` is consumer-side only
  and is not committed here.
- Terminal output goes through `std/term`. Never write escape sequences by
  hand.
- `salam format` is the authority; run `make format`. Indent with 4 spaces.
  Package-level functions are `PascalCase`; struct methods and fields are
  `snake_case`.
- `basalam/screen.salam` and `basalam/signal.salam` carry the Windows resize
  path. No CI job compiles or runs the Windows stubs, so a change to either
  file needs the manual Windows resize check in `CONTRIBUTING.md`, recorded in
  the pull request. Say so explicitly when no Windows machine was available.
- Never loosen a gate to land a change. Fix the cause, or report the failure.

## Branches, commits, pull requests

- Branch: `<prefix>/<short-slug>`, with `feature/`, `fix/`, `chore/`,
  `refactor/`, `docs/`, `style/`, `perf/`, `test/`, `build/`, or `ci/`.
- Commit: [Conventional Commits](https://www.conventionalcommits.org/) with an
  optional scope, imperative subject, and a body that says what changed and
  why. One logical change per commit; every commit leaves the tree green.
- Pull request body: Goal, What changed, Verification (commands and result),
  Acceptance criteria (a checklist with evidence per criterion), Follow-ups.
  Quote acceptance criteria verbatim; never paraphrase them.

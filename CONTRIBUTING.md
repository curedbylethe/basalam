# Contributing to basalam

Thank you for helping. This guide covers how to build, test, document, and
commit. By taking part you agree to follow the
[Code of Conduct](CODE_OF_CONDUCT.md).

## Set up

1. Install the Salam compiler, version 0.5.9 or later (`salam version` to
   check). See the [Salam repository](https://github.com/SalamLang/Salam)
   for the installer.
2. Clone the repository and run the full check:

   ```sh
   git clone https://github.com/curedbylethe/basalam
   cd basalam
   make check
   ```

## Common tasks

| Command                  | What it does                                                                                                    |
| ------------------------ | --------------------------------------------------------------------------------------------------------------- |
| `make build`             | Type-checks and compiles every file in `basalam/` with `--backend=llvm`                                         |
| `make test`              | Builds and runs the test suite                                                                                  |
| `make test-llvm`         | Builds and runs the test suite with `--backend=llvm`                                                            |
| `make examples`          | Builds every program in `examples/` into `build/examples/` with `--backend=llvm`                                |
| `make docs-examples`     | Type-checks every complete example in the documentation                                                         |
| `make run`               | Builds and runs the demo example                                                                                |
| `make format`            | Formats all Salam sources in place                                                                              |
| `make check`             | Format check, strict build and examples, tests, doc examples; CI adds `test-llvm` and the docs job               |
| `make release-check`     | Checks `basalam.Version`, the changelog headings, and the link definitions against [RELEASING.md](RELEASING.md)  |
| `make docs`              | Previews the documentation site (`npm i -g mint@4.2.988` first)                                                 |
| `make docs-check`        | Validates the documentation site and its links                                                                  |
| `make docs-format-check` | Fails if `mint format` would rewrite a docs page                                                                |

Set `SALAM=/path/to/salam` to use a compiler that is not on your `PATH`.

## Repository layout

- `basalam/` is the library. The compiler loads **every** `.salam` file in
  this directory as part of the package, so never put tests, examples, or
  scratch files here.
- `tests/` holds the test programs and their golden output.
- `examples/` holds runnable programs for newcomers.
- The `.mdx` files and `docs.json` at the root are the Mintlify
  documentation site.

## Tests

Tests follow the convention of Salam's own test corpus
(`tests/en/stdlib/*.salam` with `.out` golden files):

- `tests/<name>.salam` is a program that asserts with `std/testing` and ends
  with `ret testing.Summary()`.
- `tests/<name>.out` is its exact expected stdout.
- `tests/run.sh` builds each program, runs it with an empty stdin, and
  fails when the exit code is non-zero or stdout differs from the golden
  file. Failed assertions print `FAIL: ...` on stderr.

To add a test, write the program, run `sh tests/run.sh <name>`, check the
output is what you expect, and save it as `tests/<name>.out`.

Tests never touch a real terminal. Code that needs one (the screen's input
thread, raw mode) is kept thin so the logic around it can be tested
headlessly.

CI also runs `make test-llvm`, which builds every test with
`--backend=llvm`. The explicit backend now covers `make build` and
`make examples` as well, so an LLVM codegen failure fails those builds too
instead of falling back to C. CI covers Ubuntu and macOS; the Windows resize
path is a manual check (below).

### Windows resize check

CI runs Ubuntu and macOS only. On Windows, SIGWINCH does not exist, so the
input thread polls `term.Size()` every 20 ms instead of waiting for a signal.
The Windows stubs exist, but no CI job compiles or runs them. Before merging
a change that touches `basalam/screen.salam` or `basalam/signal.salam`, check
resize by hand on Windows:

1. Build and run `examples/demo.salam` with Salam 0.5.9 or newer. From Git
   Bash or MSYS2, `make run` is the usual path if the make toolchain is
   available; otherwise invoke the compiler directly.
2. Resize the terminal narrower and wider, then maximize and restore it.
3. Resize while an input is focused, and resize rapidly several times.
4. Confirm the layout reflows immediately (within a frame or two), with no
   stale bounds, clipped rows, or missed resize.
5. Record the result in the pull request: Windows version, terminal, and
   compiler version. If no Windows machine was available, say so explicitly.

## Code style

- `salam format` is the authority. Run `make format` before committing; CI
  rejects unformatted files.
- Indent with 4 spaces (`.editorconfig` matches the formatter).
- Follow the standard library's naming: package-level functions are
  `PascalCase`, struct methods and fields are `snake_case`.
- Never write terminal escape sequences by hand. Use `std/term`.

## Documentation is part of the change

A change is not finished until it is documented:

- Every file starts with the project header comment block, followed by a
  module comment that explains why the file exists, how it fits with its
  neighbors, and what it deliberately does not do.
- Every `pub` declaration carries an `@en "Name"` annotation (the English
  name alias the Salam language packs use) followed by a `///` doc comment.
  The doc comment must come **after** the annotation so `salam doc` picks it
  up.
- English only for now. Do not add `@fa` annotations unless a Persian
  speaker has reviewed them; they can be added later without code changes.
- Non-obvious algorithms get inline prose comments.
- User-facing behavior changes update the Mintlify pages (`*.mdx`) and,
  for new pages, `docs.json` navigation. A new or edited page must pass
  `make docs-check` and `make docs-format-check`, which CI enforces. The local
  gate compares against the index, so stage or commit page edits before
  running it.

## Commits

Use [Conventional Commits](https://www.conventionalcommits.org/), matching
the Salam project's style: `feat:`, `fix:`, `docs:`, `test:`, `refactor:`,
`chore:`, with an optional scope.

```
feat(widget): add Widget interface and BaseWidget
```

- Write the subject in the imperative mood.
- Write a body that explains what changed and why, the alternatives you
  rejected, and anything a future maintainer needs to know.
- Reference the issue identifier (for example `#184`).
- One logical change per commit. No "wip" or "fixes" commits.

## Reporting issues

Open an issue at https://github.com/curedbylethe/basalam/issues with the
Salam version (`salam version`), your OS and terminal, and the smallest
program that reproduces the problem.

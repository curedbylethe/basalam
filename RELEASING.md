# Releasing basalam

This is the release policy. It answers five questions — which version number, in
what tag form, who tags, when, and how the changelog is written — and ends with
the checklist. [`CHANGELOG.md`](CHANGELOG.md) records what shipped;
`tests/release-check.sh` enforces the parts a script can check.

Run `make release-check` before every release pull request. It is read-only, and
CI runs it on every pull request.

## Version numbers

basalam follows [Semantic Versioning 2.0.0](https://semver.org/spec/v2.0.0.html).
`basalam.Version` in `basalam/basalam.salam`, and its copy in `salam.toml`, are
the only machine-readable versions; the newest dated changelog heading and the
tag must equal them.

**Before 1.0 — versions are `0.y.z`.** The library is still finding its API, so:

- A **breaking** public-API change bumps `y`. Breaking means removing or renaming
  a public declaration, changing a signature, changing observable behaviour
  (draw order, focus order, what an event does), or raising the minimum Salam
  compiler version.
- A backward-compatible feature, and every bug fix, bumps `z`.
- Patch releases are safe to adopt without reading the diff. **Every minor
  release may break your code**; read the changelog before moving from `0.y` to
  `0.(y+1)`.

`1.0.0` is reserved for the point where the public API is declared stable. It is
not scheduled.

## Tags

- The tag is annotated and named `vX.Y.Z`, for example `v0.1.0`:
  `git tag -a v0.1.0 -m "basalam 0.1.0"`.
- Tag the release commit on `main` — the merge or squash commit of the release
  pull request, never a commit only on a branch. A release that targets an older
  line is the exception: tag it on that line's maintenance branch.
- A published tag is immutable. Never move it, delete it, or re-point it at
  another commit; if a release is wrong, publish a new patch.
- No `v`-less tags, and no pre-release suffixes (`-rc.1`, `+build`) until a
  policy for them exists.
- The historical `v0.1.0` tag predates this policy: it sits on the commit whose
  content matches `Version` (`3697630810610349227ff0ef9387e28fe51a5162`) and is
  published by manual dispatch, not by the tag push.

## Who releases

The repository owner (`curedbylethe`), or a maintainer who has been explicitly
given write access to the repository. There is no `CODEOWNERS` file: write access
is the gate. Release tags are pushed by that person and by nobody else.

## When to release

After the release pull request merges and `main` is green — not on a fixed
cadence. Ship when there is something worth shipping: a breaking change that
consumers need to adopt deliberately, a requested fix, or a coherent
consumer-facing feature set. There is no need to wait for a round number.

## The changelog

`CHANGELOG.md` follows [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/).

- `## [Unreleased]` is always present, and always the first section. Work in
  progress lands there, not in a dated section.
- A released version gets `## [X.Y.Z] - YYYY-MM-DD` (ISO date). The newest dated
  heading must equal `basalam.Version`.
- Subheadings are `### Added`, `### Changed`, `### Deprecated`, `### Removed`,
  `### Fixed`, and `### Security`, each in that order when present, plus the
  local `### Documentation` extension for docs-only user-visible changes. Use the
  standard headings unless the change genuinely has no home.
- A breaking entry starts with `**Breaking:**` and says what to do instead. This
  is what makes a `0.y` bump readable.
- Entries describe what a user of the library sees, not a commit dump. One entry
  per user-visible change; no "wip", no "various fixes".
- Reference the Linear issue where one exists: `(CUR-226)`.
- Every version has a link definition, and `[Unreleased]` links the comparison
  against the newest tag:

  ```markdown
  [Unreleased]: https://github.com/curedbylethe/basalam/compare/v0.1.0...HEAD
  [0.1.0]: https://github.com/curedbylethe/basalam/releases/tag/v0.1.0
  ```

- No empty release section: a dated heading needs at least one `###` subheading
  and one `-` entry.

**The changelog is hand-written.** Conventional Commits are a review convention;
they are not a release source. No tool generates entries, and the release
workflow extracts the section verbatim — it never rewrites or synthesizes text.

## Release checklist

1. Merge every change that belongs in the release; `main` is green.
2. Move the entries out of `[Unreleased]` into a new
   `## [X.Y.Z] - YYYY-MM-DD` section, chosen with the rules above.
3. Add a fresh, empty `## [Unreleased]` section at the top.
4. Update the link definitions: add `[X.Y.Z]`, and point `[Unreleased]` at
   `compare/vX.Y.Z...HEAD`.
5. Bump `Version` in `basalam/basalam.salam`, the `version` in `salam.toml`,
   and the version shown in `README.md`, `index.mdx`, and `quickstart.mdx`.
6. Run `make check`, `make test-llvm`, `make docs-check`,
   `make docs-format-check`, and `make release-check`. All five must pass.
7. Open the release pull request, review it, and merge it to `main`.
8. Tag the release commit on `main`:

   ```sh
   git checkout main && git pull
   git tag -a vX.Y.Z -m "basalam X.Y.Z"
   git push origin vX.Y.Z
   ```

9. The release workflow publishes the GitHub Release from the tag, using the
   changelog section as its notes.
10. Verify the release page, the attached source, and that `[X.Y.Z]` links
    resolve.

## Publishing by hand

The tag push triggers the release workflow. To publish a tag that was already
pushed — a failed publish, a retry, or the historical `v0.1.0` whose commit
predates the workflow — dispatch it:

```sh
gh workflow run release.yml --ref main -f tag=vX.Y.Z
```

That is the same as the **Run workflow** button on the workflow's page in the
GitHub UI, with `tag` set to the existing tag. The workflow validates the tagged
tree with `tests/release-check.sh tag vX.Y.Z` and prints the notes with
`tests/release-check.sh notes vX.Y.Z`.

## What the checker enforces

`make release-check` runs `tests/release-check.sh check` against the working
tree. It fails when:

- `Version` is missing, duplicated, or not plain `X.Y.Z`;
- `salam.toml` is missing from the working tree, or its `version` is not
  `Version`;
- there is not exactly one `## [Unreleased]` heading;
- the newest dated heading is not `Version`, or a version is dated twice;
- a dated version has no link definition, or one pointing somewhere other than
  this repository;
- the `[Unreleased]` comparison link is not `compare/vX.Y.Z...HEAD`;
- the section for `Version` has no subheading or no entry.

The release workflow runs the same script in `tag vX.Y.Z` mode, which reads the
tagged tree with `git show` rather than the working tree, requires an annotated
tag, and requires the tag to equal `v` + `Version`. A tag whose tree predates
`salam.toml` — `v0.1.0` through `v0.3.1` — skips the manifest comparison and
still validates. `notes vX.Y.Z` prints the section verbatim for the release
body.

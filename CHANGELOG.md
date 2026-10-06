# Changelog

All notable changes to basalam are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-10-06

Epic 1 (core): the foundation every later widget, layout, and keymap
release builds on.

### Added

- `Rect` and `Point`: integer cell geometry with half-open semantics,
  `contains`, `intersects`, `intersection`, `center`, `is_empty`, `right`,
  and `bottom`.
- `Widget` interface (`render`, `handle_event`, `focusable`, `bounds`,
  `set_bounds`) and `BaseWidget` with a default for every method, so a
  widget embeds it and overrides only what it needs.
- `Event` with `kind`, `key`, `mouse`, `width`, `height`, and the kinds
  `NoEvent`, `KeyEvent`, `MouseEvent`, `ResizeEvent`, `TickEvent`.
- Minimal `Buffer` and `Cell`: a clipped cell grid with `set`, `get`,
  `put_str`, `fill`, `clear`, `row_text`, and a `focused` render flag.
- `Event.is_key`, `Event.is_char`, and `Event.is_ctrl` helpers that check
  the kind and the key in one call.
- `Tree`: the widget registry with integer IDs (`RootId`, `NoWidget`),
  parent links, and `dispatch`, which offers an event to a widget and
  bubbles it up through its ancestors until one consumes it.
- Project scaffolding: GPL-3.0 license, `Makefile`, golden-file test runner,
  GitHub Actions CI, and the Mintlify documentation site.

[Unreleased]: https://github.com/curedbylethe/basalam/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/curedbylethe/basalam/releases/tag/v0.1.0

# Changelog

All notable changes to basalam are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `Screen.hit_test(x, y)`: the topmost widget (last painted) whose bounds
  contain a 0-based cell, or `NoWidget`.
- `Event.mouse_point()`: the 0-based cell of a `MouseEvent`, converted from
  the terminal's 1-based `mouse.col` and `mouse.row`.

### Changed

- `Screen.dispatch` routes a decoded `MouseEvent` to the widget under the
  cursor and bubbles from there. With no widget under the cursor it falls
  back to the focused widget. Every other event kind still starts at the
  focused widget.

### Documentation

- Resize detection polls `term.Size()` because Salam has no signal API (no
  `SIGWINCH`); the limitation and its trade-off (`PollMs`) are documented
  in the `screen.salam` module comment and the event-loop concept page.
- The event-loop, `Event`, and `Screen` pages cover mouse routing, mouse
  coordinates, and the decision to ship no key bindings.

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
- `Screen` with an asynchronous input thread and a synchronous main loop:
  `NewScreen`, `NewTerminalScreen`, `start`, `stop`, `close`,
  `next_event`, `dispatch`, `draw`, `present`, `post`, `run`,
  `run_with_tick`, `add`, `widget`, `fit_root`, `resize`, and the
  `tick_ms` and `mouse` options. Resize detection, tick events, mouse
  decoding, and terminal restore on every exit path.
- `Buffer.resize`, `Buffer.ansi`, and `Buffer.flush`: full-frame terminal
  output through `std/term`.
- `Channel<T>`, a wrapper that names `chan.Chan<T>` (compiler workaround).
- Focus system: a focus stack on `Screen` (`focus`,
  `push_focus`, `pop_focus`, `focused_id`, `can_focus`), linear
  navigation (`focus_next`, `focus_prev`), spatial navigation
  (`focus_up`, `focus_down`, `focus_left`, `focus_right`) backed by the
  pure `Nearest` search and the `DirUp`/`DirDown`/`DirLeft`/`DirRight`
  constants, auto-focus of the first focusable widget, and a redraw on
  every focus change.
- Examples: `examples/hello.salam` and `examples/demo.salam`.
- Project scaffolding: GPL-3.0 license, `Makefile`, golden-file test runner,
  GitHub Actions CI, and the Mintlify documentation site.

[Unreleased]: https://github.com/curedbylethe/basalam/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/curedbylethe/basalam/releases/tag/v0.1.0

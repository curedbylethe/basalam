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
- `Text`: the first concrete widget, with `NewText`, `set_text`,
  `set_align`, `set_style`, `set_wrap`, `render`, `preferred_size`, and
  `preferred_width`, plus the pure line rules `WrapText` and
  `MeasureText`, the `Alignment` enum, and the `WrapMode` enum.
- `Input`: a focusable single-line text-entry widget with `NewInput`,
  `set_value`, `set_placeholder`, `value`, `focusable`, and `render`, a
  reverse-video cursor cell drawn while focused, and a dim placeholder
  shown while the value is empty.
- `List`: a focusable, single-selection scrollable list widget with
  `NewList`, `selected_index`, `selected_item`, `on_select`, `focusable`, and
  `render`, a full-width highlighted selected row (reverse video while
  focused, bright black on a black background while not), vim `j`/`k`
  navigation clamped at the ends, and minimal scrolling that keeps the
  selection visible.
- `Widget.preferred_size`: the measurement hook a widget reports its wanted
  size through, with a cannot-measure default on `BaseWidget` that fills
  the available axis instead.
- `Row`, `Column`, `Grid`, and `Stack` containers with `NewRow`,
  `NewColumn`, `NewGrid`, and `NewStack`, the slot API (`add`,
  `set_margin`, `set_width`, `set_height`, `set_align`, `set_padding`, and
  Grid's `set_cell`), the `LayoutSlot`, `CrossAlign`, `SizeKind`,
  `LayoutSize`, and `Insets` types, and the box math `FitRect`,
  `InsetRect`, `SplitMain`, `TrackSizes`, `PlaceAxisSize`,
  `PlaceAxisOffset`, `NewInsets`, and `UniformInsets`. One `set_bounds` on
  a container lays out its whole subtree in slot order.
- `Buffer.front` and `Buffer.force_full`: the front grid (what the
  terminal currently shows) alongside the back grid widgets draw into, and
  the flag that makes the next `diff()` serialize the whole frame instead of
  the changed cells.
- `Buffer.diff()`: the bytes `flush()` writes — the whole frame while
  `force_full`, otherwise only the cells that differ from `front`.
- `Buffer.commit()`: copies the back grid into the front grid and clears
  `force_full`, so the next `diff()` reports only later changes.
- `Buffer.flush()`: now diff-based; writes only the changed cells (nothing
  when the grids already match) and then commits.
- Opt-in keymap: a `Keymap` of key and key-sequence bindings with
  `basalam.NewKeymap` and `basalam.NewDefaultKeymap`, global and per-widget
  scope through `bind`, `bind_for`, `bind_seq`, and `bind_for_seq`,
  `unbind`, and `handle`, exposed on the screen as `Screen.keymap` and
  installed or replaced with `Screen.set_keymap`. `NewDefaultKeymap` builds
  the library's stock map — Tab for `focus_next` and the four arrows for the
  spatial moves — and nothing installs it for you.

### Changed

- `Buffer.resize()` and `Screen.resize`: now reallocate both buffer grids
  and force a full repaint.
- `Screen.dispatch` routes a decoded `MouseEvent` to the widget under the
  cursor and bubbles from there. With no widget under the cursor it falls
  back to the focused widget. Every other event kind still starts at the
  focused widget.
- `Screen.dispatch` falls back to the screen's keymap for a `KeyEvent` no
  widget consumed, and returns `true` when the keymap consumes it. The
  keymap is empty by default, so a screen with none installed behaves as
  before.

### Documentation

- Resize detection polls `term.Size()` because Salam has no signal API (no
  `SIGWINCH`); the limitation and its trade-off (`PollMs`) are documented
  in the `screen.salam` module comment and the event-loop concept page.
- The event-loop, `Event`, and `Screen` pages cover mouse routing, mouse
  coordinates, and how an unconsumed `KeyEvent` reaches the opt-in keymap
  fallback; the `reference/keymap` page documents the keymap itself.
- Key repeat is documented: a held key arrives as repeated discrete
  `KeyEvent`s through the input loop; the library coalesces and drops
  nothing.

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

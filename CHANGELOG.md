# Changelog

All notable changes to basalam are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `Widget.visible()`: `true` when the widget is on screen, `false` when it is
  hidden. Focus eligibility asks every widget on the path to the root, so one
  hidden widget removes its whole subtree from focus navigation. The
  `BaseWidget` default returns `true`, so every widget that embeds `BaseWidget`
  keeps its behaviour; a hand-written widget adds `visible()` returning `true`.
  `Modal` reports its shared open state.
- `Screen.invalidate(id)`: queues a repaint of that widget's bounds. An
  unknown id, or an empty rect, marks the whole screen. Legal before
  `start()`. (CUR-226)
- `DrawBorder(buf, rect, border, style, title)`: paints a one-cell box-drawing
  ring (`BorderStyle.Single`, `Double`, or `Rounded`) with an optional title on
  the top edge, in one foreground color from `style.fg`. `BorderStyle.None`
  draws nothing.
- `Panel`: a single-child decorator that frames its child with a border ring,
  insets the child by `BorderInset`, reports a preferred size of the child plus
  that inset so it shrinks to fit in a `Row` or `Column`, and optionally takes
  focus. It has the fields `border`, `border_style`, `title`, `takes_focus`, and
  `focus_style`, and `add`, plus `preferred_size`. The focused frame paints in
  `focus_style` while the Panel has focus.
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
- `Button`: a focusable, one-row action widget drawn as `[ label ]`, with
  `NewButton`, `label`, `style`, `focus_style`, `disabled`, `on_click`,
  `focusable`, `hits`, `handle_event`, `preferred_size`, and `render`. Enter,
  Space, and a left click inside its bounds call `on_click`; a click moves no
  focus. Focus draws bold, or `focus_style` when set. A disabled button leaves
  the focus order and ignores input.
- `Checkbox`: a focusable, one-row boolean toggle drawn as `[x] label` or
  `[ ] label`, with `NewCheckbox`, `checked`, `set_checked`, `label`,
  `box_style`, `label_style`, `disabled`, `on_toggle`, `focusable`, `hits`,
  `handle_event`, `preferred_size`, and `render`. Space and a left click
  toggle it; Enter bubbles on.
- `Progress`: a one-row progress bar drawn into the buffer, with
  `NewProgress`, `progress`, `set_progress`, `set_max`, `fill_style`,
  `empty_style`, `text_style`, and `render`. The fill floors, so the bar is
  full only at 100%, and a five-cell percent tail shows when the width is at
  least six cells.
- `Table`: a non-focusable grid of single-line rows, with `NewTable`,
  `add_column`, `add_row`, `set_column_width`, `set_column_align`,
  `set_column_overflow`, `set_cell_align`, `set_pad_x`, `preferred_size`,
  `measure`, and `render`. Column widths are `LayoutSize` values, and star
  columns shrink first when the rect is narrow. An optional bold header and
  rule come from `header` and `rule`, and East Asian wide glyphs count as
  two cells.
- `Modal`: an overlay dialog drawn over a DIM scrim, with `NewModal`, `add`,
  `open`, `close`, `set_title`, `set_size`, `set_closable`, `set_bounds`,
  `bounds`, and `render`. While open it is the focus stop of its layer, it
  takes clicks on the scrim, and Esc closes it. The app raises and focuses
  it with `push_focus` then `raise_subtree`, and undoes both with
  `unraise_subtree` then `pop_focus`.
- `Separator`: a one-line horizontal or vertical rule, with `NewSeparator`,
  `set_orientation`, `set_ch`, `set_style`, `preferred_size`, `measure`, and
  `render`. `set_ch` takes exactly one cell wide rune: a wide or zero-width
  rune returns `false` and keeps the old one, and `""` resets to the default.
- `Widget.preferred_size`: the measurement hook a widget reports its wanted
  size through, with a cannot-measure default on `BaseWidget` that fills
  the available axis instead.
- `Row`, `Column`, `Grid`, and `Stack` containers with `NewRow`,
  `NewColumn`, `NewGrid`, and `NewStack`, the slot API (`add`,
  `set_margin`, `set_width`, `set_height`, `set_align`, `set_padding`,
  Row and Column `set_gap`, and Grid's `set_cell` and `set_span`), the
  `LayoutSlot` (`row_span`, `col_span`), `CrossAlign`, `SizeKind`,
  `LayoutSize` (`weight`), and `Insets` types, and the box math `FitRect`,
  `InsetRect`, `SplitMain`, `TrackSizes`, `PlaceAxisSize`,
  `PlaceAxisOffset`, `NewInsets`, and `UniformInsets`. One `set_bounds` on
  a container lays out its whole subtree in slot order. Main-axis `Fill`
  shares by `weight`, Row and Column reserve a `gap`, Grid slots span, and
  a measurable main-axis `Pref` is reserved at its measured size.
- `LayoutSize.weight` (default 1). Main-axis `Fill` shares by largest
  remainder. Ties go to the earliest slot. Weight 1 matches the old equal
  split.
- `Row.gap`, `Column.gap`, and `set_gap`. The gap budget is `(k-1)*gap`
  on the main axis, including zero-size slots. Negatives clamp to 0.
- `LayoutSlot.row_span`, `LayoutSlot.col_span` (default 1), and
  `Grid.set_span(i, rows, cols)`. A non-positive span is 1. The span
  clamps to the remaining tracks. An out-of-range origin is still a 0×0
  cell and ignores the span.
- `Axis`, `Measure`, and `Widget.measure`. Row and Column report a natural
  extent. Grid and Stack cannot measure. `BaseWidget.measure` returns
  not-ok.
- `Screen.raise` and `Screen.unraise`. One `raise` call is one layer (one
  shared stamp).
- `Widget.hits` (default true). A widget may paint and refuse hits.
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
- `Keymap.pending_timeout_ms`: a pending key sequence is abandoned when the
  next `KeyEvent` arrives later than this many milliseconds. It is evaluated
  lazily on the next key — never on a timer — defaults to `0` (never expires,
  the previous behavior), and nothing fires from the timeout alone.
- `Color`: the terminal color value type — `Default`, `Ansi`, `Indexed`, and
  `Rgb` — with the 16 palette constants `Black` through `BrightWhite`, and
  `FgSeq`/`BgSeq` for full-fidelity SGR encoding through `std/term`.
- `ColorTier` and `DetectTier`: the terminal's color capability (off, 16,
  256, or truecolor) read from `NO_COLOR`, `TERM`, `COLORTERM`, and
  `CLICOLOR_FORCE` only — uncached, pure, and tty-free.
- `Lower`, `FgSeqAt`, and `BgSeqAt`: emission-time downgrade of a color to a
  lower tier — RGB to the nearest 256-color index, RGB and indexed colors to
  the nearest ANSI color, and everything to `Default` when color is off.
- `Style`: the value type a cell is drawn with — a foreground and background
  `Color` and the four attributes `bold`, `dim`, `italic`, and `underline`,
  all defaulting to off/default — with `StyleDefault`, the constant of a
  style that asks for nothing.
- `StyleMerge(parent, child)`: sentinel-patch inheritance that resolves a
  child style over its parent. A child's color is used unless it is
  `Color.Default` (then the parent's is inherited) and each attribute is the
  OR of the two. A child can add an attribute or override a color, but cannot
  remove an inherited attribute or force the terminal default under a colored
  parent.
- `BorderStyle` (`None`, `Single`, `Double`, `Rounded`) and `BorderInset`:
  the sibling enum for a container's border kind and the cells a border costs
  on each side (0 for `None`, 1 otherwise). A value only; drawing the ring is
  a follow-up.
- `StyleEq`: value equality over a style's six stored fields. It needs no
  tier and errs toward "different", so a cell is never wrongly skipped and a
  tier change invalidates every cell.
- `StyleSgr` and `StyleSgrOff`: the SGR sequences that take a terminal from
  its default state to a style and back, at a given tier — attributes first
  in the fixed order bold, dim, italic, underline, then the foreground, then
  the background. Colors lower to the tier first and a color that is
  `Default` after lowering is skipped. Both return `""` when nothing is set
  and never emit a reset.
- `Screen.invalidate_subtree(id)`: queues one repaint region covering a widget
  and all of its descendants, instead of only the widget's own bounds as
  `Screen.invalidate(id)` does. The region is the bounding union, so a
  spread-out subtree also repaints the gaps between its rects. An unknown id,
  or a subtree whose rects are all empty, marks the whole screen. (CUR-456)
- `make test-llvm` builds and runs the test suite with `--backend=llvm`, so an
  LLVM codegen failure fails the build instead of falling back to the C
  backend; CI runs it on both platforms. (CUR-458)
- `Screen.mouse_motion`: when `true` before `start()`, the screen requests
  all-motion reporting, so a `MouseEvent` arrives as the pointer moves. It
  includes presses and releases, so it covers `mouse` on its own and the two
  are not needed together. Default off. `close()` releases every mouse mode,
  and reports are frequent: the channel holds 256 events, so a consumer slower
  than the terminal makes the input thread wait. The sequence is all-motion
  tracking (`?1003`). (CUR-425)

### Changed

- `Widget.visible()` now hides a widget and its whole subtree from painting and
  hit testing, not only from focus navigation. A hidden widget and its
  descendants are no longer drawn and no longer win `Screen.hit_test`.
- `make build` and `make examples` compile with `--backend=llvm`, so an LLVM
  codegen failure fails the build instead of falling back to the C backend.
  `make check` is strict for both. (CUR-464)
- The typed-style widgets and the Modal scrim cache the SGR strings they draw
  with and rebuild one only when the resolved style (or, for Modal's scrim,
  the underlying cell style) changes; `List` and `Input` build their default
  fallbacks once per process. Borders still build one per draw. Rendered bytes
  are unchanged. Cells still carry an SGR string; a typed cell style is
  separate work. (CUR-455)
- `make docs-check` validates the documentation site and its links in CI, so
  a broken page, a bad nav entry, or a dead link fails before merge. (CUR-453)
- `make docs-examples` type-checks every complete example in the documentation
  as part of `make check`, so a broken example fails before merge.
- `Screen.present()` and `Screen.draw()` return when nothing is pending. A widget that
  consumes an event queues its own bounds, and a focus change queues the
  old and new bounds. `dirty` still means a full repaint: resize, ticks
  from `run_with_tick`, `raise` / `unraise`, and a keymap-consumed key set
  it. A tick you dispatch yourself queues nothing, so mark the screen after
  changing state outside the widget tree. More than four
  pending regions, or regions covering more than half the screen, repaint
  every widget too. Those regions are each widget's own bounds, not its subtree.
  (CUR-226)
- `Buffer.diff()` and `Buffer.commit()` skip clean rows. `set`, `fill`,
  `put_str`, and `clear` mark the cells they write; assigning `cells`
  directly does not. Frame building reuses one string builder, and
  `put_str` no longer builds a vector of code points. (CUR-226)
- `Screen.raise_subtree(id)` and `Screen.unraise_subtree(id)`: raise or
  unraise a widget and all of its descendants as one layer, moving and
  restoring focus as `raise` and `unraise` do. A Modal uses them to stay
  above its own children.
- `Text.style` is now a `basalam.Style` value instead of a raw SGR string
  built with `std/term`, and `set_style` takes a `Style`. This is a breaking
  change at every `Text` style-construction site; the escape bytes a given
  palette color composes to are unchanged.
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
- A main-axis `Pref` that can measure is reserved at that size. A `Pref`
  that cannot measure still shares like `Fill` weight 1. A Column measures
  that Pref at the content width, because `preferred_size` takes a width.
- With nothing raised, paint order and focus order stay id order. After
  `raise`, paint order is ascending `(stamp, id)`, hit-test walks that
  order in reverse and skips `hits() == false`, and focus navigation stays
  inside the topmost layer's focusable widgets. `unraise` can restore the
  focus from before the layer.
- Resize detection now listens for `SIGWINCH` on POSIX: `start()` installs
  a handler, blocks the signal, and spawns a resize watcher that parks in
  `sigwait`, reads `term.Size()`, and sends a `ResizeEvent` only when the
  size changed. Windows keeps polling `term.Size()` on each input pass.
- Match arms use the Salam 0.5 form (`pattern: body end`) instead of the old
  `pattern => body`. 0.5.5 dropped the old form, because the compiler no
  longer parses it. The minimum compiler is now 0.5.6, which builds basalam's
  `dyn Widget` code with the LLVM backend; 0.5.5 required the C fallback.

### Documentation

- Resize detection is documented as signal-driven on POSIX and polled on
  Windows: the `SIGWINCH` watcher, the coalescing of rapid resizes, and the
  caveat about threads created before `start()` are covered in the
  `screen.salam` module comment and the event-loop concept page.
- The event-loop, `Event`, and `Screen` pages cover mouse routing, mouse
  coordinates, and how an unconsumed `KeyEvent` reaches the opt-in keymap
  fallback; the `reference/keymap` page documents the keymap itself.
- Key repeat is documented: a held key arrives as repeated discrete
  `KeyEvent`s through the input loop; the library coalesces and drops
  nothing.
- The `term.KeyEOF` once-then-stop behavior is documented: when stdin ends the input thread reports one `KeyEvent` and stops reading; the channel stays open and queued events are still delivered.
- The `reference/color` page documents the color value type, the palette,
  the SGR encodings, capability detection, and the downgrade ladder. The
  architecture, buffer, and text pages now state that the `Color` type exists
  while cells and widgets still carry raw SGR strings.
- The new `reference/style` page documents the `Style` value type, the
  `BorderStyle` and `BorderInset` pair, `StyleDefault`, `StyleMerge` and its
  limitations, `StyleEq`, and the `StyleSgr` / `StyleSgrOff` emission rules.
  The `reference/text`, `reference/color`, `reference/buffer`, and
  architecture pages now describe Text's `Style` interface and the
  cells-still-raw boundary.
- The layout, screen, widget, focus, and architecture pages describe weights,
  gap, measurement, grid spanning, and overlay order.

### Fixed

- Focus navigation skips every descendant of a hidden container. `can_focus`,
  `focus`, `push_focus`, `focus_next`, `focus_prev`, and the spatial methods
  consider only widgets whose whole ancestor chain reports `visible()`, so the
  child of a closed Modal is no longer reachable by `Tab`, `Shift-Tab`, or an
  arrow key.
- `Screen.hit_test`, `Screen.draw_full`, and `Screen.draw_regions` skip every
  id under a hidden ancestor, so a hidden widget and its descendants are
  neither hit-testable nor painted. `Screen.dispatch` revalidates the focus
  before routing and again after the widget chain returns: a focused id that
  became hidden moves to the first entry of the focus order, or the focus
  clears when the order is empty.

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

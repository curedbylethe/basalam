# Basalam API names — English and Persian

> Source: [`curedbylethe/basalam`](https://github.com/curedbylethe/basalam), default branch `main`, version **0.4.1** (inventory inspected 2026-11-08).

This file is the naming standard and the complete name inventory for basalam. Every declaration carries an English `@en` name and a Persian `@fa` alias; the inventory lists **533 entries** across **23 source modules**, all applied in the source and compiled by `make build`.

## What `@fa` is

`@en` and `@fa` are documentation metadata. The compiler parses the pair, and `salam doc --lang=fa` renders the Persian name beside the English one. They are **not identifiers**; this program does not compile:

```salam
r.width = 3   // correct
r.عرض = 3     // error[E016]: no field 'عرض' in struct 'Rect'
```

Write English names in code. Read the Persian name in the generated documentation.

## Annotation order

`@fa` sits directly under `@en`, and the `///` doc comment sits under both. `salam doc` reads the annotation pair above the declaration and the comment below it.

```salam
@en "Rect"
@fa "مستطیل"
/// An axis-aligned, half-open rectangle of terminal cells.
pub struct Rect:
    @en "width"
    @fa "عرض"
    /// Number of columns.
    pub width: int = 0
end
```

**Verification.** Every alias below is applied to the source, so `make build` proves it parses and type-checks. `salam doc --lang=fa` renders aliases for the declarations in its model. Salam 0.5.9 does not include enum variants in that model, so an alias on a variant such as `ColorTier.Ansi16` does not appear in generated docs; it still compiles, and the gate enforces it. `make fa-aliases` (part of `make check`) fails when an `@en` has no following `@fa`, when an alias is empty, when a `@fa` stands alone, or when the row count below no longer matches the source. No check covers spelling or meaning: a Persian speaker reviews new names.

## Adding a name

1. Choose the English name and annotate it with `@en`.
2. Choose the Persian alias from the standard below. Reuse the canonical term when one exists.
3. Put `@fa` directly under `@en`, and the `///` doc comment under both.
4. Add the row to the matching module table in this file.
5. Update the English reference page under `reference/`, and add it to `docs.json` when it is new.
6. Run `make fa-aliases`, `make build`, and `make docs-check`.

## Persian API naming standard

| Element | Convention | Example |
|---|---|---|
| Types and interfaces | Short, familiar nouns | `Widget` → `ویجت`; `Tree` → `درخت` |
| Fields / getters | Nouns without repeating the containing type | `Button.label` → `برچسب`; `Input.value` → `مقدار` |
| Constructors (`New*`) | Entity followed by `جدید` | `NewButton` → `دکمه جدید` |
| Mutators (`set_*`) | `تنظیم` plus the property | `set_bounds` → `تنظیم محدوده` |
| Boolean queries | Short predicates | `is_empty` → `خالی است`; `focusable` → `تمرکز‌پذیر است` |
| Action methods | Verbal nouns or short verbs | `render` → `ترسیم`; `add` → `افزودن` |
| Collections | Plural nouns | `widgets` → `ویجت‌ها`; `rows` → `ردیف‌ها` |
| Callbacks | `هنگام` plus the event | `on_click` → `هنگام کلیک` |
| Color/terminal jargon | Familiar technical language | `Buffer` → `بافر`; `ColorTier` → `سطح رنگ` |
| Shared/inherited methods | Identical spelling across implementations | Every `render` → `ترسیم` |

**Canonical terminology:** `Style` = `ظاهر`; `Border` = `کادر`; `Bounds` = `محدوده`; `Align` = `تراز`; `Padding` = `فاصله درونی`; `Margin` = `حاشیه بیرونی`; `Focus` = `تمرکز`; `Render` = `ترسیم`; `Measure` (method) = `اندازه‌گیری`; `Free` = `آزادسازی`. Technical loanwords (`ویجت`, `بافر`, `پنل`, `مودال`) remain when more useful than forced translations. Persian spaces and half-spaces are intentionally used where names are phrases.

**Persian form:** most aliases are translations. A settled technical word keeps its loanword (`ویجت`, `بافر`, `پنل`, `مودال`, `انسی`, `آرجی‌بی`, `باسلام`), and a few names are transliterations rather than translations (`Point.x` = `ایکس`, `Point.y` = `ایگرگ`).

**Meaning distinctions:** `Buffer.clear` = `پاک‌سازی` (clear cells); `Buffer.free` = `آزادسازی` (release storage); `Buffer.flush` = `ارسال به ترمینال` (emit and commit). `Widget.render` = `ترسیم` (render into a buffer); `Screen.draw` = `بازترسیم` (paint back buffer); `Screen.present` = `نمایش تغییرات` (draw and emit when attached). `Point` means a point, not the general idea of coordinates.

**Notation:** `Screen.focus_next` identifies a method or field; top-level functions/constants are unqualified; enum members are qualified by the enum. Some names may be identical in **different scopes** (e.g., `Row.add` and `Grid.add`); distinct declarations within the same scope have no duplicate Persian alias.

**Scope:** Every `@en`-annotated declaration in `basalam/`. Salam compiler keywords and standard-library APIs, implementation-only fields, test-only helpers, and examples are excluded. `Modal.state` is included because it is public, but its private element type makes it an implementation detail; prefer interacting with a modal through its methods.

## `basalam.salam` (2 entries)

[Source file](https://github.com/curedbylethe/basalam/blob/main/basalam/basalam.salam)

| Kind | English API name | Meaning / usage | Persian alias |
|---|---|---|---|
| Package | `basalam` | The library namespace | باسلام |
| Constant | `Version` | Semantic version string of the library | نسخه |

## `rect.salam` (15 entries)

[Source file](https://github.com/curedbylethe/basalam/blob/main/basalam/rect.salam)

| Kind | English API name | Meaning / usage | Persian alias |
|---|---|---|---|
| Type | `Point` | Cell-grid position | نقطه |
| Type | `Rect` | Half-open rectangular area in terminal cells | مستطیل |
| Field | `Point.x` | Zero-based column | ایکس |
| Field | `Point.y` | Zero-based row | ایگرگ |
| Field | `Rect.x` | Leftmost column | ایکس |
| Field | `Rect.y` | Topmost row | ایگرگ |
| Field | `Rect.width` | Number of columns | عرض |
| Field | `Rect.height` | Number of rows | ارتفاع |
| Method | `Rect.is_empty` | Test for zero or negative area | خالی است |
| Method | `Rect.right` | Return exclusive right edge | راست |
| Method | `Rect.bottom` | Return exclusive bottom edge | پایین |
| Method | `Rect.contains` | Test whether a Point falls inside | دربرمی‌گیرد |
| Method | `Rect.intersects` | Test overlap with another Rect | هم‌پوشانی دارد |
| Method | `Rect.intersection` | Return shared area of two rectangles | اشتراک |
| Method | `Rect.center` | Return the center cell | مرکز |

## `event.salam` (15 entries)

[Source file](https://github.com/curedbylethe/basalam/blob/main/basalam/event.salam)

| Kind | English API name | Meaning / usage | Persian alias |
|---|---|---|---|
| Constant | `NoEvent` | Event kind: no event | بدون رویداد |
| Constant | `KeyEvent` | Event kind: key input | رویداد کیبورد |
| Constant | `MouseEvent` | Event kind: mouse input | رویداد ماوس |
| Constant | `ResizeEvent` | Event kind: terminal resized | رویداد تغییر اندازه |
| Constant | `TickEvent` | Event kind: periodic timer tick | رویداد تیک |
| Type | `Event` | Unified event value delivered to widgets | رویداد |
| Field | `Event.kind` | Event discriminator | نوع |
| Field | `Event.key` | Decoded key, including key modifiers | کلید |
| Field | `Event.mouse` | Decoded terminal mouse report | ماوس |
| Field | `Event.width` | New terminal width for resize event | عرض |
| Field | `Event.height` | New terminal height for resize event | ارتفاع |
| Method | `Event.mouse_point` | Convert mouse position to zero-based Point | مختصات ماوس |
| Method | `Event.is_key` | Check whether event matches key code | کلید است |
| Method | `Event.is_char` | Check for typed character without Ctrl/Alt | نویسه است |
| Method | `Event.is_ctrl` | Check Ctrl+character combination | ترکیب کنترل است |

## `color.salam` (32 entries)

[Source file](https://github.com/curedbylethe/basalam/blob/main/basalam/color.salam)

| Kind | English API name | Meaning / usage | Persian alias |
|---|---|---|---|
| Constant | `Black` | Black ANSI palette color | مشکی |
| Constant | `Red` | Red ANSI palette color | قرمز |
| Constant | `Green` | Green ANSI palette color | سبز |
| Constant | `Yellow` | Yellow ANSI palette color | زرد |
| Constant | `Blue` | Blue ANSI palette color | آبی |
| Constant | `Magenta` | Magenta ANSI palette color | ارغوانی |
| Constant | `Cyan` | Cyan ANSI palette color | فیروزه‌ای |
| Constant | `White` | White ANSI palette color | سفید |
| Constant | `BrightBlack` | Bright black / gray ANSI palette color | مشکی روشن |
| Constant | `BrightRed` | Bright red ANSI palette color | قرمز روشن |
| Constant | `BrightGreen` | Bright green ANSI palette color | سبز روشن |
| Constant | `BrightYellow` | Bright yellow ANSI palette color | زرد روشن |
| Constant | `BrightBlue` | Bright blue ANSI palette color | آبی روشن |
| Constant | `BrightMagenta` | Bright magenta ANSI palette color | ارغوانی روشن |
| Constant | `BrightCyan` | Bright cyan ANSI palette color | فیروزه‌ای روشن |
| Constant | `BrightWhite` | Bright white ANSI palette color | سفید روشن |
| Enum | `Color` | Variant type for terminal color encodings | رنگ |
| Enum | `ColorTier` | Terminal color capability level | سطح رنگ |
| Enum variant | `Color.Default` | Terminal default color | پیش‌فرض |
| Enum variant | `Color.Ansi` | 16-color palette index | انسی |
| Enum variant | `Color.Indexed` | 256-color palette index | نمایه‌ای |
| Enum variant | `Color.Rgb` | Truecolor RGB triple | آرجی‌بی |
| Enum variant | `ColorTier.Off` | Color output disabled | خاموش |
| Enum variant | `ColorTier.Ansi16` | 16-color capability | انسی ۱۶ |
| Enum variant | `ColorTier.Indexed256` | 256-color capability | نمایه‌ای ۲۵۶ |
| Enum variant | `ColorTier.TrueColor` | 24-bit RGB capability | رنگ حقیقی |
| Function | `FgSeq` | Emit foreground SGR escape sequence | دنباله رنگ پیش‌زمینه |
| Function | `BgSeq` | Emit background SGR escape sequence | دنباله رنگ پس‌زمینه |
| Function | `DetectTier` | Detect terminal color capability | تشخیص سطح رنگ |
| Function | `Lower` | Reduce a Color to an available tier | کاهش سطح رنگ |
| Function | `FgSeqAt` | Emit foreground color at requested tier | دنباله پیش‌زمینه در سطح |
| Function | `BgSeqAt` | Emit background color at requested tier | دنباله پس‌زمینه در سطح |

## `style.salam` (20 entries)

[Source file](https://github.com/curedbylethe/basalam/blob/main/basalam/style.salam)

| Kind | English API name | Meaning / usage | Persian alias |
|---|---|---|---|
| Constant | `StyleDefault` | Default empty style | ظاهر پیش‌فرض |
| Enum | `BorderStyle` | Border drawing style | سبک کادر |
| Enum variant | `BorderStyle.None` | No border | بدون کادر |
| Enum variant | `BorderStyle.Single` | Single-line border | تک خط |
| Enum variant | `BorderStyle.Double` | Double-line border | دو خط |
| Enum variant | `BorderStyle.Rounded` | Rounded-corner border | گوشه‌گرد |
| Type | `Style` | Foreground, background, and visual text attributes | ظاهر |
| Field | `Style.fg` | Foreground color | رنگ پیش‌زمینه |
| Field | `Style.bg` | Background color | رنگ پس‌زمینه |
| Field | `Style.bold` | Bold text attribute | پررنگ |
| Field | `Style.dim` | Dim text attribute | کم‌رنگ |
| Field | `Style.italic` | Italic text attribute | کج |
| Field | `Style.underline` | Underlined text attribute | زیرخط |
| Field | `Style.reverse` | Invert foreground and background | وارونه |
| Function | `BorderInset` | Return border thickness in cells | ضخامت کادر |
| Function | `StyleMerge` | Combine parent and child styles | ادغام ظاهر |
| Function | `StyleEq` | Test styles for equality | برابری ظاهر |
| Function | `StyleSgr` | Generate style-on ANSI SGR sequences | دنباله فعال‌سازی ظاهر |
| Function | `StyleSgrOff` | Generate style-off ANSI SGR sequences | دنباله غیرفعال‌سازی ظاهر |
| Function | `SgrBuilds` | Query SGR-building instrumentation counter | شمار ساخت اس‌جی‌آر |

## `buffer.salam` (31 entries)

[Source file](https://github.com/curedbylethe/basalam/blob/main/basalam/buffer.salam)

| Kind | English API name | Meaning / usage | Persian alias |
|---|---|---|---|
| Type | `Cell` | Character and style for a single terminal cell | سلول |
| Type | `Buffer` | Grid of terminal cells and drawing operations | بافر |
| Field | `Cell.ch` | Character or glyph in the cell | نویسه |
| Field | `Cell.style` | Render style for the cell | ظاهر |
| Field | `Buffer.width` | Buffer width in cells | عرض |
| Field | `Buffer.height` | Buffer height in cells | ارتفاع |
| Field | `Buffer.cells` | Cell grid of current frame | سلول‌ها |
| Field | `Buffer.front` | Cell grid of last committed frame | بافر پیشین |
| Field | `Buffer.clip` | Current clipping region | محدوده برش |
| Field | `Buffer.focused` | Whether buffer drawing is in focused state | در تمرکز |
| Field | `Buffer.tier` | Terminal color capability used for emission | سطح رنگ |
| Field | `Buffer.force_full` | Force a complete redraw rather than diff | اجبار بازترسیم کامل |
| Field | `Buffer.glyphs` | Glyph policy that structural glyphs follow | نویسه‌ها |
| Method | `Buffer.area` | Get the buffer area as Rect | محدوده |
| Method | `Buffer.set` | Write one cell at coordinates | تنظیم |
| Method | `Buffer.get` | Read one cell at coordinates | دریافت |
| Method | `Buffer.put_str` | Draw a string at coordinates | نوشتن متن |
| Method | `Buffer.fill` | Fill a rectangular region with glyph and style | پرکردن |
| Method | `Buffer.clear` | Clear current drawing cells | پاک‌سازی |
| Method | `Buffer.row_text` | Get text representation of one row | متن ردیف |
| Method | `Buffer.resize` | Resize buffer and storage | تغییر اندازه |
| Method | `Buffer.ansi` | Generate full-frame terminal output | خروجی کامل انسی |
| Method | `Buffer.diff` | Generate changes relative to previous frame | اختلاف |
| Method | `Buffer.commit` | Mark current frame as the front frame | ثبت قاب |
| Method | `Buffer.flush` | Emit and commit output to terminal | ارسال به ترمینال |
| Method | `Buffer.free` | Release buffer storage | آزادسازی |
| Enum | `GlyphPolicy` | Glyph repertoire structural glyphs may use | سیاست نویسه‌ها |
| Enum variant | `GlyphPolicy.Unicode` | Box-drawing glyphs | یونیکد |
| Enum variant | `GlyphPolicy.ASCII` | Plain ASCII glyphs only | اسکی |
| Constructor | `NewBuffer` | Create buffer with specified cell dimensions | بافر جدید |
| Function | `DetectGlyphPolicy` | Glyph policy the environment advertises | تشخیص سیاست نویسه‌ها |

## `border.salam` (27 entries)

[Source file](https://github.com/curedbylethe/basalam/blob/main/basalam/border.salam)

| Kind | English API name | Meaning / usage | Persian alias |
|---|---|---|---|
| Function | `DrawBorder` | Draw a border ring with optional title into a buffer | ترسیم کادر |
| Function | `DrawBorderGlyphs` | Draw a border ring from an explicit glyph set | ترسیم کادر با نویسه‌ها |
| Enum | `Weight` | Stroke weight of a border run | ضخامت |
| Enum variant | `Weight.Light` | Thin single line | سبک |
| Enum variant | `Weight.Heavy` | Thick single line | سنگین |
| Enum variant | `Weight.Double` | Double line | دوگانه |
| Type | `BorderGlyphs` | Glyphs of one border ring: edges, corners and junctions | نویسه‌های کادر |
| Field | `BorderGlyphs.h` | Horizontal edge glyph | افقی |
| Field | `BorderGlyphs.v` | Vertical edge glyph | عمودی |
| Field | `BorderGlyphs.tl` | Top-left corner glyph | گوشه بالا چپ |
| Field | `BorderGlyphs.tr` | Top-right corner glyph | گوشه بالا راست |
| Field | `BorderGlyphs.bl` | Bottom-left corner glyph | گوشه پایین چپ |
| Field | `BorderGlyphs.br` | Bottom-right corner glyph | گوشه پایین راست |
| Field | `BorderGlyphs.t_down` | T junction opening downward | سه‌راهی پایین |
| Field | `BorderGlyphs.t_up` | T junction opening upward | سه‌راهی بالا |
| Field | `BorderGlyphs.t_right` | T junction opening right | سه‌راهی راست |
| Field | `BorderGlyphs.t_left` | T junction opening left | سه‌راهی چپ |
| Field | `BorderGlyphs.cross` | Four-way junction glyph | چهارراه |
| Field | `BorderGlyphs.hw` | Weight of the horizontal run | ضخامت افقی |
| Field | `BorderGlyphs.vw` | Weight of the vertical run | ضخامت عمودی |
| Function | `GlyphsSingle` | Light lines with square corners | نویسه‌های تک خط |
| Function | `GlyphsDouble` | Double lines | نویسه‌های دو خط |
| Function | `GlyphsRounded` | Light lines with rounded corners | نویسه‌های گرد |
| Function | `GlyphsASCII` | Plain ASCII glyphs | نویسه‌های اسکی |
| Function | `GlyphsHeavy` | Thick single lines | نویسه‌های سنگین |
| Function | `GlyphsMixed` | Heavy horizontal and light vertical runs | نویسه‌های ترکیبی |
| Function | `GlyphsFor` | Glyph set for a border style under a glyph policy | نویسه‌ها برای |

## `widget.salam` (21 entries)

[Source file](https://github.com/curedbylethe/basalam/blob/main/basalam/widget.salam)

| Kind | English API name | Meaning / usage | Persian alias |
|---|---|---|---|
| Interface | `Widget` | Contract implemented by all TUI widgets | ویجت |
| Type | `BaseWidget` | Default implementation and base for custom widgets | ویجت پایه |
| Method | `Widget.render` | Draw into buffer within bounds | ترسیم |
| Method | `Widget.handle_event` | Process input event, indicating consumption | پردازش رویداد |
| Method | `Widget.focusable` | Indicate keyboard focus eligibility | تمرکز‌پذیر است |
| Method | `Widget.hits` | Indicate mouse hit-test eligibility | اصابت‌پذیر است |
| Method | `Widget.visible` | Indicate whether widget is displayed | نمایان است |
| Method | `Widget.bounds` | Return assigned widget rectangle | محدوده |
| Method | `Widget.set_bounds` | Assign widget rectangle | تنظیم محدوده |
| Method | `Widget.preferred_size` | Compute desired size given width constraint | اندازه ترجیحی |
| Method | `Widget.measure` | Return a measured extent for an axis | اندازه‌گیری |
| Method | `BaseWidget.render` | Draw into buffer within bounds | ترسیم |
| Method | `BaseWidget.handle_event` | Process input event, indicating consumption | پردازش رویداد |
| Method | `BaseWidget.focusable` | Indicate keyboard focus eligibility | تمرکز‌پذیر است |
| Method | `BaseWidget.hits` | Indicate mouse hit-test eligibility | اصابت‌پذیر است |
| Method | `BaseWidget.visible` | Indicate whether widget is displayed | نمایان است |
| Method | `BaseWidget.bounds` | Return assigned widget rectangle | محدوده |
| Method | `BaseWidget.set_bounds` | Assign widget rectangle | تنظیم محدوده |
| Method | `BaseWidget.preferred_size` | Compute desired size given width constraint | اندازه ترجیحی |
| Method | `BaseWidget.measure` | Return a measured extent for an axis | اندازه‌گیری |
| Field | `BaseWidget.rect` | Stored widget rectangle | مستطیل |

## `layout.salam` (97 entries)

[Source file](https://github.com/curedbylethe/basalam/blob/main/basalam/layout.salam)

| Kind | English API name | Meaning / usage | Persian alias |
|---|---|---|---|
| Enum | `Axis` | Coordinate axis for measurement | محور |
| Enum | `CrossAlign` | Alignment on cross axis | تراز عرضی |
| Enum | `SizeKind` | Sizing algorithm kind | نوع اندازه‌گذاری |
| Enum variant | `Axis.X` | Horizontal axis | محور افقی |
| Enum variant | `Axis.Y` | Vertical axis | محور عمودی |
| Enum variant | `CrossAlign.Start` | Place at leading edge | آغاز |
| Enum variant | `CrossAlign.Center` | Center within available space | مرکز |
| Enum variant | `CrossAlign.End` | Place at trailing edge | پایان |
| Enum variant | `CrossAlign.Stretch` | Fill available cross-axis space | کشیده |
| Enum variant | `SizeKind.Fill` | Divide remaining available space | پرکردن فضا |
| Enum variant | `SizeKind.Fixed` | Assign fixed size | ثابت |
| Enum variant | `SizeKind.Pref` | Use preferred/natural size | ترجیحی |
| Type | `Measure` | Measured size plus validity flag | اندازه |
| Type | `LayoutSize` | One dimension's sizing policy | قاعده اندازه‌گذاری |
| Type | `Insets` | Four edges' inset values | فاصله‌های چهارگانه |
| Type | `LayoutSlot` | Child, sizing, placement and alignment metadata | جایگاه چیدمان |
| Type | `Row` | Horizontal container | ردیف |
| Type | `Column` | Vertical container | ستون |
| Type | `Grid` | Cell-based row-column container | شبکه |
| Type | `Stack` | Overlapping layered container | پشته |
| Field | `Measure.ok` | Whether measurement was produced | معتبر |
| Field | `Measure.extent` | Measured extent in cells | گستره |
| Field | `LayoutSize.kind` | Size policy (Fill/Fixed/Pref) | نوع |
| Field | `LayoutSize.cells` | Fixed-size extent | تعداد سلول |
| Field | `LayoutSize.weight` | Relative Fill weight | وزن |
| Field | `Insets.top` | Top inset in cells | بالا |
| Field | `Insets.right` | Right inset in cells | راست |
| Field | `Insets.bottom` | Bottom inset in cells | پایین |
| Field | `Insets.left` | Left inset in cells | چپ |
| Field | `LayoutSlot.child` | Child widget | فرزند |
| Field | `LayoutSlot.margin` | External spacing around child | حاشیه بیرونی |
| Field | `LayoutSlot.width` | Width sizing rule | عرض |
| Field | `LayoutSlot.height` | Height sizing rule | ارتفاع |
| Field | `LayoutSlot.align_x` | Horizontal placement rule | تراز افقی |
| Field | `LayoutSlot.align_y` | Vertical placement rule | تراز عمودی |
| Field | `LayoutSlot.row` | Start grid row | ردیف |
| Field | `LayoutSlot.col` | Start grid column | ستون |
| Field | `LayoutSlot.row_span` | Number of grid rows occupied | گستره ردیف |
| Field | `LayoutSlot.col_span` | Number of grid columns occupied | گستره ستون |
| Field | `Row.pad` | Internal padding | فاصله درونی |
| Field | `Row.gap` | Space between children | فاصله |
| Field | `Row.items` | Ordered child slots | جایگاه‌ها |
| Method | `Row.add` | Append child widget | افزودن |
| Method | `Row.set_margin` | Set child's outside spacing | تنظیم حاشیه بیرونی |
| Method | `Row.set_width` | Set child's width sizing rule | تنظیم عرض |
| Method | `Row.set_height` | Set child's height sizing rule | تنظیم ارتفاع |
| Method | `Row.set_align` | Set child's horizontal and vertical alignment | تنظیم تراز |
| Method | `Row.set_padding` | Set container padding | تنظیم فاصله درونی |
| Method | `Row.set_gap` | Set spacing between children | تنظیم فاصله |
| Method | `Row.measure` | Measure desired layout size | اندازه‌گیری |
| Method | `Row.set_bounds` | Assign container geometry and lay out children | تنظیم محدوده |
| Field | `Column.pad` | Internal padding | فاصله درونی |
| Field | `Column.gap` | Space between children | فاصله |
| Field | `Column.items` | Ordered child slots | جایگاه‌ها |
| Method | `Column.add` | Append child widget | افزودن |
| Method | `Column.set_margin` | Set child's outside spacing | تنظیم حاشیه بیرونی |
| Method | `Column.set_width` | Set child's width sizing rule | تنظیم عرض |
| Method | `Column.set_height` | Set child's height sizing rule | تنظیم ارتفاع |
| Method | `Column.set_align` | Set child's horizontal and vertical alignment | تنظیم تراز |
| Method | `Column.set_padding` | Set container padding | تنظیم فاصله درونی |
| Method | `Column.set_gap` | Set spacing between children | تنظیم فاصله |
| Method | `Column.measure` | Measure desired layout size | اندازه‌گیری |
| Method | `Column.set_bounds` | Assign container geometry and lay out children | تنظیم محدوده |
| Field | `Grid.pad` | Internal padding | فاصله درونی |
| Field | `Grid.items` | Child slots | جایگاه‌ها |
| Field | `Grid.rows` | Number of rows | ردیف‌ها |
| Field | `Grid.cols` | Number of columns | ستون‌ها |
| Method | `Grid.add` | Append child widget | افزودن |
| Method | `Grid.set_margin` | Set child margin | تنظیم حاشیه بیرونی |
| Method | `Grid.set_width` | Set child width policy | تنظیم عرض |
| Method | `Grid.set_height` | Set child height policy | تنظیم ارتفاع |
| Method | `Grid.set_align` | Set child alignment | تنظیم تراز |
| Method | `Grid.set_cell` | Assign child grid coordinates | تنظیم خانه |
| Method | `Grid.set_span` | Set child grid row/column span | تنظیم گستره |
| Method | `Grid.set_padding` | Set container padding | تنظیم فاصله درونی |
| Method | `Grid.set_bounds` | Assign grid geometry and lay out children | تنظیم محدوده |
| Field | `Stack.pad` | Internal padding | فاصله درونی |
| Field | `Stack.items` | Layered child slots | جایگاه‌ها |
| Method | `Stack.add` | Append child widget | افزودن |
| Method | `Stack.set_margin` | Set child margin | تنظیم حاشیه بیرونی |
| Method | `Stack.set_width` | Set child width policy | تنظیم عرض |
| Method | `Stack.set_height` | Set child height policy | تنظیم ارتفاع |
| Method | `Stack.set_align` | Set child alignment | تنظیم تراز |
| Method | `Stack.set_padding` | Set container padding | تنظیم فاصله درونی |
| Method | `Stack.set_bounds` | Assign stack geometry and lay out children | تنظیم محدوده |
| Function | `NewInsets` | Build four-sided Insets | فاصله‌های چهارگانه جدید |
| Function | `UniformInsets` | Build identical Insets on all sides | فاصله‌های چهارگانه یکسان |
| Function | `FitRect` | Fit a rectangle inside another | جاسازی مستطیل |
| Function | `InsetRect` | Shrink a rectangle by insets | کاستن از لبه‌های مستطیل |
| Function | `SplitMain` | Allocate main-axis lengths to sizing rules | تقسیم محور اصلی |
| Function | `TrackSizes` | Divide length into grid track sizes | اندازه‌های بخش‌های شبکه |
| Function | `PlaceAxisSize` | Compute aligned dimension size | اندازه در محور |
| Function | `PlaceAxisOffset` | Compute aligned dimension offset | جابه‌جایی در محور |
| Constructor | `NewRow` | Construct an empty Row | ردیف جدید |
| Constructor | `NewColumn` | Construct an empty Column | ستون جدید |
| Constructor | `NewGrid` | Construct a Grid with row/column counts | شبکه جدید |
| Constructor | `NewStack` | Construct an empty Stack | پشته جدید |

## `focus.salam` (5 entries)

[Source file](https://github.com/curedbylethe/basalam/blob/main/basalam/focus.salam)

| Kind | English API name | Meaning / usage | Persian alias |
|---|---|---|---|
| Constant | `DirUp` | Upward focus direction | جهت بالا |
| Constant | `DirDown` | Downward focus direction | جهت پایین |
| Constant | `DirLeft` | Leftward focus direction | جهت چپ |
| Constant | `DirRight` | Rightward focus direction | جهت راست |
| Function | `Nearest` | Find nearest focus candidate in a direction | نزدیک‌ترین |

## `keymap.salam` (15 entries)

[Source file](https://github.com/curedbylethe/basalam/blob/main/basalam/keymap.salam)

| Kind | English API name | Meaning / usage | Persian alias |
|---|---|---|---|
| Type | `Keymap` | Bind individual keys and multi-key sequences to actions | نگاشت کلید |
| Field | `Keymap.pending_timeout_ms` | Maximum wait for continuation of a key sequence | مهلت توالی به میلی‌ثانیه |
| Field | `Keymap.pending_since_ms` | Timestamp of current pending key sequence | آغاز انتظار توالی به میلی‌ثانیه |
| Method | `Keymap.bind` | Bind global single key | پیوند کلید |
| Method | `Keymap.bind_for` | Bind single key for one widget | پیوند کلید برای ویجت |
| Method | `Keymap.bind_seq` | Bind global key sequence | پیوند توالی |
| Method | `Keymap.bind_for_seq` | Bind key sequence for one widget | پیوند توالی برای ویجت |
| Method | `Keymap.unbind` | Remove global single-key binding | لغو پیوند کلید |
| Method | `Keymap.unbind_for` | Remove widget-specific single-key binding | لغو پیوند کلید برای ویجت |
| Method | `Keymap.unbind_for_seq` | Remove widget-specific sequence binding | لغو پیوند توالی برای ویجت |
| Method | `Keymap.handle` | Resolve key event against bindings | پردازش کلید |
| Method | `Keymap.free` | Release keymap data | آزادسازی |
| Constructor | `NewKeymap` | Create an unbound keymap | نگاشت کلید جدید |
| Constructor | `NewDefaultKeymap` | Create default navigation bindings | نگاشت کلید پیش‌فرض |
| Constructor | `NewVimKeymap` | Create Vim-style navigation bindings | نگاشت کلید ویم |

## `input.salam` (17 entries)

[Source file](https://github.com/curedbylethe/basalam/blob/main/basalam/input.salam)

| Kind | English API name | Meaning / usage | Persian alias |
|---|---|---|---|
| Type | `Input` | Focusable single-line text input | ورودی |
| Field | `Input.placeholder` | Hint when value is empty | متن راهنما |
| Field | `Input.style` | Normal input text styling | ظاهر |
| Field | `Input.cursor_style` | Caret styling | ظاهر مکان‌نما |
| Field | `Input.placeholder_style` | Hint text styling | ظاهر متن راهنما |
| Field | `Input.max_length` | Maximum value length in glyphs, 0 for unlimited | حداکثر طول |
| Field | `Input.filter` | Veto callback for each proposed insertion | پالایه |
| Field | `Input.masked` | Whether value glyphs are painted as the mask glyph | پوشانده |
| Field | `Input.mask_glyph` | Glyph painted for each value glyph while masked | نماد پوشش |
| Field | `Input.on_submit` | Callback on Enter; its result is the consumed flag | هنگام ثبت |
| Method | `Input.focusable` | Indicate keyboard focus eligibility | تمرکز‌پذیر است |
| Method | `Input.handle_event` | Handle keyboard editing | پردازش رویداد |
| Method | `Input.value` | Get text value | مقدار |
| Method | `Input.set_value` | Replace text value | تنظیم مقدار |
| Method | `Input.set_placeholder` | Change placeholder text | تنظیم متن راهنما |
| Method | `Input.render` | Draw input and caret | ترسیم |
| Constructor | `NewInput` | Create empty input widget | ورودی جدید |

## `button.salam` (12 entries)

[Source file](https://github.com/curedbylethe/basalam/blob/main/basalam/button.salam)

| Kind | English API name | Meaning / usage | Persian alias |
|---|---|---|---|
| Type | `Button` | Activatable one-line button | دکمه |
| Field | `Button.label` | Text displayed on button | برچسب |
| Field | `Button.style` | Normal button style | ظاهر |
| Field | `Button.focus_style` | Style while focused | ظاهر تمرکز |
| Field | `Button.disabled` | Whether user action is disabled | غیرفعال |
| Field | `Button.on_click` | Callback when activated | هنگام کلیک |
| Method | `Button.focusable` | Indicate keyboard focus eligibility | تمرکز‌پذیر است |
| Method | `Button.hits` | Indicate mouse hit-test eligibility | اصابت‌پذیر است |
| Method | `Button.preferred_size` | Compute natural button size | اندازه ترجیحی |
| Method | `Button.handle_event` | Process activation event | پردازش رویداد |
| Method | `Button.render` | Draw button | ترسیم |
| Constructor | `NewButton` | Construct button with label | دکمه جدید |

## `checkbox.salam` (14 entries)

[Source file](https://github.com/curedbylethe/basalam/blob/main/basalam/checkbox.salam)

| Kind | English API name | Meaning / usage | Persian alias |
|---|---|---|---|
| Type | `Checkbox` | Focusable boolean toggle | کادر انتخاب |
| Field | `Checkbox.label` | Caption beside checkbox | برچسب |
| Field | `Checkbox.box_style` | Style of checkbox indicator | ظاهر کادر |
| Field | `Checkbox.label_style` | Style of label text | ظاهر برچسب |
| Field | `Checkbox.disabled` | Whether toggling is disabled | غیرفعال |
| Field | `Checkbox.on_toggle` | Callback after value changes | هنگام تغییر انتخاب |
| Method | `Checkbox.focusable` | Indicate keyboard focus eligibility | تمرکز‌پذیر است |
| Method | `Checkbox.hits` | Indicate mouse hit-test eligibility | اصابت‌پذیر است |
| Method | `Checkbox.handle_event` | Process toggle input | پردازش رویداد |
| Method | `Checkbox.checked` | Read boolean selected state | انتخاب شده است |
| Method | `Checkbox.set_checked` | Set selected state | تنظیم انتخاب |
| Method | `Checkbox.preferred_size` | Compute natural checkbox size | اندازه ترجیحی |
| Method | `Checkbox.render` | Draw checkbox and label | ترسیم |
| Constructor | `NewCheckbox` | Create checkbox with label and checked state | کادر انتخاب جدید |

## `list.salam` (11 entries)

[Source file](https://github.com/curedbylethe/basalam/blob/main/basalam/list.salam)

| Kind | English API name | Meaning / usage | Persian alias |
|---|---|---|---|
| Type | `List` | Scrollable single-selection list | فهرست |
| Field | `List.style` | Normal list text styling | ظاهر |
| Field | `List.selected_style` | Style of selection when focused | ظاهر انتخاب |
| Field | `List.selected_unfocused_style` | Style of selection without focus | ظاهر انتخاب بی‌تمرکز |
| Field | `List.on_select` | Callback when selected index changes | هنگام انتخاب |
| Method | `List.focusable` | Indicate keyboard focus eligibility | تمرکز‌پذیر است |
| Method | `List.handle_event` | Handle list navigation input | پردازش رویداد |
| Method | `List.selected_index` | Return current selected index | نمایه انتخاب |
| Method | `List.selected_item` | Return current selected item text | گزینه انتخاب‌شده |
| Method | `List.render` | Draw list items and selection | ترسیم |
| Constructor | `NewList` | Create list from string items | فهرست جدید |

## `text.salam` (24 entries)

[Source file](https://github.com/curedbylethe/basalam/blob/main/basalam/text.salam)

| Kind | English API name | Meaning / usage | Persian alias |
|---|---|---|---|
| Enum | `Alignment` | Text horizontal alignment | تراز |
| Enum | `WrapMode` | Line wrapping behavior | حالت شکست خط |
| Enum variant | `Alignment.Left` | Align left | چپ |
| Enum variant | `Alignment.Center` | Align center | مرکز |
| Enum variant | `Alignment.Right` | Align right | راست |
| Enum variant | `WrapMode.Word` | Wrap at word boundaries | بر پایه واژه |
| Enum variant | `WrapMode.None` | Do not wrap lines | بدون شکست |
| Type | `Text` | Static multiline text widget | متن |
| Field | `Text.content` | Text to display | محتوا |
| Field | `Text.align` | Horizontal alignment | تراز |
| Field | `Text.style` | Text style | ظاهر |
| Field | `Text.wrap` | Line-wrapping mode | شکست خط |
| Method | `Text.set_text` | Replace displayed text | تنظیم متن |
| Method | `Text.set_source` | Read displayed text from a source function | تنظیم منبع |
| Method | `Text.clear_source` | Return to the last pushed text | پاک‌سازی منبع |
| Method | `Text.set_align` | Change text alignment | تنظیم تراز |
| Method | `Text.set_style` | Change text style | تنظیم ظاهر |
| Method | `Text.set_wrap` | Change wrapping policy | تنظیم شکست خط |
| Method | `Text.preferred_size` | Compute natural dimensions at width | اندازه ترجیحی |
| Method | `Text.preferred_width` | Return natural text width | عرض ترجیحی |
| Method | `Text.render` | Draw text lines | ترسیم |
| Function | `WrapText` | Split text into width-limited lines | شکستن خطوط متن |
| Function | `MeasureText` | Measure text at a width constraint | اندازه‌گیری متن |
| Constructor | `NewText` | Construct text widget with content | متن جدید |

## `panel.salam` (13 entries)

[Source file](https://github.com/curedbylethe/basalam/blob/main/basalam/panel.salam)

| Kind | English API name | Meaning / usage | Persian alias |
|---|---|---|---|
| Type | `Panel` | Bordered decorator containing a single child | پنل |
| Field | `Panel.border` | Selected border kind | کادر |
| Field | `Panel.border_style` | Border color/style | ظاهر کادر |
| Field | `Panel.title` | Caption on top border | عنوان |
| Field | `Panel.takes_focus` | Whether panel itself accepts focus | تمرکز می‌گیرد |
| Field | `Panel.focus_style` | Border styling when focused | ظاهر تمرکز |
| Field | `Panel.slot` | Stored child layout slot collection | جایگاه |
| Method | `Panel.add` | Set/add child widget | افزودن |
| Method | `Panel.set_bounds` | Assign panel geometry | تنظیم محدوده |
| Method | `Panel.preferred_size` | Report natural panel size | اندازه ترجیحی |
| Method | `Panel.focusable` | Indicate panel focus eligibility | تمرکز‌پذیر است |
| Method | `Panel.handle_event` | Process panel event | پردازش رویداد |
| Method | `Panel.render` | Draw frame and child | ترسیم |

## `modal.salam` (23 entries)

[Source file](https://github.com/curedbylethe/basalam/blob/main/basalam/modal.salam)

| Kind | English API name | Meaning / usage | Persian alias |
|---|---|---|---|
| Enum | `ModalSize` | Dialog size mode | اندازه مودال |
| Enum variant | `ModalSize.Percent` | Relative size specified as percent | درصدی |
| Enum variant | `ModalSize.Fixed` | Fixed size in cells | ثابت |
| Type | `Modal` | Overlay dialog with focus handling and scrim | مودال |
| Field | `Modal.border_style` | Border styling | ظاهر کادر |
| Field | `Modal.takes_focus` | Whether dialog takes focus | تمرکز می‌گیرد |
| Field | `Modal.on_close` | Callback when dialog closes | هنگام بستن |
| Field | `Modal.state` | Internal modal state vector (public field with private type) | وضعیت |
| Method | `Modal.add` | Place child widget inside dialog | افزودن |
| Method | `Modal.open` | Display dialog | باز کردن |
| Method | `Modal.close` | Hide dialog | بستن |
| Method | `Modal.set_title` | Change dialog title | تنظیم عنوان |
| Method | `Modal.set_size` | Change dialog sizing rule | تنظیم اندازه |
| Method | `Modal.set_closable` | Allow/disallow user close | تنظیم امکان بستن |
| Method | `Modal.set_bounds` | Set modal geometry | تنظیم محدوده |
| Method | `Modal.bounds` | Get current geometry | محدوده |
| Method | `Modal.preferred_size` | Compute natural dimensions | اندازه ترجیحی |
| Method | `Modal.focusable` | Indicate focus eligibility | تمرکز‌پذیر است |
| Method | `Modal.hits` | Indicate pointer hit eligibility | اصابت‌پذیر است |
| Method | `Modal.visible` | Check if modal is shown | نمایان است |
| Method | `Modal.handle_event` | Process modal input and dismissal | پردازش رویداد |
| Method | `Modal.render` | Draw scrim and dialog | ترسیم |
| Constructor | `NewModal` | Construct modal overlay | مودال جدید |

## `progress.salam` (11 entries)

[Source file](https://github.com/curedbylethe/basalam/blob/main/basalam/progress.salam)

| Kind | English API name | Meaning / usage | Persian alias |
|---|---|---|---|
| Type | `Progress` | Single-row progress bar | نوار پیشرفت |
| Field | `Progress.fill_style` | Filled portion styling | ظاهر بخش پر |
| Field | `Progress.empty_style` | Unfilled portion styling | ظاهر بخش خالی |
| Field | `Progress.text_style` | Progress caption styling | ظاهر متن |
| Method | `Progress.hits` | Indicate pointer hit eligibility | اصابت‌پذیر است |
| Method | `Progress.preferred_size` | Compute natural bar size | اندازه ترجیحی |
| Method | `Progress.progress` | Read progress value | مقدار پیشرفت |
| Method | `Progress.set_progress` | Set progress percentage | تنظیم پیشرفت |
| Method | `Progress.set_max` | Set progress range maximum | تنظیم بیشینه |
| Method | `Progress.render` | Draw progress bar | ترسیم |
| Constructor | `NewProgress` | Construct progress bar | نوار پیشرفت جدید |

## `separator.salam` (17 entries)

[Source file](https://github.com/curedbylethe/basalam/blob/main/basalam/separator.salam)

| Kind | English API name | Meaning / usage | Persian alias |
|---|---|---|---|
| Enum | `Orientation` | Orientation of separator line | جهت‌گیری |
| Enum variant | `Orientation.Horizontal` | Horizontal line | افقی |
| Enum variant | `Orientation.Vertical` | Vertical line | عمودی |
| Type | `Separator` | Horizontal or vertical dividing rule | جداکننده |
| Field | `Separator.orientation` | Line orientation | جهت‌گیری |
| Field | `Separator.ch` | Optional glyph to draw | نویسه |
| Field | `Separator.style` | Separator style | ظاهر |
| Method | `Separator.focusable` | Indicate keyboard focus eligibility | تمرکز‌پذیر است |
| Method | `Separator.hits` | Indicate pointer hit eligibility | اصابت‌پذیر است |
| Method | `Separator.handle_event` | Handle event (normally inert) | پردازش رویداد |
| Method | `Separator.preferred_size` | Return natural separator dimensions | اندازه ترجیحی |
| Method | `Separator.measure` | Measure required extent | اندازه‌گیری |
| Method | `Separator.set_orientation` | Change separator direction | تنظیم جهت‌گیری |
| Method | `Separator.set_ch` | Change separating glyph | تنظیم نویسه |
| Method | `Separator.set_style` | Change separator appearance | تنظیم ظاهر |
| Method | `Separator.render` | Draw dividing rule | ترسیم |
| Constructor | `NewSeparator` | Construct separator | جداکننده جدید |

## `table.salam` (43 entries)

[Source file](https://github.com/curedbylethe/basalam/blob/main/basalam/table.salam)

| Kind | English API name | Meaning / usage | Persian alias |
|---|---|---|---|
| Enum | `CellOverflow` | Overflow strategy for table cells | سرریز سلول |
| Enum variant | `CellOverflow.Clip` | Truncate content at cell edge | برش |
| Enum variant | `CellOverflow.Ellipsis` | Show ellipsis on overflowing content | سه‌نقطه |
| Type | `TableColumn` | Column sizing/format options | ستون جدول |
| Type | `Table` | Tabular text widget | جدول |
| Field | `TableColumn.width` | Column sizing policy | عرض |
| Field | `TableColumn.min` | Minimum width in cells | کمینه |
| Field | `TableColumn.max` | Maximum width in cells | بیشینه |
| Field | `TableColumn.align` | Horizontal alignment | تراز |
| Field | `TableColumn.overflow` | Overflow handling policy | سرریز |
| Field | `Table.columns` | Column definitions | ستون‌ها |
| Field | `Table.rows` | Row values | ردیف‌ها |
| Field | `Table.header` | Whether first row is a header | سرآیند |
| Field | `Table.rule` | Whether to show row/column ruling | خط‌کشی |
| Field | `Table.pad_x` | Cell horizontal padding | فاصله درونی افقی |
| Field | `Table.style` | Normal cell style | ظاهر |
| Field | `Table.header_style` | Header cell style | ظاهر سرآیند |
| Method | `Table.focusable` | Whether table accepts focus | تمرکز‌پذیر است |
| Method | `Table.hits` | Whether table accepts pointer hits | اصابت‌پذیر است |
| Method | `Table.handle_event` | Handle input event (normally inert) | پردازش رویداد |
| Method | `Table.add_column` | Append column definition | افزودن ستون |
| Method | `Table.add_row` | Append text row | افزودن ردیف |
| Method | `Table.set_column_width` | Change width rule for column | تنظیم عرض ستون |
| Method | `Table.set_column_align` | Change alignment for column | تنظیم تراز ستون |
| Method | `Table.set_column_overflow` | Change overflow rule for column | تنظیم سرریز ستون |
| Method | `Table.set_cell_align` | Override alignment for one cell | تنظیم تراز سلول |
| Method | `Table.set_pad_x` | Change horizontal cell padding | تنظیم فاصله درونی افقی |
| Method | `Table.preferred_size` | Compute natural table dimensions | اندازه ترجیحی |
| Method | `Table.measure` | Measure table in chosen axis | اندازه‌گیری |
| Method | `Table.render` | Draw table | ترسیم |
| Method | `Table._resolve_widths` | Resolve column widths for a width (public for TableView; not for application code) | محاسبه عرض‌ها |
| Method | `Table._paint_row` | Paint one data row (public for TableView; not for application code) | رسم ردیف |
| Method | `Table._paint_rule` | Paint a ruling line (public for TableView; not for application code) | رسم خط |
| Constructor | `NewTable` | Construct table widget | جدول جدید |
| Type | `TableView` | Focusable, vertically scrollable Table with selection | نمای جدول |
| Field | `TableView.offset` | Index of the first visible data row | جابه‌جایی |
| Field | `TableView.selected` | Selected data row, or -1 when there are none | انتخاب‌شده |
| Field | `TableView.activate` | Callback on Enter; its result is the consumed flag | فعال‌سازی |
| Method | `TableView.focusable` | Whether table view accepts focus (true) | تمرکز‌پذیر است |
| Method | `TableView.hits` | Whether table view accepts pointer hits (true) | اصابت‌پذیر است |
| Method | `TableView.handle_event` | Move the cursor with navigation keys; Enter calls activate | پردازش رویداد |
| Method | `TableView.render` | Draw pinned header and visible rows with scrollbar | ترسیم |
| Constructor | `NewTableView` | Construct an empty table view | نمای جدول جدید |

## `tree.salam` (13 entries)

[Source file](https://github.com/curedbylethe/basalam/blob/main/basalam/tree.salam)

| Kind | English API name | Meaning / usage | Persian alias |
|---|---|---|---|
| Constant | `NoWidget` | Sentinel for absence of widget ID | بدون ویجت |
| Constant | `RootId` | Root widget ID | شناسه ریشه |
| Type | `Tree` | Widget ID registry with parent links and event bubbling | درخت |
| Field | `Tree.widgets` | Registered widget collection | ویجت‌ها |
| Field | `Tree.parents` | Parent index for each registered widget | والدها |
| Method | `Tree.count` | Count registered widgets | تعداد |
| Method | `Tree.valid` | Check whether widget ID is valid | معتبر است |
| Method | `Tree.add` | Register widget beneath parent | افزودن |
| Method | `Tree.get` | Retrieve widget by ID | دریافت |
| Method | `Tree.parent` | Retrieve parent ID | والد |
| Method | `Tree.dispatch` | Bubble an event from a widget upward | هدایت رویداد |
| Method | `Tree.free` | Release tree bookkeeping | آزادسازی |
| Constructor | `NewTree` | Create tree with root widget | درخت جدید |

## `screen.salam` (52 entries)

[Source file](https://github.com/curedbylethe/basalam/blob/main/basalam/screen.salam)

| Kind | English API name | Meaning / usage | Persian alias |
|---|---|---|---|
| Constant | `PollMs` | Terminal event polling interval in milliseconds | بازه پایش به میلی‌ثانیه |
| Constant | `EventCapacity` | Event channel capacity | ظرفیت رویداد |
| Type | `Screen` | Terminal session, widget tree, focus and rendering loop | صفحه |
| Field | `Screen.events` | Incoming event channel | رویدادها |
| Field | `Screen.root` | Root widget | ریشه |
| Field | `Screen.focused` | Currently focused widget | ویجت متمرکز |
| Field | `Screen.buffer` | Frame buffer | بافر |
| Field | `Screen.running` | Whether event loop is active | در حال اجرا |
| Field | `Screen.tree` | Widget registry | درخت |
| Field | `Screen.tick_ms` | Tick interval in milliseconds | بازه تیک به میلی‌ثانیه |
| Field | `Screen.mouse` | Whether mouse reporting is enabled | گزارش ماوس |
| Field | `Screen.mouse_motion` | Whether mouse-motion reports are enabled | گزارش حرکت ماوس |
| Field | `Screen.keymap` | Optional keyboard binding map | نگاشت کلید |
| Field | `Screen.dirty` | Whether screen requires redraw | نیازمند بازترسیم |
| Field | `Screen.focus_stack` | Stack of focus targets to restore | پشته تمرکز |
| Field | `Screen.glyphs` | Glyph policy seeded into every frame buffer | نویسه‌ها |
| Method | `Screen.add` | Add widget with parent ID | افزودن |
| Method | `Screen.raise` | Raise a group of widgets | آوردن به رو |
| Method | `Screen.unraise` | Reverse raising a group | بازگرداندن ترتیب |
| Method | `Screen.raise_subtree` | Raise one widget subtree | آوردن زیردرخت به رو |
| Method | `Screen.unraise_subtree` | Restore widget subtree ordering | بازگرداندن ترتیب زیردرخت |
| Method | `Screen.widget` | Look up widget by ID | ویجت |
| Method | `Screen.focused_id` | Get current focus ID | شناسه متمرکز |
| Method | `Screen.can_focus` | Check if widget ID can receive focus | تمرکز‌پذیر است |
| Method | `Screen.focus` | Give focus to widget ID | تمرکز |
| Method | `Screen.push_focus` | Save current focus and set new focus | ذخیره و تغییر تمرکز |
| Method | `Screen.pop_focus` | Restore previous focus | بازیابی تمرکز |
| Method | `Screen.focus_next` | Move focus forward | تمرکز بعدی |
| Method | `Screen.focus_prev` | Move focus backward | تمرکز قبلی |
| Method | `Screen.focus_up` | Move focus upward | تمرکز بالا |
| Method | `Screen.focus_down` | Move focus downward | تمرکز پایین |
| Method | `Screen.focus_left` | Move focus leftward | تمرکز چپ |
| Method | `Screen.focus_right` | Move focus rightward | تمرکز راست |
| Method | `Screen.fit_root` | Fit root widget to screen size | جاسازی ریشه |
| Method | `Screen.resize` | Resize screen | تغییر اندازه |
| Method | `Screen.hit_test` | Locate widget at cell coordinates | آزمون برخورد |
| Method | `Screen.dispatch` | Route event through screen hierarchy | هدایت رویداد |
| Method | `Screen.set_keymap` | Set keyboard binding map | تنظیم نگاشت کلید |
| Method | `Screen.set_glyphs` | Fix the glyph policy instead of detecting one | تنظیم نویسه‌ها |
| Method | `Screen.invalidate` | Mark widget dirty | علامت‌گذاری برای بازترسیم |
| Method | `Screen.invalidate_subtree` | Mark widget subtree dirty | علامت‌گذاری زیردرخت برای بازترسیم |
| Method | `Screen.draw` | Render widgets to buffer | بازترسیم |
| Method | `Screen.present` | Flush current frame to terminal | نمایش تغییرات |
| Method | `Screen.post` | Enqueue event | صف‌گذاری رویداد |
| Method | `Screen.next_event` | Read/wait for next event | رویداد بعدی |
| Method | `Screen.start` | Start terminal session | آغاز |
| Method | `Screen.stop` | Request event loop termination | توقف |
| Method | `Screen.close` | Close terminal and restore state | بستن |
| Method | `Screen.run` | Run event loop | اجرا |
| Method | `Screen.run_with_tick` | Run event loop with tick callback | اجرا با تیک |
| Constructor | `NewScreen` | Create screen with explicit dimensions | صفحه جدید |
| Constructor | `NewTerminalScreen` | Create screen sized to terminal | صفحه ترمینال جدید |

## Review checks

Automated, on every `make check`:

- `make fa-aliases` fails when an `@en` has no following `@fa`, when an alias is empty, or when a `@fa` stands alone.
- `make build` type-checks every file in `basalam/`, so a malformed annotation cannot land.
- A rename in the source without a matching row here passes the gate, so review the table diff by hand.

Manual, on review of a name change:

- Every entry here names a real declaration, and every new declaration has an entry. Compare the table against `grep -rn '@en' basalam/`.
- Enum variants that share an English name (`None`, `Fixed`) read correctly for their own enum.
- Interfaces, base widgets, and concrete widgets reuse one Persian spelling for an overridden method (`render`, `hits`, `focusable`).
- Names shared across widgets (`set_align`, `set_bounds`) follow one convention.
- A Persian speaker reviews new aliases for meaning and spelling; the gate cannot.

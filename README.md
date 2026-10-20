# basalam

A retained-mode terminal user interface (TUI) library for the
[Salam](https://github.com/SalamLang/Salam) programming language.

basalam is a library, not an application: your program includes it to
build full-screen terminal interfaces. It sits on top of Salam's standard
`term` package and adds geometry, widgets, events, focus, and a screen that
draws frames.

> **Status: 0.1.0, early development.** See the
> [CHANGELOG](CHANGELOG.md) for what this release contains.

## Install

You need the Salam compiler, version 0.5.6 or later:

```sh
{ curl -fsSL https://raw.githubusercontent.com/SalamLang/Salam/refs/heads/main/install.sh || wget -qO- https://raw.githubusercontent.com/SalamLang/Salam/refs/heads/main/install.sh; } | sh
```

Salam has no third-party package registry yet, so vendor basalam into your
project:

```sh
git submodule add https://github.com/curedbylethe/basalam vendor/basalam
```

## Quick start

```salam
import term

include "vendor/basalam/basalam/basalam.salam"

struct Hello:
    pub use basalam.BaseWidget

    pub func render(buf: basalam.Buffer, bounds: basalam.Rect):
        buf.put_str(bounds.x + 2, bounds.y + 1, "Hello from basalam! Press q to quit.", term.Sgr(term.StyleBold))
    end
end

func main:
    mut screen := basalam.NewTerminalScreen(Hello {})
    screen.start()
    defer screen.close()

    screen.present()
    mut ev := basalam.Event {}
    until screen.next_event(ev):
        if not screen.dispatch(ev) and ev.is_char("q"):
            screen.stop()
        end
        screen.present()
    end
end
```

```sh
salam build main.salam && ./main
```

To see more, clone this repository and run `make run` for the demo.

## Documentation

The full documentation (concepts, guides, and API reference) is a
[Mintlify](https://mintlify.com) site whose source lives in this repository.
Start at [`index.mdx`](index.mdx), or preview it locally:

```sh
npm i -g mint
mint dev
```

Run `make docs-check` to validate the site and its links the way CI does; it
needs the same `mint` install.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). `make check` runs the library checks
and the documentation's own examples, `make test-llvm` builds every test with
`--backend=llvm` so a codegen failure fails instead of falling back to C, and
`make docs-check` checks the documentation site; CI runs all three. This
project follows the [Contributor Covenant](CODE_OF_CONDUCT.md).

## License

GPL-3.0-or-later, the same license family as Salam itself. See
[LICENSE](LICENSE). Because basalam is GPL, programs that include it are
distributed under the GPL too.

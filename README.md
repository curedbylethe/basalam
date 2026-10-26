# basalam

A retained-mode terminal user interface (TUI) library for the
[Salam](https://github.com/SalamLang/Salam) programming language.

basalam is a library, not an application: your program includes it to
build full-screen terminal interfaces. It sits on top of Salam's standard
`term` package and adds geometry, widgets, events, focus, and a screen that
draws frames.

> **Status: 0.3.2, early development.** See the
> [CHANGELOG](CHANGELOG.md) for what this release contains.

## Install

You need the Salam compiler, version 0.5.9 or later:

```sh
{ curl -fsSL https://raw.githubusercontent.com/SalamLang/Salam/refs/heads/main/install.sh || wget -qO- https://raw.githubusercontent.com/SalamLang/Salam/refs/heads/main/install.sh; } | sh
```

Add basalam with Salam's package manager. If the project has no `salam.toml`
yet, run `salam init` first, then pin a release tag:

```sh
salam add github.com/curedbylethe/basalam@v0.3.2
```

`salam add` writes the dependency to `salam.toml` and pins its commit and
sha256 in `salam.lock`. Commit both files. The lock is what makes the pin
reproducible, and a fresh clone restores the download with `salam deps`.

To move to another release, run the same command with that release's tag;
`salam add` replaces the pin.

Name the tag rather than running a bare `salam update`. That command moves
within the same major version, and until 1.0 the same major covers every `0.y`
minor, which this project treats as breaking.

## Quick start

```salam
import "github.com/curedbylethe/basalam/basalam"

struct Hello:
    pub use basalam.BaseWidget

    pub func render(buf: basalam.Buffer, bounds: basalam.Rect):
        buf.put_str(bounds.x + 2, bounds.y + 1, "Hello from basalam! Press q to quit.", basalam.Style { bold = true })
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
npm i -g mint@4.2.988
mint dev
```

Run `make docs-check` to validate the site and its links the way CI does, and
`make docs-format-check` to fail when `mint format` would rewrite a page; both
need the same `mint` install. The local gate compares against the index, so
stage or commit page edits before running it.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). `make check` is the library gate:
format check, strict LLVM build and examples, tests, and the documentation's
own examples. `make release-check` validates the release metadata: the version
constant, the changelog headings and compare links. `make test-llvm` builds
every test with `--backend=llvm`. `make docs-check` validates the documentation
site and its links, and `make docs-format-check` fails when `mint format` would
rewrite a page. CI runs the library and docs gates. The Windows resize path is
a documented manual check; CI covers Ubuntu and macOS. This project follows the
[Contributor Covenant](CODE_OF_CONDUCT.md).

## License

GPL-3.0-or-later, the same license family as Salam itself. See
[LICENSE](LICENSE). Because basalam is GPL, programs that include it are
distributed under the GPL too.

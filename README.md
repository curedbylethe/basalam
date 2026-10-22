# basalam

A retained-mode terminal user interface (TUI) library for the
[Salam](https://github.com/SalamLang/Salam) programming language.

basalam is a library, not an application: your program includes it to
build full-screen terminal interfaces. It sits on top of Salam's standard
`term` package and adds geometry, widgets, events, focus, and a screen that
draws frames.

> **Status: 0.2.0, early development.** See the
> [CHANGELOG](CHANGELOG.md) for what this release contains.

## Install

You need the Salam compiler, version 0.5.6 or later:

```sh
{ curl -fsSL https://raw.githubusercontent.com/SalamLang/Salam/refs/heads/main/install.sh || wget -qO- https://raw.githubusercontent.com/SalamLang/Salam/refs/heads/main/install.sh; } | sh
```

Salam has no third-party package registry yet, so vendor basalam into your
project and pin it to a release tag:

```sh
git submodule add https://github.com/curedbylethe/basalam vendor/basalam
git -C vendor/basalam checkout v0.2.0
git add vendor/basalam .gitmodules
git commit -m "chore: vendor basalam v0.2.0"
```

The checkout records the tag's commit in the parent repository's gitlink, and
that commit is what makes the pin reproducible: a fresh `git clone` followed
by `git submodule update --init --recursive` reproduces exactly that commit.
The submodule reports `## HEAD (no branch)`; that is expected for a pinned
submodule.

To move the pin to another release, check out its tag and commit the new
gitlink:

```sh
git -C vendor/basalam fetch --tags origin
git -C vendor/basalam checkout v0.2.0
git add vendor/basalam
git commit -m "chore: bump basalam to v0.2.0"
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

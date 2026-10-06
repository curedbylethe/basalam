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

You need the Salam compiler, version 0.4.9 or later:

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
include "vendor/basalam/basalam/basalam.salam"

func main:
    r := basalam.Rect { x = 0, y = 0, width = 80, height = 24 }
    c := r.center()
    println "basalam", basalam.Version, "center:", c.x, c.y
end
```

```sh
salam build main.salam && ./main
```

## Documentation

The full documentation (concepts, guides, and API reference) is a
[Mintlify](https://mintlify.com) site whose source lives in this repository.
Start at [`index.mdx`](index.mdx), or preview it locally:

```sh
npm i -g mint
mint dev
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). `make check` runs everything CI
runs. This project follows the [Contributor Covenant](CODE_OF_CONDUCT.md).

## License

GPL-3.0-or-later, the same license family as Salam itself. See
[LICENSE](LICENSE). Because basalam is GPL, programs that include it are
distributed under the GPL too.

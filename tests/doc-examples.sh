#!/bin/sh
# Compile every complete example in the documentation.
#
# Why: nothing used to compile the fenced examples, so reference/list.mdx
# shipped code that did not type-check. This harness extracts each example
# and runs it through the compiler on every `make check`.
#
# A block counts as a complete program only when it loads the library — an
# `include` path ending in `basalam/basalam.salam`, or the package import
# `import "github.com/curedbylethe/basalam/basalam"` — and a `func main`. A
# fragment without both assumes an ambient `screen`, `t`, or a widget defined
# earlier on the page, so it is skipped silently.
#
# The `/basalam` subpath is the only supported spelling. There is no root entry
# file, and no shape of one re-exports the package: a plain `include` is
# module-local and yields `no exported member "Version"`, while a symlink to
# the entry file exposes that file only and misses the sibling modules. A
# fence that uses the short `import "github.com/curedbylethe/basalam"` is
# therefore rejected, not skipped, because skipping it would hide the broken
# example.
#
# `salam check` rather than `salam build`: the examples are only type-checked,
# never run, and check is several times faster.
#
# Any fence whose info string starts with `salam` is seen, and everything after
# that word is ignored: a file name (```salam main.salam) or decoration
# (```salam title="a b") both count.
#
# Usage: tests/doc-examples.sh
# Env:   SALAM=path/to/salam          (default: salam on PATH)

set -u

SALAM="${SALAM:-salam}"
ROOT=$(cd "$(dirname "$0")/.." && pwd)
OUT="$ROOT/build/doc-examples"

# Skipped: this example builds the docs' `MyRoot` placeholder widget, which no
# page defines. Drop the entry once the docs define a canonical root widget
# (PR-CUR-454 Q1).
SKIP="reference/keymap.mdx"

pages=$(cd "$ROOT" && find . -name '*.mdx' \
    ! -path './.git/*' ! -path './node_modules/*' ! -path './.codegraph/*' \
    ! -path './.agents/*' ! -path './.claude/*' ! -path './.opencode/*' \
    ! -path './build/*' | sed 's|^\./||' | sort)

mkdir -p "$OUT"

pass=0
fail=0
total=0

for page in $pages; do
    [ "$page" = "$SKIP" ] && continue
    base=$(printf '%s' "$page" | sed 's|\.mdx$||; s|/|-|g')
    # One pass per page: emit the opener line of every block that holds both
    # markers, rewriting the include for the output's depth, plus a `!page:line`
    # marker for every fence whose only load is the unsupported short import.
    starts=$(awk -v out="$OUT" -v base="$base" -v page="$page" '
        /^[ ]*```salam([ ].*)?[ ]*$/ {
            inblock = 1; start = FNR; n = 0; hasinclude = 0; hasmain = 0; bad = 0
            next
        }
        inblock && /^[ ]*```[ ]*$/ {
            inblock = 0
            if (bad) {
                # Prefix marks a rejected fence: the shell reports it as failed.
                print "!" page ":" start
            } else if (hasinclude && hasmain) {
                seen++
                file = out "/" base "-" seen ".salam"
                for (i = 1; i <= n; i++) print lines[i] > file
                close(file)
                print start
            }
            next
        }
        inblock {
            line = $0
            # The short form binds no members, so the fence is a defect.
            if (line ~ /^[ ]*import[ ]+"[^"]*basalam[^"]*"/ && line !~ /basalam\/basalam/) bad = 1
            if (line ~ /^[ ]*import[ ]+"[^"]*basalam\/basalam[^"]*"/) {
                hasinclude = 1
                # An import needs a project salam.toml; the extracted example
                # has none, so load the package by path instead.
                sub(/^[ ]*import[ ]+"[^"]*"/,
                    "include \"../../basalam/basalam.salam\"", line)
            }
            if (line ~ /include[ ]+"[^"]*basalam\/basalam\.salam"/) {
                hasinclude = 1
                # include paths resolve relative to the including file.
                sub(/include[ ]+"[^"]*"/,
                    "include \"../../basalam/basalam.salam\"", line)
            }
            if (line ~ /^[ ]*func[ ]+main/) hasmain = 1
            lines[++n] = line
        }
    ' "$ROOT/$page")

    n=0
    for start in $starts; do
        case $start in
        '!'*)
            echo "doc-examples: unsupported short import in ${start#!} — use \"github.com/curedbylethe/basalam/basalam\"" >&2
            fail=$((fail + 1))
            continue
            ;;
        esac
        n=$((n + 1))
        src="$OUT/$base-$n.salam"
        total=$((total + 1))
        # `check` writes "no errors" to stdout; keep stderr, which carries the
        # diagnostics when an example is broken.
        if "$SALAM" check "$src" > /dev/null; then
            echo "ok   $page:$start"
            pass=$((pass + 1))
        else
            echo "FAIL $page:$start"
            fail=$((fail + 1))
        fi
    done
done

# A green run that compiled nothing would hide exactly the defect this checks.
if [ "$total" -eq 0 ]; then
    echo "no complete examples found; refusing to report success" >&2
    exit 1
fi

echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]

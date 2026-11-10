#!/bin/sh
# Persian name coverage gate.
#
# Every @en name must be followed directly by a non-blank @fa alias, and no
# @fa may stand alone. The pair is documentation metadata: `make build`
# proves the compiler parses it and `salam doc --lang=fa` renders it, but a
# Persian name is NOT a usable identifier (Salam 0.6.0 rejects `rect.عرض`
# with E016). The inventory in basalam-api-glossary-fa.md must carry one row
# per alias; this gate compares the counts.
#
# Usage: tests/fa-aliases.sh   (needs no compiler and no network)
set -u

ROOT=${FA_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}
GLOSSARY="$ROOT/basalam-api-glossary-fa.md"
bad=0

en=$(grep -h '^[[:space:]]*@en "' "$ROOT"/basalam/*.salam | wc -l | tr -d ' ')
fa=$(grep -h '^[[:space:]]*@fa "' "$ROOT"/basalam/*.salam | wc -l | tr -d ' ')
if [ "$en" -ne "$fa" ]; then
    echo "FAIL: $en @en annotations but $fa @fa aliases"
    bad=1
fi

for f in "$ROOT"/basalam/*.salam; do
    awk -v file="$f" '
        FNR == 1 { prev = "" }
        prev ~ /^[[:space:]]*@en "/ && $0 !~ /^[[:space:]]*@fa "[^"]*[^"[:space:]][^"]*"/ {
            printf "%s:%d: @en without a non-blank @fa alias on the next line\n", file, FNR - 1
            bad = 1
        }
        $0 ~ /^[[:space:]]*@fa/ && prev !~ /^[[:space:]]*@en "/ {
            printf "%s:%d: @fa without an @en name on the line before\n", file, FNR
            bad = 1
        }
        { prev = $0 }
        END { if (bad) exit 1 }
    ' "$f" || bad=1
done

if [ -f "$GLOSSARY" ] && [ "${FA_SKIP_GLOSSARY:-0}" != "1" ]; then
    rows=$(grep -cE '^\| (Package|Constant|Type|Field|Method|Enum|Enum variant|Function|Constructor|Interface|Static method) \|' "$GLOSSARY")
    if [ "$rows" -ne "$fa" ]; then
        echo "FAIL: $fa @fa aliases but $rows inventory rows in basalam-api-glossary-fa.md"
        bad=1
    fi
fi

# Prove the failure branches still fire: one good file and one file per
# failure mode, each run through this script in a temporary tree.
if [ "${FA_SELFTEST_CHILD:-0}" != "1" ]; then
    tmp=$(mktemp -d) || exit 1
    trap 'rm -rf "$tmp"' EXIT HUP INT TERM
    mkdir -p "$tmp/basalam"

    try() {
        printf '%s\n' "$3" > "$tmp/basalam/x.salam"
        if FA_ROOT="$tmp" FA_SKIP_GLOSSARY=1 FA_SELFTEST_CHILD=1 sh "$0" >/dev/null 2>&1; then
            rc=0
        else
            rc=1
        fi
        if [ "$rc" -ne "$2" ]; then
            echo "FAIL: gate self-test '$1' expected exit $2, got $rc"
            bad=1
        fi
    }

    try good 0 '@en "A"
@fa "الف"'
    try missing 1 '@en "A"'
    try blank 1 '@en "A"
@fa " "'
    try orphan 1 '@fa "الف"'

    if [ "$bad" -eq 0 ]; then
        echo "ok   gate rejects missing, blank, and orphan aliases"
    fi
fi

if [ "$bad" -ne 0 ]; then
    exit 1
fi
echo "ok   $en @en names, $fa @fa aliases"

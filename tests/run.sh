#!/bin/sh
# basalam test runner.
#
# Follows the convention of Salam's own test corpus (tests/en/stdlib): every
# tests/<name>.salam is a program that asserts with std/testing and ends with
# `ret testing.Summary()`, and tests/<name>.out is its golden stdout. A test
# passes when it builds, exits 0, and its stdout matches the golden file
# byte for byte. Failed assertions are reported on stderr by std/testing.
#
# Usage: tests/run.sh [name ...]      (default: every tests/*.salam)
# Env:   SALAM=path/to/salam          (default: salam on PATH)

set -u

SALAM="${SALAM:-salam}"
ROOT=$(cd "$(dirname "$0")/.." && pwd)
OUT="$ROOT/build/tests"
mkdir -p "$OUT"

# Salam links with the host toolchain on macOS; pin the deployment target to
# the running OS so the linker does not warn about mismatched versions.
if [ "$(uname -s)" = "Darwin" ] && [ -z "${MACOSX_DEPLOYMENT_TARGET:-}" ]; then
    MACOSX_DEPLOYMENT_TARGET=$(sw_vers -productVersion)
    export MACOSX_DEPLOYMENT_TARGET
fi

if [ "$#" -gt 0 ]; then
    names="$*"
else
    names=$(cd "$ROOT/tests" && ls *.salam | sed 's/\.salam$//')
fi

pass=0
fail=0
for name in $names; do
    src="$ROOT/tests/$name.salam"
    want="$ROOT/tests/$name.out"
    bin="$OUT/$name"
    got="$OUT/$name.stdout"

    if ! "$SALAM" build "$src" --output="$bin" --log-level=warn; then
        echo "FAIL $name (build)"
        fail=$((fail + 1))
        continue
    fi
    # Tests never read the terminal; give them an empty stdin so a test that
    # accidentally does cannot hang the run.
    "$bin" < /dev/null > "$got"
    code=$?
    if [ "$code" -ne 0 ]; then
        echo "FAIL $name (exit $code)"
        fail=$((fail + 1))
    elif ! diff -u "$want" "$got"; then
        echo "FAIL $name (output differs from $name.out)"
        fail=$((fail + 1))
    else
        echo "ok   $name"
        pass=$((pass + 1))
    fi
done

echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]

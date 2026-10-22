#!/bin/sh
# Release metadata checker.
#
# The version lives in `basalam/basalam.salam`, the changelog in another file,
# and the tag in a third. Nothing compared them, so a release could ship with a
# stale heading, a dead link, or an empty section. This script is the single
# place those rules are written down; `RELEASING.md` explains the policy.
#
# Usage:
#   tests/release-check.sh check        validate the working tree
#   tests/release-check.sh tag vX.Y.Z   validate the tree a tag records
#   tests/release-check.sh notes vX.Y.Z print that tag's changelog section
#
# `check` never reads a tag, so an ordinary pull request and `make check` need
# no tag, no network, and no release. `tag` reads the tagged tree with
# `git show`, so an old release can be revalidated from `main` (the v0.1.0
# commit predates this policy). `notes` prints the section verbatim for GitHub
# Release notes: the changelog is hand-written, never generated.
#
# Read-only: no network, no writes.

set -u
LC_ALL=C
export LC_ALL

ROOT=$(cd "$(dirname "$0")/.." && pwd)
SALAM_PATH=basalam/basalam.salam
CHANGELOG_PATH=CHANGELOG.md
REPO_URL=https://github.com/curedbylethe/basalam

die() {
    printf 'release-check: %s\n' "$*" >&2
    exit 1
}

usage() {
    printf 'usage: %s check | tag <tag> | notes <tag>\n' "$0" >&2
    exit 1
}

# lookup_link <name> <links text> -> the URL defined for <name>, or nothing.
lookup_link() {
    printf '%s\n' "$2" | awk -v name="$1" '$1 == name { print $2; exit }'
}

# section_body <version> <changelog text> -> the version's section, verbatim,
# without its heading, the next `## ` heading, or any trailing link definition.
section_body() {
    printf '%s\n' "$2" | awk -v heading="## [$1] - " '
        !inside && index($0, heading) == 1 { inside = 1; next }
        inside && /^## / { exit }
        inside && /^\[[^]]*\]: / { exit }
        inside { print }
    '
}

# trim_blanks <text> -> the text without leading or trailing blank lines.
trim_blanks() {
    printf '%s\n' "$1" | awk '
        NF {
            if (seen) for (i = 1; i <= held; i++) print blank[i]
            seen = 1
            held = 0
            print
            next
        }
        { blank[++held] = $0 }
    '
}

# check_metadata <salam text> <changelog text> [tag]
check_metadata() {
    salam=$1
    changelog=$2
    tag=${3:-}

    version=$(printf '%s\n' "$salam" | sed -n \
        's/^[[:space:]]*pub const Version[[:space:]]*:=[[:space:]]*"\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\)"[[:space:]]*$/\1/p')
    version_count=$(printf '%s\n' "$version" | grep -c '[0-9]')
    [ "$version_count" -eq 1 ] ||
        die "$SALAM_PATH needs exactly one \`pub const Version := \"X.Y.Z\"\`, found $version_count"

    if [ -n "$tag" ] && [ "$tag" != "v$version" ]; then
        die "tag $tag does not match Version $version"
    fi

    unreleased_count=$(printf '%s\n' "$changelog" | grep -c -x -F '## [Unreleased]')
    [ "$unreleased_count" -eq 1 ] ||
        die "$CHANGELOG_PATH needs exactly one '## [Unreleased]' heading, found $unreleased_count"

    dated=$(printf '%s\n' "$changelog" | sed -n \
        's/^## \[\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\)\] - [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$/\1/p')
    [ -n "$dated" ] ||
        die "$CHANGELOG_PATH has no dated '## [X.Y.Z] - YYYY-MM-DD' heading"

    newest=$(printf '%s\n' "$dated" | sed -n '1p')
    [ "$newest" = "$version" ] ||
        die "newest changelog heading is $newest but Version is $version"

    duplicates=$(printf '%s\n' "$dated" | sort | uniq -d)
    if [ -n "$duplicates" ]; then
        die "duplicate changelog heading for $(printf '%s\n' "$duplicates" | sed -n '1p')"
    fi

    links=$(printf '%s\n' "$changelog" | sed -n \
        's/^\[\([^]]*\)\]:[[:space:]]*\([^[:space:]]*\)$/\1 \2/p')

    for known in $dated; do
        url=$(lookup_link "$known" "$links")
        [ -n "$url" ] ||
            die "missing link definition '[$known]: $REPO_URL/...'"
        case $url in
        "$REPO_URL"/*) ;;
        *) die "[$known] link definition must point at $REPO_URL, found $url" ;;
        esac
        case $url in
        *"$known"*) ;;
        *) die "[$known] link definition does not contain the version: $url" ;;
        esac
    done

    expected_unreleased="$REPO_URL/compare/v$version...HEAD"
    unreleased_url=$(lookup_link Unreleased "$links")
    [ "$unreleased_url" = "$expected_unreleased" ] ||
        die "[Unreleased] link definition must be $expected_unreleased (found: ${unreleased_url:-none})"

    body=$(section_body "$version" "$changelog")
    has_heading=$(printf '%s\n' "$body" | grep -c '^### ')
    has_entry=$(printf '%s\n' "$body" | grep -c '^- ')
    if [ "$has_heading" -eq 0 ] || [ "$has_entry" -eq 0 ]; then
        die "changelog section for $version is empty: it needs a '### ' subheading and a '- ' entry"
    fi
}

[ "$#" -gt 0 ] || usage
mode=$1
shift

case $mode in
check)
    [ "$#" -eq 0 ] || usage
    [ -f "$ROOT/$SALAM_PATH" ] || die "missing $SALAM_PATH"
    [ -f "$ROOT/$CHANGELOG_PATH" ] || die "missing $CHANGELOG_PATH"
    check_metadata "$(cat "$ROOT/$SALAM_PATH")" "$(cat "$ROOT/$CHANGELOG_PATH")"
    ;;
tag | notes)
    [ "$#" -eq 1 ] || usage
    tag=$1
    printf '%s\n' "$tag" | grep -q -x -E 'v[0-9]+\.[0-9]+\.[0-9]+' ||
        die "tag must look like vX.Y.Z: $tag"

    commit=$(git -C "$ROOT" rev-parse --verify --quiet "$tag^{commit}") ||
        die "no such tag: $tag"
    salam=$(git -C "$ROOT" show "$commit:$SALAM_PATH") ||
        die "cannot read $SALAM_PATH at $tag"
    changelog=$(git -C "$ROOT" show "$commit:$CHANGELOG_PATH") ||
        die "cannot read $CHANGELOG_PATH at $tag"

    if [ "$mode" = tag ]; then
        object_type=$(git -C "$ROOT" cat-file -t "refs/tags/$tag")
        [ "$object_type" = tag ] ||
            die "$tag is a lightweight tag; releases use annotated tags (git tag -a)"
        check_metadata "$salam" "$changelog" "$tag"
    else
        body=$(trim_blanks "$(section_body "${tag#v}" "$changelog")")
        [ -n "$body" ] || die "changelog has no section for ${tag#v} at $tag"
        printf '%s\n' "$body"
    fi
    ;;
*)
    usage
    ;;
esac

#!/usr/bin/env bash
# Prints the repositories of repositories.list, one per line.
#
# Usage: scripts/list-repositories.sh [--all|--image|--optional]
#
#   --all       every repository (default)
#   --image     the repositories whose programs the image brings: all but the optional ones
#   --optional  the optional ones, marked "# optional" after their name: the games that are not in the image
#               and come only from the package repository (apt.amadeos.eu, Software), together or as the meta
#               package amadeos-games
set -euo pipefail

list="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/repositories.list"
mode="${1:---all}"
case "$mode" in
    --all) sed -e 's/#.*//' "$list" | awk 'NF { print $1 }' ;;
    --optional) sed -n 's/^[[:space:]]*\([A-Za-z0-9._-]\{1,\}\)[[:space:]]*#[[:space:]]*optional\b.*/\1/p' "$list" ;;
    --image) grep -vE '^[[:space:]]*[A-Za-z0-9._-]+[[:space:]]*#[[:space:]]*optional\b' "$list" \
        | sed -e 's/#.*//' | awk 'NF { print $1 }' ;;
    -h|--help) sed -n '2,10p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//' ;;
    *) echo "Unknown option: $mode (see --help)" >&2; exit 1 ;;
esac

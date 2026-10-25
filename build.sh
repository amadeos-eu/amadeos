#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Prints how long the image build took, also when it fails (75 -> "1m 15s", 3725 -> "1h 02m 05s").
report_duration() {
    local status=$? s=$SECONDS took
    if [ "$s" -ge 3600 ]; then took=$(printf '%dh %02dm %02ds' $((s / 3600)) $((s % 3600 / 60)) $((s % 60)))
    elif [ "$s" -ge 60 ]; then took=$(printf '%dm %02ds' $((s / 60)) $((s % 60)))
    else took="${s}s"; fi
    if [ "$status" -eq 0 ]; then
        printf '\n[build] Image built in %s\n' "$took"
    else
        printf '\n[build] Image build failed after %s\n' "$took" >&2
    fi
    return "$status"
}
trap report_duration EXIT

"$ROOT_DIR/scripts/build-image.sh" "$@"

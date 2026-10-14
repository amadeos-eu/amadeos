#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_ISO="$ROOT_DIR/artifacts/amadeos-amd64.iso"
ISO="${1:-$DEFAULT_ISO}"
RAM="${QEMU_RAM:-1024}"

if [[ ! -f "$ISO" ]]; then
    echo "Error: ISO image not found at: $ISO" >&2
    echo "Please build the ISO image first using: sudo ./build.sh" >&2
    exit 1
fi

echo "Launching QEMU for $ISO with ${RAM}M RAM..."

KVM_ARGS=()
if [[ -r /dev/kvm ]] && [[ -w /dev/kvm ]]; then
    KVM_ARGS=("-enable-kvm")
fi

exec qemu-system-x86_64 \
    "${KVM_ARGS[@]}" \
    -m "$RAM" \
    -usb \
    -device usb-tablet \
    -cdrom "$ISO" \
    -audiodev pipewire,id=audio0 \
    -device intel-hda -device hda-duplex,audiodev=audio0 \
    "$@"
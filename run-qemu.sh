#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_ISO="$ROOT_DIR/artifacts/amadeos-amd64.iso"
ISO="$DEFAULT_ISO"
if [[ $# -gt 0 && "$1" != -* ]]; then
    ISO="$1"
    shift
fi
RAM="${QEMU_RAM:-2048}"  # Default to 2GB RAM if QEMU_RAM is not set

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

# QEMU cannot emulate WLAN. To try WLAN in the guest, hand a USB WLAN stick to it:
#   QEMU_WLAN_USB=0bda:8179 ./run-qemu.sh        (vendor:product from lsusb)
# The host loses the stick while the guest runs; /dev/bus/usb access may need sudo or a udev rule.
WLAN_ARGS=()
if [[ -n "${QEMU_WLAN_USB:-}" ]]; then
    WLAN_ARGS=(-device qemu-xhci,id=xhci
               -device "usb-host,bus=xhci.0,vendorid=0x${QEMU_WLAN_USB%%:*},productid=0x${QEMU_WLAN_USB##*:}")
    echo "Passing USB device $QEMU_WLAN_USB to the guest"
fi

# -nic: wired network, NAT through the host (user mode, no root needed); the guest gets 10.0.2.15 by DHCP.
# -audiodev/intel-hda: sound card for the bell and amade-audio, played through the host's PipeWire.
exec qemu-system-x86_64 \
    "${KVM_ARGS[@]}" \
    -m "$RAM" \
    -usb \
    -device usb-tablet \
    -cdrom "$ISO" \
    -nic user,model=virtio-net-pci \
    -audiodev pipewire,id=audio0 \
    -device intel-hda -device hda-duplex,audiodev=audio0 \
    "${WLAN_ARGS[@]}" \
    "$@"

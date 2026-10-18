#!/usr/bin/env bash
# Boots the live image in QEMU.
#
#   ./run-qemu.sh [ISO] [OPTIONS] [-- QEMU ARGUMENTS]
#
#   --install-disk [PATH]  attach an empty disk to install amadeOS onto (default artifacts/install-disk.qcow2,
#                          QEMU_DISK_SIZE, default 20G; created when missing)
#   --boot-disk [PATH]     boot that disk instead of the ISO: the installed system
#   --uefi                 boot with UEFI firmware (OVMF) instead of BIOS; the firmware variables are kept in
#                          artifacts/ovmf-vars.fd, so an installed boot entry survives a restart
#   QEMU_RAM=4096          memory in MB (default 2048)
#   QEMU_WLAN_USB=vvvv:pppp hand a USB WLAN stick to the guest (see below)
#
# Anything else is passed on to qemu-system-x86_64.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_ISO="$ROOT_DIR/artifacts/amadeos-amd64.iso"
ISO="$DEFAULT_ISO"
if [[ $# -gt 0 && "$1" != -* ]]; then
    ISO="$1"
    shift
fi
RAM="${QEMU_RAM:-2048}"  # Default to 2GB RAM if QEMU_RAM is not set
DISK=""
BOOT_DISK=0
UEFI=0
QEMU_EXTRA=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        --install-disk|--boot-disk)
            [[ "$1" == --boot-disk ]] && BOOT_DISK=1
            DISK="$ROOT_DIR/artifacts/install-disk.qcow2"
            if [[ $# -gt 1 && "$2" != -* ]]; then DISK="$2"; shift; fi
            ;;
        --uefi) UEFI=1 ;;
        -h|--help) sed -n '2,15p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
        --) shift; QEMU_EXTRA+=("$@"); break ;;
        *) QEMU_EXTRA+=("$1") ;;
    esac
    shift
done

if [[ "$BOOT_DISK" = 0 && ! -f "$ISO" ]]; then
    echo "Error: ISO image not found at: $ISO" >&2
    echo "Please build the ISO image first using: sudo ./build.sh" >&2
    exit 1
fi

KVM_ARGS=()
if [[ -r /dev/kvm ]] && [[ -w /dev/kvm ]]; then
    KVM_ARGS=("-enable-kvm")
fi

# The disk amadeOS is installed onto (amadeos-installer), a virtio disk; the installed system boots from it.
DISK_ARGS=()
if [[ -n "$DISK" ]]; then
    if [[ ! -f "$DISK" ]]; then
        mkdir -p "$(dirname "$DISK")"
        qemu-img create -f qcow2 "$DISK" "${QEMU_DISK_SIZE:-20G}"
    fi
    DISK_ARGS=(-drive "file=$DISK,if=virtio,format=qcow2,discard=unmap")
fi
MEDIA_ARGS=()
if [[ "$BOOT_DISK" = 1 ]]; then
    MEDIA_ARGS=(-boot order=c)
else
    MEDIA_ARGS=(-cdrom "$ISO" -boot order=d)
fi

# UEFI: OVMF with its own copy of the variable store, so that the boot entry grub-install writes is kept.
UEFI_ARGS=()
if [[ "$UEFI" = 1 ]]; then
    OVMF_CODE=""
    OVMF_VARS=""
    for dir in /usr/share/OVMF /usr/share/edk2/x64 /usr/share/edk2-ovmf/x64 /usr/share/qemu; do
        if [[ -f "$dir/OVMF_CODE_4M.fd" ]]; then OVMF_CODE="$dir/OVMF_CODE_4M.fd"; OVMF_VARS="$dir/OVMF_VARS_4M.fd"; break; fi
        if [[ -f "$dir/OVMF_CODE.fd" ]]; then OVMF_CODE="$dir/OVMF_CODE.fd"; OVMF_VARS="$dir/OVMF_VARS.fd"; break; fi
    done
    [[ -n "$OVMF_CODE" ]] || { echo "OVMF not found; install the package ovmf" >&2; exit 1; }
    VARS_COPY="$ROOT_DIR/artifacts/ovmf-vars.fd"
    [[ -f "$VARS_COPY" ]] || cp "$OVMF_VARS" "$VARS_COPY"
    UEFI_ARGS=(-drive "if=pflash,format=raw,readonly=on,file=$OVMF_CODE"
               -drive "if=pflash,format=raw,file=$VARS_COPY")
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

if [[ "$BOOT_DISK" = 1 ]]; then
    echo "Launching QEMU, booting the installed system on $DISK with ${RAM}M RAM..."
else
    echo "Launching QEMU for $ISO with ${RAM}M RAM${DISK:+, install disk $DISK}..."
fi

# -nic: wired network, NAT through the host (user mode, no root needed); the guest gets 10.0.2.15 by DHCP.
# -audiodev/intel-hda: sound card for the bell and amade-audio, played through the host's PipeWire.
exec qemu-system-x86_64 \
    "${KVM_ARGS[@]}" \
    -m "$RAM" \
    -usb \
    -device usb-tablet \
    "${UEFI_ARGS[@]}" \
    "${MEDIA_ARGS[@]}" \
    "${DISK_ARGS[@]}" \
    -nic user,model=virtio-net-pci \
    -audiodev pipewire,id=audio0 \
    -device intel-hda -device hda-duplex,audiodev=audio0 \
    "${WLAN_ARGS[@]}" \
    "${QEMU_EXTRA[@]}"

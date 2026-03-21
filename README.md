# pattern

Immutable, atomic, image-based systems provisioned using Nix.

# Goals

- [x] Base image generated using `systemd-repart`
- [x] Verity on erofs root Nix Store using `systemd-veritysetup`
- [x] Inflatable TPMv2 LUKS-encrypted persistent partition using
      `systemd-repart`
- [x] Unprivileged user setup on first boot using `systemd-homed`
- [ ] Signed A/B updates over the I2P network using `systemd-sysupdate`
- [x] Distrobox, bubblewrap and xdg-dbus-proxy to install and sandbox apps
- [x] Minimal GNOME desktop

# Demonstration

To create and run a demonstration image in `virt-manager` under QEMU/KVM

1. Build the image.

   ```bash
   nix build github:sotormd/pattern#flag
   ```

2. Increase the image disk size for persistent partition.

   ```bash
   cp result/flag_*.raw /tmp/flag.raw
   chmod +w /tmp/flag.raw
   qemu-img resize -f raw /tmp/flag.raw "+100G"
   ```

3. Create a QEMU/KVM guest in `virt-manager` with UEFI and a TPM 2.0 device.
   Attach this disk and boot the guest.

{ config, ... }:

{
  imports = [

    # options
    ./options.nix

    # release
    ./release.nix

    # base image made using systemd-repart
    # dm-verity for integrity
    ./00-image.nix

    # filesystem mounts
    # inflating partitions using systemd-repart
    # tpm2 encryption
    # opt-in state persistence
    ./01-filesystem.nix

    # basic environment
    ./02-environment.nix

    # A/B updates with systemd-sysupdate
    ./03-updates.nix

    # users with systemd-homed
    ./10-homed.nix

    # gnome desktop
    ./11-desktop.nix

    # distrobox
    ./12-distrobox.nix

    # bubblewrap and xdg-dbus-proxy
    ./13-sandboxing.nix

    # debug
    ./90-debug.nix
    ./91-quiet.nix

  ];

  # systemd in initrd
  boot.initrd.systemd.enable = true;

  system = {

    # image id and version
    image = { inherit (config.pattern.image) id version; };

    # distro name
    nixos.distroName = "${config.system.image.id}_${config.system.image.version}";

    # do not change
    stateVersion = "25.11";

  };
}

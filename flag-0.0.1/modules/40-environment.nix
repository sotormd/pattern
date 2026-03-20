{ pkgs, lib, ... }:

{
  # list of packages
  environment.systemPackages = [

    # editor
    pkgs.neovim

    # filesystem
    pkgs.xfsprogs
    pkgs.cryptsetup

    # containers
    pkgs.distrobox

    # sandboxing
    pkgs.bubblewrap
    pkgs.xdg-dbus-proxy

    # gnome console & nautilus
    pkgs.gnome-console
    pkgs.nautilus

  ];

  # backend for distrobox
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  # gnome desktop
  services = {
    desktopManager.gnome = {
      enable = true;
      extraGSettingsOverrides = ''
        [org.gnome.shell]
        welcome-dialog-last-shown-version='9999999999'
      '';
    };
    gnome = {
      core-apps.enable = false;
      core-developer-tools.enable = false;
    };
    displayManager.gdm.enable = true;
  };

  # use system user ranges for gdm
  users.users = {
    gdm-greeter.uid = lib.mkForce 880;
    gdm-greeter-1.uid = lib.mkForce 881;
    gdm-greeter-2.uid = lib.mkForce 882;
    gdm-greeter-3.uid = lib.mkForce 883;
    gdm-greeter-4.uid = lib.mkForce 884;
  };

  # disable stuff we dont need
  boot.loader.grub.enable = false;
  system = {
    switch.enable = false;
    tools = {
      nixos-version.enable = false;
      nixos-rebuild.enable = false;
      nixos-option.enable = false;
      nixos-install.enable = false;
      nixos-generate-config.enable = false;
      nixos-enter.enable = false;
      nixos-build-vms.enable = false;
    };
  };
  nix.enable = false;
  nixpkgs.flake = {
    setNixPath = false;
    setFlakeRegistry = false;
  };
  documentation.nixos.enable = false;
  users.users.root.hashedPassword = "!";
}

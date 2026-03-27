{ pkgs, ... }:

{
  # list of packages
  environment.systemPackages = [

    # editor
    pkgs.vim

    # filesystem
    pkgs.xfsprogs
    pkgs.cryptsetup

  ];

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
  security.sudo.enable = false;
  programs.nano.enable = false;
}

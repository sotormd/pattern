{
  config,
  pkgs,
  lib,
  ...
}:

{
  config = lib.mkIf config.pattern.userspace.distrobox {
    environment.systemPackages = [ pkgs.distrobox ];
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
    };
  };
}

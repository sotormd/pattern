{
  config,
  pkgs,
  lib,
  ...
}:

{
  config = lib.mkIf config.pattern.userspace.sandboxing {
    environment.systemPackages = [
      pkgs.bubblewrap
      pkgs.xdg-dbus-proxy
    ];
  };
}

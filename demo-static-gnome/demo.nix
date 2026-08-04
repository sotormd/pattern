{ pkgs, ... }:

{
  pattern = {
    image = {
      id = "demo";
      version = "static-gnome";
      updates = {
        enable = false;
      };
    };
    partitions = {
      disk = "/dev/sda";
      sizes = {
        esp = "200M";
        verity = "200M";
        usr = "5G";
      };
      persist = {
        etc = true;
        home = true;
        srv = true;
        var = true;
      };
    };
    userspace = {
      homed = true;
      desktop = true;
      distrobox = true;
      sandboxing = false;
    };
    debug = false;
  };

  users.users.root.initialPassword = "demo";

  environment.systemPackages = [ pkgs.fastfetch ];

  # do not change
  system.stateVersion = "25.11";
}

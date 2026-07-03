{ pkgs, ... }:

{
  pattern = {
    image = {
      id = "demo";
      version = "static";
      updates = {
        enable = false;
      };
    };
    partitions = {
      disk = "/dev/sda";
      sizes = {
        esp = "200M";
        verity = "200M";
        usr = "2G";
      };
      persist = {
        etc = true;
        home = true;
        srv = true;
        var = true;
      };
    };
    userspace = {
      homed = false;
      desktop = false;
      distrobox = true;
      sandboxing = false;
    };
    debug = true;
  };

  boot.kernelParams = [ "console=ttyS0" ];

  users.users.root.initialPassword = "demo";

  environment.systemPackages = [ pkgs.fastfetch ];

  # do not change
  system.stateVersion = "25.11";
}

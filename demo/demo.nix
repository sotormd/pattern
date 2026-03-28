{
  pattern = {
    image = {
      id = "demo";
      updates = {
        url = "https://github.com/sotormd/pattern/releases/latest/download";
        pubring = ./demo-pubring.pgp;
      };
    };
    partitions = {
      disk = "/dev/sda";
      sizes = {
        esp = "200M";
        verity = "200M";
        usr = "1G";
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
}

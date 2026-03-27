{
  config,
  pkgs,
  lib,
  ...
}:

{
  # additional partitions to create/inflate
  boot.initrd.systemd.repart = {
    enable = true;
    device = config.pattern.partitions.disk;
  };
  systemd.repart.partitions = {
    "00-esp" = {
      Type = "esp";
      Format = "vfat";
      SizeMinBytes = config.pattern.partitions.sizes.esp;
      SizeMaxBytes = config.pattern.partitions.sizes.esp;
    };
    "10-usr-verity-a" = {
      Type = "usr-verity";
      SizeMinBytes = config.pattern.partitions.sizes.verity;
      SizeMaxBytes = config.pattern.partitions.sizes.verity;
    };
    "20-usr-a" = {
      Type = "usr";
      SizeMinBytes = config.pattern.partitions.sizes.usr;
      SizeMaxBytes = config.pattern.partitions.sizes.usr;
    };
    "30-usr-verity-b" = {
      Type = "usr-verity";
      SizeMinBytes = config.pattern.partitions.sizes.verity;
      SizeMaxBytes = config.pattern.partitions.sizes.verity;
      Label = "_empty";
      ReadOnly = 1;
    };
    "40-usr-b" = {
      Type = "usr";
      SizeMinBytes = config.pattern.partitions.sizes.usr;
      SizeMaxBytes = config.pattern.partitions.sizes.usr;
      Label = "_empty";
      ReadOnly = 1;
    };
    "50-persist" = {
      Type = "linux-generic";
      Label = "persist";
      Format = "xfs";
      Encrypt = "tpm2"; # use tpm encryption
      MakeDirectories = "/root/etc /root/home /root/srv /root/var /root/nix/upper /root/nix/work";
    };
  };

  # actual mounts
  boot.initrd.luks.devices = {
    persist = {
      device = "/dev/disk/by-partlabel/persist";
      preLVM = true;
    };
  };
  fileSystems =
    let
      tmp = {
        fsType = "tmpfs";
        neededForBoot = true;
      };
      persist = dir: {
        device = "/persist/root${dir}";
        options = [ "bind" ];
        neededForBoot = true;
      };
    in
    {
      "/nix/store" = {
        device = "/usr/nix/store";
        options = [ "bind" ];
        neededForBoot = true;
      };
      "/persist" = {
        device = "/dev/mapper/persist";
        fsType = "xfs";
        neededForBoot = true;
      };
    }
    // builtins.listToAttrs (
      map
        (dir: {
          name = dir;
          value = tmp;
        })
        [
          "/"
        ]
    )
    // builtins.listToAttrs (
      map
        (dir: {
          name = dir;
          value = persist dir;
        })
        (
          (lib.optional config.pattern.partitions.persist.etc "/etc")
          ++ (lib.optional config.pattern.partitions.persist.home "/home")
          ++ (lib.optional config.pattern.partitions.persist.srv "/srv")
          ++ (lib.optional config.pattern.partitions.persist.var "/var")
        )
    );

  # usr mount options
  boot.kernelParams = [
    "mount.usrfstype=erofs"
    "mount.usrflags=ro"
  ];

  # usr verity BEFORE repart
  boot.initrd.systemd.services.systemd-repart.after = [ "systemd-veritysetup@usr.service" ];

  # tpm2 support
  boot.initrd.luks.forceLuksSupportInInitrd = true;
  boot.initrd.systemd.tpm2.enable = true;
  systemd.tpm2.enable = true;

  # xfs support
  boot.initrd.systemd.extraBin."mkfs.xfs" = "${pkgs.xfsprogs}/bin/mkfs.xfs";
  boot.initrd.kernelModules = [
    "dm_mod"
    "dm_crypt"
    "xfs"
  ]
  ++ config.boot.initrd.luks.cryptoModules;
}

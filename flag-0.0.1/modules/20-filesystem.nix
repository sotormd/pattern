{ config, pkgs, ... }:

{
  # additional partitions to create/inflate
  boot.initrd.systemd.repart = {
    enable = true;
    device = "/dev/sda";
  };
  systemd.repart.partitions = {
    persist = {
      Type = "linux-generic";
      Label = "persist";
      Format = "xfs";
      Encrypt = "tpm2"; # use tpm encryption
      MakeDirectories = "/root/etc /root/home /root/var /work";
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
      "/" = {
        device = "/dev/mapper/root";
        fsType = "erofs";
        options = [ "ro" ];
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
          "/bin" # nixos creates the /bin/sh symlink
          "/usr" # nixos creates the /usr/bin/env symlink
          "/tmp" # tmp should obviously be tmpfs
        ]
    )
    // builtins.listToAttrs (
      map
        (dir: {
          name = dir;
          value = persist dir;
        })
        [
          "/etc" # configuration
          "/home" # user homes
          "/var" # variable service data
        ]
    );

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

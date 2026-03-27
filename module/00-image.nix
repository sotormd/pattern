{
  modulesPath,
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) efiArch;
  inherit (config.image.repart.verityStore) partitionIds;
in
{
  imports = [
    "${modulesPath}/image/repart.nix"
    "${modulesPath}/system/boot/uki.nix"
  ];

  image.repart = {
    split = true;
    verityStore.enable = true;

    partitions = {
      ${partitionIds.esp} = {
        contents = {
          "/EFI/BOOT/BOOT${lib.toUpper efiArch}.EFI".source =
            "${pkgs.systemd}/lib/systemd/boot/efi/systemd-boot${efiArch}.efi";

          "/loader/loader.conf".source = builtins.toFile "loader.conf" ''
            timeout 20
          '';
        };
        repartConfig = {
          Type = "esp";
          Format = "vfat";
          SizeMinBytes = config.pattern.partitions.sizes.esp;
          SizeMaxBytes = config.pattern.partitions.sizes.esp;
          SplitName = "-";
        };
      };
      ${partitionIds.store-verity}.repartConfig = {
        SizeMinBytes = config.pattern.partitions.sizes.verity;
        SizeMaxBytes = config.pattern.partitions.sizes.verity;
        Label = "verity-${config.system.image.version}";
        SplitName = "verity";
        ReadOnly = 1;
      };
      ${partitionIds.store}.repartConfig = {
        Minimize = "best";
        Label = "usr-${config.system.image.version}";
        SplitName = "usr";
        ReadOnly = 1;
      };
    };

  };

  boot.initrd.systemd.dmVerity.enable = true;
}

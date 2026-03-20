{
  modulesPath,
  config,
  pkgs,
  ...
}:

{
  # some modules we need
  imports = [
    "${modulesPath}/image/repart.nix"
    "${modulesPath}/system/boot/uki.nix"
  ];

  # for the image
  image.repart = {

    name = config.system.image.id;
    version = config.system.image.version;

    # partitions in the image
    partitions = {

      # first partition is the ESP boot partition with the UKIs
      "00-esp" = {
        contents = {
          "/".source = pkgs.runCommand "esp-contents" { } ''
            mkdir -p $out/EFI/BOOT
            cp ${config.system.build.uki}/${config.system.boot.loader.ukiFile} $out/EFI/BOOT/BOOTX64.EFI
          '';
        };
        repartConfig = {
          Type = "esp";
          Format = "vfat";
        };
      };

      # second partition is the erofs root partition with the Nix Store
      "10-root" = {
        storePaths = [ config.system.build.toplevel ];
        repartConfig = {
          Type = "root";
          Label = "root";
          Format = "erofs";
          Minimize = "best";
          Verity = "data";
          VerityMatchKey = "root";
          MakeDirectories = "/bin /boot /dev /etc /home /lib /lib64 /nix /persist /proc /root /run /srv /sys /tmp /usr /var";
        };
      };

      # third partition is the verity partition for the root
      "20-root-verity" = {
        repartConfig = {
          Type = "root-verity";
          Label = "root-verity";
          Verity = "hash";
          VerityMatchKey = "root";
          Minimize = "best";
        };
      };

    };

  };
}

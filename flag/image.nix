{ pkgs, lib, ... }:

let
  stubhash = "0000000000000000000000000000000000000000000000000000000000000000"; # fake hash that we replace later
  nixos =
    (pkgs.nixos (

      {
        modulesPath,
        config,
        pkgs,
        ...
      }:

      {
        imports = [
          "${modulesPath}/image/repart.nix"
          "${modulesPath}/system/boot/uki.nix"
          ./additional-config.nix
        ];

        image.repart = {
          name = "flag";
          version = "0.0.1";

          partitions = {
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
            "10-root" = {
              storePaths = [ config.system.build.toplevel ];
              repartConfig = {
                Type = "root";
                Label = "root";
                Format = "erofs";
                Minimize = "best";
                Verity = "data";
                VerityMatchKey = "root";
                MakeDirectories = "/bin /boot /dev /etc /home /lib /lib64 /nix /proc /root /run /srv /sys /tmp /usr /var";
              };
            };
            "20-root-verity" = {
              repartConfig = {
                Type = "root-verity";
                Label = "root-verity";
                Verity = "hash";
                VerityMatchKey = "root";
                Minimize = "best";
              };
            };
            "50-home" = {
              repartConfig = {
                Type = "home";
                Label = "home";
                Format = "xfs";
              };
            };
          };
        };

        fileSystems =
          let
            tmp = {
              neededForBoot = true;
              fsType = "tmpfs";
            };
          in
          {
            "/" = {
              device = "/dev/mapper/root";
              fsType = "erofs";
              options = [ "ro" ];
            };
          }
          // builtins.listToAttrs (
            map
              (dir: {
                name = dir;
                value = tmp;
              })
              [
                "/var" # services need to write to var
                "/etc" # things may need to write to etc
                "/bin" # nixos creates the /bin/sh symlink
                "/usr" # nixos creates the /usr/bin/env symlink
                "/tmp" # tmp should obviously be tmpfs
              ]
          );

        boot = {
          loader.grub.enable = false;
          initrd = {
            systemd = {
              enable = true;
              dmVerity.enable = true;
              network.enable = true;
              repart = {
                enable = true;
                device = "/dev/sda";
              };
              tpm2.enable = true;
            };
            luks.forceLuksSupportInInitrd = true;
            kernelModules = [
              "dm_mod"
              "dm_crypt"
            ]
            ++ config.boot.initrd.luks.cryptoModules;
          };
          kernelParams = [
            "console=ttyS0"
            "roothash=${stubhash}" # use fake hash
          ];
          supportedFilesystems = {
            xfs = true;
          };
        };

        systemd = {
          repart.partitions = {
            home = {
              Type = "home";
              Label = "home";
              Format = "xfs"; # this should both grow the partition + xfs_growfs the filesystem
              Encrypt = "tpm2"; # tpm-backed luks encryption on /home
            };
          };
          tpm2.enable = true;
          network.enable = true;
        };
        networking = {
          useNetworkd = true;
          useDHCP = true;
        };
        services.resolved.enable = true;

        system = {
          switch.enable = false; # updates wont be delivered like this :p
          stateVersion = "25.11";
        };

        environment.systemPackages = [
          pkgs.vim # probably need an editor
          pkgs.cryptsetup # might need this for setting a passphrase instead of tpm
        ];
      }
    )).image.overrideAttrs
      (oldAttrs: {
        nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ pkgs.jq ];
        postInstall = ''
          realRoothash=$(${lib.getExe pkgs.jq} -r "[.[] | select(.roothash != null)] | .[0].roothash" $out/repart-output.json)
          sed -i "0,/${stubhash}/ s/${stubhash}/$realRoothash/" $out/${oldAttrs.pname}_${oldAttrs.version}.raw
        ''; # replace fake hash with the real one
      });
in
{
  inherit nixos;
}

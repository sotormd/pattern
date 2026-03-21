{ pkgs, lib, ... }:

let
  stubhash = "0000000000000000000000000000000000000000000000000000000000000000"; # fake hash that we replace later
  nixos =
    (pkgs.nixos

      {
        imports = [

          # image definition with systemd-repart
          ./10-image.nix

          # filesystem definitions with systemd-repart
          ./20-filesystem.nix

          # initial setup systemd-homed
          ./30-setup.nix

          # packages and desktop
          ./40-environment.nix

          # quiet boot
          ./91-quiet.nix

          # root autologin
          # ./92-debug.nix

        ];

        # image options
        system.image = {
          id = "flag";
          version = "0.0.1";
        };

        # options to enable dm-verity
        boot = {
          kernelParams = [ "roothash=${stubhash}" ];
          initrd.systemd = {
            enable = true;
            dmVerity.enable = true;
            services.systemd-repart.after = [ "systemd-veritysetup@root.service" ];
          };
        };

        # do not change
        system.stateVersion = "25.11";
      }
    ).image.overrideAttrs
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

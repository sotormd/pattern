{
  description = "image-based atomic nix-provisioned systems";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      perSystem =
        { pkgs, ... }:
        {
          packages = {
            flag = pkgs.callPackage ./flag-0.0.1 { };

            qemu = pkgs.callPackage (
              { pkgs, ... }:
              pkgs.writeShellApplication {
                name = "boot-uefi-qemu";

                runtimeInputs = [
                  pkgs.qemu
                  pkgs.swtpm
                ];

                text =
                  let
                    tpmOVMF = pkgs.OVMF.override { tpmSupport = true; };
                  in
                  ''
                    swtpm socket -d --tpmstate dir="$2" \
                      --ctrl type=unixio,path="$2/swtpm-sock" \
                      --tpm2 \
                      --log level=20                  

                    qemu-system-x86_64 \
                      -enable-kvm \
                      -m 4G \
                      -nographic \
                      -drive if=pflash,format=raw,readonly=on,file=${tpmOVMF.firmware} \
                      -drive if=pflash,format=raw,readonly=on,file=${tpmOVMF.variables} \
                      -chardev socket,id=chrtpm,path="$2/swtpm-sock" \
                      -tpmdev emulator,id=tpm0,chardev=chrtpm \
                      -device tpm-tis,tpmdev=tpm0 \
                      -drive "format=raw,file=$1"
                  '';
              }
            ) { };
          };
        };
    };
}

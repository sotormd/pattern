{ config, pkgs, ... }:

{
  pattern.release =
    let
      name = config.system;
      verityImgAttrs = builtins.fromJSON (
        builtins.readFile "${name.build.finalImage}/repart-output.json"
      );
      usrAttrs = builtins.elemAt verityImgAttrs 2;
      verityAttrs = builtins.elemAt verityImgAttrs 1;
      usrUuid = usrAttrs.uuid;
      verityUuid = verityAttrs.uuid;
    in
    pkgs.runCommand "pattern-release" { } ''
      mkdir $out

      cp ${name.build.finalImage}/${name.image.id}_${name.image.version}.raw $out/

      cp ${name.build.uki}/${name.boot.loader.ukiFile} \
        $out/PART_${name.boot.loader.ukiFile}

      cp ${name.build.finalImage}/${name.image.id}_${name.image.version}.usr.raw \
        $out/PART_${name.image.id}_${name.image.version}_${usrUuid}.usr.raw

      cp ${name.build.finalImage}/${name.image.id}_${name.image.version}.verity.raw \
        $out/PART_${name.image.id}_${name.image.version}_${verityUuid}.verity.raw

      cd $out
      sha256sum * > SHA256SUMS
    '';
}

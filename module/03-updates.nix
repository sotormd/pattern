{ config, lib, ... }:

{
  environment.etc."systemd/import-pubring.pgp".source = config.pattern.image.updates.pubring;

  systemd.sysupdate.enable = lib.mkDefault true;
  systemd.sysupdate.reboot.enable = lib.mkDefault false;

  systemd.sysupdate.transfers = {
    "00-uki" = {
      Transfer = {
        Verify = "yes";
      };
      Source = {
        Type = "url-file";
        Path = "${config.pattern.image.updates.url}";
        MatchPattern = "PART_${config.boot.uki.name}_@v.efi";
      };
      Target = {
        Type = "regular-file";
        Path = "/EFI/Linux";
        PathRelativeTo = "esp";
        MatchPattern = "PART_${config.boot.uki.name}_@v.efi";
        Mode = "0644";
        TriesLeft = 3;
        TriesDone = 0;
        InstancesMax = 2;
      };
    };
    "10-usr-verity" = {
      Transfer = {
        Verify = "yes";
      };
      Source = {
        Type = "url-file";
        Path = "${config.pattern.image.updates.url}";
        MatchPattern = "PART_${config.system.image.id}_@v_@u.verity";
      };
      Target = {
        Type = "partition";
        Path = "auto";
        MatchPattern = "verity-@v";
        MatchPartitionType = "usr-verity";
        ReadOnly = 1;
      };
    };
    "20-usr" = {
      Transfer = {
        Verify = "yes";
      };
      Source = {
        Type = "url-file";
        Path = "${config.pattern.image.updates.url}";
        MatchPattern = "PART_${config.system.image.id}_@v_@u.usr";
      };
      Target = {
        Type = "partition";
        Path = "auto";
        MatchPattern = "usr-@v";
        MatchPartitionType = "usr";
        ReadOnly = 1;
      };
    };
  };
}

{
  config,
  pkgs,
  lib,
  ...
}:

{
  config = lib.mkIf config.pattern.userspace.homed {

    services.homed.enable = true;

    systemd.services."setup-subuid-subgid" = {
      description = "Assign subuid/subgid for single homed user";
      after = [ "multi-user.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
      };

      path = [
        pkgs.systemd
        pkgs.gnugrep
        pkgs.gawk
        pkgs.coreutils-full
      ];

      script = ''
        HUSERNAME=$(homectl | grep bash | awk '{print $1}')

        if ! grep -q "^$HUSERNAME:" /etc/subuid; then
          echo "$HUSERNAME:524288:65536" >> /etc/subuid
        fi

        if ! grep -q "^$HUSERNAME:" /etc/subgid; then
          echo "$HUSERNAME:524288:65536" >> /etc/subgid
        fi
      '';
    };

  };
}

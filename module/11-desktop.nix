{
  config,
  pkgs,
  lib,
  ...
}:

{
  config = lib.mkIf config.pattern.userspace.desktop {

    # gnome desktop
    services = {
      desktopManager.gnome = {
        enable = true;
        extraGSettingsOverrides = ''
          [org.gnome.shell]
          welcome-dialog-last-shown-version='9999999999'
        '';
      };
      gnome = {
        core-apps.enable = false;
        core-developer-tools.enable = false;
      };
      displayManager.gdm.enable = true;
    };
    environment.gnome.excludePackages = [ pkgs.gnome-tour ];
    environment.systemPackages = [ pkgs.gnome-console ];

    # use system user ranges for gdm
    users.users = {
      gdm-greeter.uid = lib.mkForce 880;
      gdm-greeter-1.uid = lib.mkForce 881;
      gdm-greeter-2.uid = lib.mkForce 882;
      gdm-greeter-3.uid = lib.mkForce 883;
      gdm-greeter-4.uid = lib.mkForce 884;
    };

  };
}

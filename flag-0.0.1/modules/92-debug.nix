{
  services.getty.autologinUser = "root";
  boot.initrd.systemd.emergencyAccess = true;
  systemd.enableEmergencyMode = true;
  boot.kernelParams = [ "systemd.setenv=SYSTEMD_SULOGIN_FORCE=1" ];
}

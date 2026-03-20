{
  # quiet boot
  boot = {
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
    consoleLogLevel = 3;
    kernel.sysctl = {
      "kernel.printk" = "3 3 3 3";
    };
  };
}

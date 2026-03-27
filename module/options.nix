{ lib, ... }:

{
  options = {

    pattern = {

      # image id, version and update options
      image = {
        id = lib.mkOption { type = lib.types.str; };
        version = lib.mkOption { type = lib.types.str; };
        updates = {
          url = lib.mkOption { type = lib.types.str; };
          pubring = lib.mkOption { type = lib.types.path; };
        };
      };

      # partition sizes and persistence
      partitions = {
        disk = lib.mkOption { type = lib.types.str; };
        sizes = {
          esp = lib.mkOption { type = lib.types.str; };
          verity = lib.mkOption { type = lib.types.str; };
          usr = lib.mkOption { type = lib.types.str; };
        };
        persist = {
          etc = lib.mkEnableOption false;
          home = lib.mkEnableOption false;
          srv = lib.mkEnableOption false;
          var = lib.mkEnableOption false;
        };
      };

      # whether to enable root autologin
      debug = lib.mkEnableOption true;

      # some userspace options
      userspace = {
        homed = lib.mkEnableOption false;
        desktop = lib.mkEnableOption false;
        distrobox = lib.mkEnableOption false;
        sandboxing = lib.mkEnableOption false;
      };

      # pattern release package
      release = lib.mkOption { type = lib.types.package; };

    };
  };
}

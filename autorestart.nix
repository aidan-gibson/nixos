{ config, pkgs, lib, inputs, ... }:

# https://nixos.wiki/wiki/Hardware/Apple auto restart
with lib;

let
  register = {
    "mini_white_intel+nVidia" = "00:03.0 0x7b.b=0x19";
    "mini_white_intel" = "0:1f.0 0xa4.b=0";
    "mini_unibody_intel" = "0:3.0 -0x7b=20";
    "mini_unibody_M1" = "?";
  };
  cfg = config.autoRestart;

in {
  options.autoRestart = {
    macVariant = mkOption {
      type = types.enum (attrNames register);
      default = elemAt (attrNames register) 0;
      example = elemAt (attrNames register) 0;
      description =
        "Minor hardware variants have different registers for enabling autostart";
    };
    enable = mkEnableOption "autoRestart";
  };

  config = mkIf cfg.enable {
    # Needs to run every reboot
    systemd.services.enable-autorestart = {
      script = ("${pkgs.pciutils}/bin/setpci -s "
          + (getAttr cfg.macVariant register));
      wantedBy = [ "default.target" ];
      after = [ "default.target" ];
    };
  };
}

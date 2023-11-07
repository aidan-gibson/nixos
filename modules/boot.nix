{ config, lib, pkgs, options, ... }:

with lib;

let cfg = config.modules.boot;

in {
  # options.modules.boot = {
  #   enable = mkEnableOption "general boot and kernel options";

  #   kernelPackages = mkOption {
  #     type = types.unspecified // { merge = mergeEqualOption; };
  #     default = pkgs.linuxPackages_zen;
  #     defaultText = "pkgs.linuxPackages_zen";
  #     description = "see the NixOS boot.kernelPackages option for more info";
  #   };
  # };

  config = mkIf cfg.enable {

    boot = {
      kernelPackages = cfg.kernelPackages;
      supportedFilesystems = [ "btrfs" ];
      # https://mynixos.com/nixpkgs/option/boot.initrd.systemd.enable
      # initrd.systemd.enable = true;

      # tmp.useTmpfs = true;
      kernel.sysctl."kernel.sysrq" = 1;
      # kernelParams =
      #   [ "quiet" "rd.udev.log_priority=1" "rd.systemd.show_status=auto" ];
      # consoleLogLevel = 1;
    };

    boot.loader = {
      efi.canTouchEfiVariables = true;
      timeout = 1;
    };

    boot.loader.systemd-boot = {
      enable = true;
      editor = false;
      memtest86.enable = true;
    };

    console = {
      font = "latarcyrheb-sun32";
      # packages = [ pkgs.terminus_font ];
      # earlySetup = true;
    };

    # boot.plymouth.enable = true;
  };
}
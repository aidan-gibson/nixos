# /etc/nixos/configuration.nix
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, lib, options, inputs, power, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # ./autorestart.nix
  ];


  power.ups = {
    enable = true;
    maxStartDelay = 45;
    mode = "netserver";
    # openFirewall = true;
    # schedulerRules = "/etc/nixos/upssched.conf";


    ups."eaton5s700lcd" = {
      driver = "usbhid-ups";
      port = "auto";
      description = "eaton5s700lcd connected to opn, thinkcentre, ap, trix (this)";
      # summary is strings concat with \n. it's lines which would be inside ups.conf
      summary = "";
      # directives = [""];
    };

    upsd = {
      enable = true;
      # additional lines to be added to upsd.conf. strings concat w \n.
      # extraConfig = "";
      listen = [
        {
          address = "127.0.0.1";
        }


      ];

    };

    # upsmon powers down the system when powerout
    upsmon = {
      enable = true;
      monitor."eaton5s700lcd" = {
        user = "upsmon";
        type = "master";
        system = "eaton5s700lcd";
        powerValue = 1;
        passwordFile = "/etc/upsmonpass";


      };
      # settings 

    };
    users.upsmon = {
      passwordFile = "/etc/upsmonpass";
      instcmds = ["ALL"];
      # actions = [""];
      # upsmon = "master";
    };

  };


  programs = {
    #https://nixos.wiki/wiki/Zsh
    # /etc/zshrc and /etc/zprofile /etc/zshenv
    zsh = {
      enable = true;
      # TODO
      histSize = 999999999;
      shellAliases = {
        ls = "eza -a -g --icons -F -l -H -i -h -o --git -M --time-style iso --sort=modified";
        cat = "bat";
        dir = "dust -d 1 -D -b --skip-total -c -H";
        sdir = "sudo dust -d 1 -D -b --skip-total -c -H";
        tree = "ls --tree";
        reload = "source /etc/zshrc";
        reb = ''sudo nixos-rebuild switch --flake "github:aidan-gibson/nixos" --verbose --fast'';
        vers = "nixos-version --json";
        gc = "nix-store --gc";
      };
    };
  };

  nixpkgs.config.allowUnfree = true;


  # Use the systemd-boot EFI boot loader.
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;


  boot = {
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


  networking.hostName = "trix"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };



  programs.mosh.enable = true;

  services.tailscale.enable = true;



  # The following option (`boot.kernetl.sysctl = ...`) is IN PLACE OF `services.tailscale.useRoutingFeatures = "server'`. See the following bug for details:
  # https://github.com/NixOS/nixpkgs/issues/209119
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv6.conf.all.forwarding" = true;
  };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nix = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINphP8B6EmUr/ZKuj0k2XH3WERn2G4kBBkYvGpdB9m5x"
    ];
    shell = pkgs.zsh;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    variables.EDITOR = "micro";
    systemPackages = with pkgs; [
      aria
      bat
      btop
      croc
      du-dust
      duf
      eza
      fd
      file
      gh
      git
      iproute2
      iputils
      htop
      mtr
      inetutils
      nettools
      nmap
      rsync
      iperf
      micro
      neofetch
      ookla-speedtest
      python3
      ripgrep
      screen
      tmate
      usbutils
      wget
      pciutils
      coreutils
      smartmontools
      mosh
      ripgrep-all
      tealdeer
      nut
    ];
  };
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    settings.PermitRootLogin = "yes";
  };

  services.fwupd.enable = true;

  services.btrfs.autoScrub.enable = true;
  services.btrfs.autoScrub.interval = "monthly";

  nix.settings = {
    auto-optimise-store = true;
    experimental-features =
      [ "ca-derivations" "flakes" "nix-command" "repl-flake" "auto-allocate-uids" "cgroups" ];
    keep-derivations = true;
    keep-outputs = true;
    use-cgroups = true;
    trusted-users = [ "@wheel" ];
    substituters = [ "https://cache.garnix.io" ];
    trusted-public-keys =
      [ "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=" ];
  };

  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 3d";
    persistent = true;
  };

  #https://nixos.wiki/wiki/Automatic_system_upgrades
  system.autoUpgrade = {
    enable = true;
    flake = "github:aidan-gibson/nixos";
    flags = [
      "-L" # print build logs
      # these would autoupdate to latest, BUT then the lock on the gh repo wouldn't b correct. using github action to auto-gen latest flake lock instead
      # "--update-input"
      # "nixpkgs"
    ];
    dates = "02:00";
    randomizedDelaySec = "45min";
    allowReboot = true;
  };

  # autoRestart = {
  #   enable = true;
  #   macVariant = "mini_unibody_intel";
  # };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # fails on dirty git trees
  # system.configurationRevision =
  #   if inputs.self ? rev then
  #     inputs.self.rev
  #   else
  #     throw "Refusing to build from a dirty Git tree!";

  # doesn't fail
  system.configurationRevision =
    if inputs.self ? rev then
      inputs.self.rev
    else
      "Dirty Git tree";


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}

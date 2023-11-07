# /etc/nixos/configuration.nix
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, lib, options, inputs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # ./autorestart.nix
  ];

  programs = {
    #https://nixos.wiki/wiki/Zsh
    zsh = {
      enable = true;
      # TODO
      # histSize = 999999999; doesn't work
      #initExtra = "HISTSIZE=999999999"; also doesn't work
      shellAliases = {
        ls = "eza -a -g --icons -F -l -H -i -h -o --git -M --time-style iso --sort=modified";
        cat = "bat";
        dir = "dust -d 1 -D -b --skip-total -c -H";
        sdir = "sudo dust -d 1 -D -b --skip-total -c -H";
        tree = "ls --tree";
        #reb = "sudo nixos-rebuild switch --flake "github:aidan-gibson/nixos" --verbose --fast";
        # gc = "nix-store --gc";
      };
    };
  };

  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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


  services.btrfs.autoScrub.enable = true;
  services.btrfs.autoScrub.interval = "monthly";

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
  environment.systemPackages = with pkgs; [
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
    git
    htop
    inetutils
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
    mosh
    ripgrep-all
    tealdeer
  ];

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

  nix.settings = {
    auto-optimise-store = true;
    experimental-features =
      [ "ca-derivations" "flakes" "nix-command" "repl-flake" ];
    keep-derivations = true;
    keep-outputs = true;
    trusted-users = [ "@wheel" ];
    substituters = [ "https://cache.garnix.io" ];
    trusted-public-keys =
      [ "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=" ];
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

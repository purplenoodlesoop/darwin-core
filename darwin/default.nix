{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault;
  inherit (config.networking) hostName;
  user = config.system.primaryUser;
in
{
  imports = [
    ./macos.nix
    ./flake-update.nix
  ];

  fonts.packages = [
    pkgs.nerd-fonts.fira-code
  ];

  environment = {
    pathsToLink = [
      "/share/zsh"
    ];
  };

  # Caps Lock is the most reachable key on the board and does nothing useful.
  # enableKeyMapping gates the hidutil call that actually applies the remap;
  # without it the mapping is computed and then never installed.
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };

  security.pam.services.sudo_local = {
    touchIdAuth = true;
    # tmux's server runs outside the Aqua session, so processes under it have
    # no audit session and pam_tid can never prompt. Reattach to the user's
    # bootstrap session first so Touch ID works from inside tmux too.
    reattach = true;
  };

  nix = {
    enable = true;
    package = pkgs.nix;

    # Collect on a schedule rather than by hand, and dedup identical store
    # files.
    gc = {
      automatic = true;
      interval.Weekday = 0;
      options = "--delete-older-than 30d";
    };
    optimise.automatic = true;

    settings = {
      experimental-features = "nix-command flakes";

      # Needed for a non-root user to use the extra substituter below.
      trusted-users = [
        "root"
        "@admin"
      ];

      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      # Config repos are rebuilt from dirty trees constantly; the warning is noise.
      warn-dirty = false;

      # Keep dev-shell dependencies alive across GC runs, so direnv-backed
      # shells do not rebuild after every collection.
      keep-outputs = true;
      keep-derivations = true;
    };
  };

  programs = {
    zsh.enable = true;
  };

  users.users.${user}.home = mkDefault "/Users/${user}";

  networking = {
    computerName = mkDefault hostName;
    localHostName = mkDefault hostName;
  };

  nixpkgs = {
    hostPlatform = mkDefault "aarch64-darwin";
    config.allowUnfree = true;
  };
}

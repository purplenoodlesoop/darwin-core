{
  config,
  pkgs,
  ...
}:
{
  home = {
    packages = with pkgs; [
      curl
      fastfetch
      zsh-autosuggestions
      fd
      ripgrep
      jq
      git-ignore
      httpie
      # JDK 21: the version Gradle, AGP and the Kotlin toolchain target for
      # Android builds. Also supplies keytool and jarsigner.
      temurin-bin-21
      nh
      dust
      duf
      hyperfine
      tokei
    ];

    shellAliases = {
      ngc = "nix store gc";
      nswitch = "sudo darwin-rebuild switch --flake ~/.config/nix-darwin";
      ngens = "sudo nix-env -p /nix/var/nix/profiles/system --list-generations";
      newflake = "nix flake init -t git+ssh://git@github.com/purplenoodlesoop/core-flake --refresh && direnv allow";
      ncode = "nvim  ~/.config/nix-darwin";
      gch = "git checkout";
      zre = "source ~/.zshrc";
    };
    sessionVariables = {
      ANDROID_SDK = "$HOME/Library/Android/sdk";
      # Gradle and AGP look for ANDROID_HOME, not ANDROID_SDK. Without it
      # every Android project needs a hand-written local.properties.
      ANDROID_HOME = "$HOME/Library/Android/sdk";
      JAVA_HOME = "${pkgs.temurin-bin-21.home}";
      # Lets `nh darwin switch` run with no path argument, and prints a
      # package-level diff of what a rebuild would change.
      NH_FLAKE = "$HOME/.config/nix-darwin";
      EDITOR = "nvim";
      VISUAL = "nvim";
      # Man pages in neovim: real search, marks and jumps instead of less.
      MANPAGER = "nvim +Man!";
    };
  };

  programs = {
    zsh = {
      enable = true;
      autosuggestion.enable = true;
      enableCompletion = true;
      autocd = true;
      history = {
        size = 100000;
        save = 100000;
        ignoreDups = true;
        ignoreAllDups = true;
        ignoreSpace = true;
        expireDuplicatesFirst = true;
        share = true;
      };
      localVariables = {
        COMPLETION_WAITING_DOTS = "true";
        HIST_STAMPS = "dd/mm/yyyy";
      };
      initContent = ''
        . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"

        # attach-or-create a named local tmux session (persistence layer).
        #   t        -> session "main"
        #   t work   -> session "work"
        t() { tmux new-session -A -s "''${1:-main}"; }

        # fzf-tab draws the completion menu itself, so zsh's built-in one has
        # to be off. oh-my-zsh sets `menu select` on the five-component
        # pattern, which beats a plain ':completion:*' on specificity, so
        # override that exact pattern too.
        zstyle ':completion:*' menu no
        zstyle ':completion:*:*:*:*:*' menu no
      '';
      oh-my-zsh = {
        enable = true;
        custom = "${config.home.homeDirectory}/.oh-my-custom";
        theme = "cdimascio-lambda";
        plugins = [
          "colored-man-pages"
          "colorize"
          "command-not-found"
          "copybuffer" # ctrl-o to copy current command
          "git"
          "last-working-dir"
          "safe-paste"
          "timer"
        ];
      };
      plugins = [
        {
          name = "fzf-tab";
          src = pkgs.zsh-fzf-tab;
          file = "share/fzf-tab/fzf-tab.plugin.zsh";
        }
      ];
      syntaxHighlighting = {
        enable = true;
        highlighters = [
          "main"
          "brackets"
        ];
      };
    };
    # Directory jumping, replacing autojump: `z <partial>` / `zi` to pick.
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    # Ctrl-R becomes a searchable history. Up-arrow keeps its normal
    # behaviour so muscle memory is untouched.
    atuin = {
      enable = true;
      enableZshIntegration = true;
      flags = [ "--disable-up-arrow" ];
    };

    bat.enable = true;

    btop.enable = true;

    tealdeer = {
      enable = true;
      settings.updates.auto_update = true;
    };

    eza = {
      enable = true;
      enableZshIntegration = true;
      git = true;
      icons = "auto";
    };

    # Completion specs for ~1000 CLIs, rendered by fzf-tab.
    carapace = {
      enable = true;
      enableZshIntegration = true;
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
      # Atuin owns Ctrl-R; fzf keeps Ctrl-T and Alt-C.
      historyWidget.command = "";
    };
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };
}

{ lib, ... }:
let
  inherit (lib) mkDefault;
in
{
  programs.git = {
    enable = true;

    ignores = [
      "*~"
      ".DS_Store"
      "**/.claude/settings.local.json"
    ];

    # Sign with the SSH key already loaded in the agent, rather than keeping a
    # separate GPG keyring.
    signing = {
      key = mkDefault "~/.ssh/id_ed25519.pub";
      format = "ssh";
      signByDefault = mkDefault true;
    };

    settings = {
      alias = {
        s = "status --short --branch";
        lg = "log --oneline --graph --decorate";
        lga = "log --oneline --graph --decorate --all";
        last = "log -1 --stat";
        amend = "commit --amend --no-edit";
        unstage = "restore --staged";
      };

      # Matches this repo; flip to "main" if new projects should start there.
      init.defaultBranch = "master";

      pull.rebase = true;
      push = {
        autoSetupRemote = true;
        followTags = true;
      };
      fetch.prune = true;
      rebase.autosquash = true;

      # Remember conflict resolutions and replay them on the next rebase.
      rerere.enabled = true;

      diff.algorithm = "histogram";
      # Shows the common ancestor in conflicts, not just the two sides.
      merge.conflictstyle = "zdiff3";
      branch.sort = "-committerdate";
      column.ui = "auto";
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      line-numbers = true;
    };
  };

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
    };
  };

  programs.lazygit.enable = true;
}

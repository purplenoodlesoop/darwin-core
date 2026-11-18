{ ... }:
{
  # One agent at a fixed socket, which every new shell points at itself.
  # macOS's own agent moves to a new socket whenever it restarts, and a
  # long-running tmux server keeps handing its panes the old one, so
  # signing and ssh inside tmux failed until the server was restarted.
  services.ssh-agent.enable = true;

  # Commit signing asks the agent for the key before any ssh has had a
  # chance to add it, so load the keys whose passphrases are in the
  # keychain as soon as the agent is up. Until it is, ssh-add fails and
  # launchd runs it again.
  launchd.agents.ssh-add-keychain = {
    enable = true;
    config = {
      ProgramArguments = [
        "/bin/sh"
        "-c"
        ''SSH_AUTH_SOCK="$(/usr/bin/getconf DARWIN_USER_TEMP_DIR)/ssh-agent" exec /usr/bin/ssh-add --apple-load-keychain''
      ];
      RunAtLoad = true;
      KeepAlive.SuccessfulExit = false;
      ThrottleInterval = 5;
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    includes = [
      "~/.orbstack/ssh/config"
    ];

    # macOS ssh keeps key passphrases in the keychain; other ssh builds reading
    # this config skip the Apple-only option instead of failing.
    settings."*" = {
      UseKeychain = "yes";
      IgnoreUnknown = "UseKeychain";
      AddKeysToAgent = "yes";
      IdentityFile = "~/.ssh/id_ed25519";
      # Reuse one connection for repeat sessions instead of renegotiating;
      # makes back-to-back git/ssh against the same host near-instant.
      ControlMaster = "auto";
      ControlPath = "~/.ssh/master-%r@%n:%p";
      ControlPersist = "10m";
    };
  };
}

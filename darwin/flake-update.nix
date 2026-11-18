{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    literalExpression
    ;
  cfg = config.services.flake-update;
  user = config.system.primaryUser;
  inherit (cfg) repo;
  host = config.networking.hostName;
  log = "/var/log/flake-update.log";

  # Runs as root so it can activate without Touch ID; everything that touches
  # the repo or the network runs as the user, with their ssh-agent, so private
  # inputs fetch and the commit is signed and pushed as them.
  flake-update = pkgs.writeShellApplication {
    name = "flake-update";
    runtimeInputs = [
      config.nix.package
      pkgs.git
      pkgs.coreutils
    ];
    text = ''
      echo "== $(date)"
      cd ${repo}
      sock="$(/usr/bin/sudo -u ${user} /usr/bin/getconf DARWIN_USER_TEMP_DIR)ssh-agent"
      as_user() {
        /usr/bin/sudo -u ${user} -H env PATH="$PATH:/usr/bin:/bin" SSH_AUTH_SOCK="$sock" "$@"
      }
      # Posted into the user's GUI session; a root daemon has none of its own.
      notify() {
        /bin/launchctl asuser "$(/usr/bin/id -u ${user})" /usr/bin/sudo -u ${user} \
          /usr/bin/osascript -e "display notification \"$1\" with title \"Nix update\"" || true
      }
      on_exit() {
        local status=$?
        [ "$status" -eq 0 ] || notify "Failed; see ${log}"
      }
      trap on_exit EXIT

      # Uncommitted edits would be built and switched to unreviewed; wait.
      if ! as_user git diff --quiet HEAD -- . ':!flake.lock'; then
        echo "working tree has uncommitted changes; skipping"
        notify "Skipped: uncommitted changes in ${repo}"
        exit 0
      fi

      as_user nix flake update
      if as_user git diff --quiet HEAD -- flake.lock; then
        echo "inputs already up to date"
        exit 0
      fi

      if ! system="$(as_user nix build --no-link --print-out-paths \
          .#darwinConfigurations.${host}.system)"; then
        echo "build failed; restoring flake.lock"
        as_user git checkout -- flake.lock
        exit 1
      fi

      # What `darwin-rebuild switch` does, minus re-evaluating the repo as root.
      nix-env -p /nix/var/nix/profiles/system --set "$system"
      "$system/activate"

      as_user git commit -m "Update flake inputs" -- flake.lock
      as_user git push
    '';
  };
in
{
  options.services.flake-update = {
    enable = mkEnableOption "the weekly update of this system's flake inputs" // {
      default = true;
    };
    repo = mkOption {
      type = types.str;
      default = "${config.users.users.${user}.home}/.config/nix-darwin";
      defaultText = literalExpression ''"''${config.users.users.''${config.system.primaryUser}.home}/.config/nix-darwin"'';
      description = ''
        Checkout of the system flake, owned by the primary user. Its
        `darwinConfigurations` attribute must match `networking.hostName`.
      '';
    };
  };

  config.launchd.daemons.flake-update = mkIf cfg.enable {
    command = "${flake-update}/bin/flake-update";
    serviceConfig = {
      # Weekly, Monday 10:00; launchd runs a missed slot on the next wake.
      StartCalendarInterval = [
        {
          Weekday = 1;
          Hour = 10;
          Minute = 0;
        }
      ];
      StandardOutPath = log;
      StandardErrorPath = log;
    };
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption types concatStringsSep;
  cfg = config.darwinCore.tmux;
  statusRight = concatStringsSep "  " (
    cfg.statusRight
    ++ [ "#{?client_prefix,#[bg=white]#[fg=colour232]#[bold] PREFIX #[default] ,}%H:%M" ]
  );
in
{
  options.darwinCore.tmux.statusRight = mkOption {
    type = types.listOf types.str;
    default = [ ];
    example = [ "#(uptime)" ];
    description = "Segments shown in tmux's status bar before the prefix flag and the clock.";
  };

  config.programs.tmux = {
    enable = true;
    prefix = "`"; # single-key prefix; double-tap `` forwards to nested (remote) tmux
    mouse = true; # trackpad scroll + click-to-focus pane
    baseIndex = 1; # windows/panes count from 1 (matches the `1 2 3` keys)
    escapeTime = 10; # snappier esc, no lag over ssh
    historyLimit = 50000;
    terminal = "tmux-256color";
    plugins = with pkgs.tmuxPlugins; [
      resurrect
      continuum
    ];
    extraConfig = ''
      setw -g pane-base-index 1
      set -g renumber-windows on   # keep window numbers gapless after closing one

      # tmux-256color alone advertises 256 colours; this is what actually
      # carries 24-bit colour through to neovim.
      set -sa terminal-features ',xterm-kitty:RGB'
      # Let neovim's autoread fire when a pane regains focus.
      set -g focus-events on

      # --- WINDOWS (workspaces within a context) ---
      #   `c        new window (inherits current dir)
      #   `1 `2 `3  jump to window N
      #   `n / `p   next / previous window
      bind c new-window -c "#{pane_current_path}"

      # --- PANES (splits within a window) ---
      #   `|  split left|right     `-  split top/bottom   (both keep cwd)
      #   ` + arrow   move between panes
      #   ` + Shift-arrow  resize (hold prefix, repeatable)
      #   `z  zoom pane fullscreen (toggle)    `x  close pane
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind Left  select-pane -L
      bind Right select-pane -R
      bind Up    select-pane -U
      bind Down  select-pane -D
      bind -r S-Left  resize-pane -L 5
      bind -r S-Right resize-pane -R 5
      bind -r S-Up    resize-pane -U 5
      bind -r S-Down  resize-pane -D 5

      # --- SESSIONS (persistence; survive detach / terminal restart) ---
      #   `d  detach     `s  visual session tree picker     `$  rename session
      bind s choose-tree -Zs

      # Sessions previously died with the machine. resurrect snapshots them and
      # continuum saves every 15 min, restoring on the next tmux start, so
      # windows/panes/cwds survive a reboot too.
      set -g @resurrect-capture-pane-contents 'on'
      set -g @continuum-restore 'on'

      # Reload this config live with `r
      bind r source-file ~/.config/tmux/tmux.conf \; display "tmux reloaded"

      # Copy-mode yank -> system clipboard via terminal OSC-52
      set -g set-clipboard on

      # Smooth native-feeling wheel scroll (auto-enters copy-mode, exits at bottom)
      bind -n WheelUpPane if -Ft= "#{mouse_any_flag}" "send -M" "if -Ft= '#{pane_in_mode}' 'send -M' 'copy-mode -e'"

      # --- STATUS BAR: makes the hierarchy visible while you learn it ---
      # left: session name | center: window list (current highlighted) | right: PREFIX flag + clock
      set -g status-style bg=colour93,fg=white
      set -g status-left "#[bold] #S #[default] "
      set -g status-left-length 30
      set -g window-status-format " #I:#W "
      set -g window-status-current-format "#[bg=colour44,fg=colour232,bold] #I:#W #[default]"
      set -g status-interval 30
      set -g status-right-length 80
      set -g status-right "${statusRight}"
    '';
  };

  # Running sessions pick up config changes without re-sourcing by hand.
  #
  # Ordered after linkGeneration rather than writeBoundary: linkGeneration is
  # itself only entryAfter writeBoundary, so nothing guaranteed the new
  # tmux.conf symlink was in place before this ran -- it could re-source the
  # outgoing generation's config and appear to do nothing.
  #
  # The `tmux info` guard is gone too. It made the reload conditional on a
  # second command's exit status, so any reason that probe failed skipped the
  # reload silently. source-file is harmless with no server running, so just
  # attempt it and swallow the failure.
  config.home.activation.reloadTmux = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    # TERM is `unknown` in the activation environment and there is no
    # controlling tty, so tmux refuses every command with "missing or
    # unsuitable terminal" -- source-file included. It failed silently for as
    # long as this was guarded behind `tmux info`, which failed for the same
    # reason. Forcing a real terminfo entry is what makes the reload land.
    run env TERM=xterm-256color ${pkgs.tmux}/bin/tmux \
      source-file ${config.xdg.configHome}/tmux/tmux.conf 2>/dev/null || true
  '';
}

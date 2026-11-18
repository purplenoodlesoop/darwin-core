{ ... }:
{
  programs.kitty = {
    enable = true;
    themeFile = "Neowave";
    font = {
      name = "FiraCode Nerd Font Mono";
      size = 14;
    };
    settings = {
      bold_font = "auto";
      italic_font = "auto";
      bold_italic_font = "auto";
      cursor_trail = 3;
      cursor_trail_decay = "0.1 0.4";
      # Without this macOS eats Option as a dead key for accents, so Alt-
      # chords never reach the shell or neovim.
      macos_option_as_alt = "yes";
      scrollback_lines = 100000;
      window_padding_width = 4;
      # tmux already shows session/window state; kitty's own tabs duplicate it.
      tab_bar_edge = "bottom";
      enable_audio_bell = "no";
      # OSC-52: let tmux copy-mode (local AND remote-over-ssh) reach the
      # system clipboard through kitty.
      clipboard_control = "write-clipboard write-primary read-clipboard read-primary";
    };
    shellIntegration.enableZshIntegration = true;
  };
}

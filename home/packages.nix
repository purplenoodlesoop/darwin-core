{ pkgs, ... }:
let
  androidHome = "$HOME/Library/Android/sdk";
in
{
  home = {
    packages = with pkgs; [
      raycast
      ffmpeg
      pandoc
      fvm
      nixd
      nixfmt
      xcodes
      aria2
      cocoapods
      nodejs_26
      android-studio
    ];

    sessionPath = [
      "$HOME/.pub-cache/bin"
      "$HOME/fvm/default/bin"
      "$HOME/.local/bin"
      "${androidHome}/platform-tools"
      "${androidHome}/emulator"
    ];
  };
}

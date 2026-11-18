{ pkgs, ... }:
{
  tasks.fmt = {
    description = "Format Nix";
    body = ''
      set -euo pipefail
      cd "$(${pkgs.git}/bin/git rev-parse --show-toplevel)"
      ${pkgs.findutils}/bin/find . -name '*.nix' -not -path './.git/*' -print0 \
        | ${pkgs.findutils}/bin/xargs -0 ${pkgs.nixfmt}/bin/nixfmt
    '';
  };

  flake.output.checks.fmt-check =
    pkgs.runCommand "fmt-check"
      {
        nativeBuildInputs = [
          pkgs.nixfmt
          pkgs.findutils
        ];
      }
      ''
        find ${./..} -name '*.nix' -print0 | xargs -0 nixfmt --check
        touch $out
      '';
}

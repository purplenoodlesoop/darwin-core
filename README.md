# darwin-core

Shared nix-darwin and home-manager modules for macOS workstations: shell,
tmux, kitty, git, ssh-agent, Neovim, Flutter and Android tooling, macOS
defaults, Nix settings, and a weekly job that updates, builds, switches to and
pushes the machine's own flake.

It defines no machine and no person. A machine flake supplies those.

## Use

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    darwin-core = {
      url = "github:purplenoodlesoop/darwin-core";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, darwin-core, ... }:
    let
      hostName = "example-mac";
      user = "alice";
    in
    {
      darwinConfigurations.${hostName} = darwin-core.inputs.nix-darwin.lib.darwinSystem {
        modules = [
          darwin-core.darwinModules.default
          {
            networking = { inherit hostName; };
            system = {
              primaryUser = user;
              configurationRevision = self.rev or self.dirtyRev or null;
              stateVersion = 6;
            };
            ids.gids.nixbld = 350;

            home-manager.users.${user} = {
              home.stateVersion = "26.05";
              programs.git.settings.user = {
                name = "Alice Example";
                email = "alice@example.org";
              };
            };
          }
        ];
      };
    };
}
```

The `darwinConfigurations` attribute must equal `networking.hostName`: the
weekly update builds `.#darwinConfigurations.<hostName>`.

- `system.stateVersion`, `home.stateVersion` and `ids.gids.nixbld` belong to
  the machine: take them from the first `darwin-rebuild` run, which reports
  the values it expects.
- Git signs with `~/.ssh/id_ed25519.pub` by default; override
  `programs.git.signing.key` for another key.
- The update job expects the flake at `~/.config/nix-darwin`; set
  `services.flake-update.repo` otherwise, or `services.flake-update.enable =
  false` to turn it off.
- `darwinCore.tmux.statusRight` adds segments to tmux's status bar.

## Develop

`nix run .#fmt` formats; `nix flake check` checks formatting.

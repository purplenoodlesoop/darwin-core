{
  description = "Shared nix-darwin and home-manager modules for macOS workstations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    core-flake = {
      url = "github:purplenoodlesoop/core-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-config = {
      url = "github:purplenoodlesoop/neovim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    codex-cli-nix = {
      url = "github:sadjow/codex-cli-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      core-flake,
      home-manager,
      neovim-config,
      codex-cli-nix,
      ...
    }:
    with core-flake;
    lib.evalFlake {
      perSystem.imports = [
        nixosModules.tasks
        ./nix/tasks.nix
      ];
      topLevel = {
        darwinModules = rec {
          core = {
            imports = [
              ./darwin
              home-manager.darwinModules.home-manager
            ];
            nix.registry.nixpkgs.flake = nixpkgs;
            home-manager = {
              useGlobalPkgs = true;
              backupFileExtension = "backup";
              sharedModules = [ self.homeModules.default ];
            };
          };
          default = core;
        };

        homeModules = rec {
          core =
            { pkgs, ... }:
            {
              imports = [
                ./home
                neovim-config.homeManagerModules.default
              ];
              home.packages = [ codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.default ];
            };
          default = core;
        };
      };
    };
}

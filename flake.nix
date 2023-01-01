{
  description = "System configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    impermanence.url = "github:nix-community/impermanence";

    emacs-overlay.url = "github:nix-community/emacs-overlay";
    # emacs-overlay.url = "github:ericdallo/emacs-overlay?rev=00cdfbd36d40d529003d521ab32ca570dfcd453e";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    fenix.url = "github:nix-community/fenix";
    fenix.inputs.nixpkgs.follows = "nixpkgs";

    nurl_.url = "github:nix-community/nurl";
    nurl_.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ { self, nixpkgs, home-manager, impermanence, emacs-overlay, darwin, fenix, nurl_, ... }:
    let
      lib = nixpkgs.lib.extend (self: super: { my = import ./lib { inherit inputs; lib = self; }; });

      genPkgs = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      overlays = [
        emacs-overlay.overlay
        fenix.overlays.default
        (final: prev: {nurl = nurl_.packages."${prev.stdenv.hostPlatform.system}".default;})
        # (final: prev: {
        #   nativeClangStdenv =
        #     prev.stdenvAdapters.impureUseNativeOptimizations
        #     (prev.stdenvAdapters.withCFlags [ "-O2" "-pipe" ]
        #       (prev.overrideCC prev.llvmPackages.stdenv
        #         (prev.wrapCCWith rec {
        #           cc = prev.llvmPackages.clang-unwrapped;
        #         })));
        # })
      ];

      genPkgsWithOverlays = system: import nixpkgs {
        inherit system overlays;
        config.allowUnfree = true;
        # config.replaceStdenv = { pkgs }: pkgs.nativeClangStdenv;
      };

      hmConfig = { hm, pkgs, inputs, config, ... }: {
        imports = (lib.my.mapModulesRec' ./hm-imports (x: x)) ++ [ "${impermanence}/home-manager.nix" ];
      };

      darwinSystem = system: extraModules: hostName:
        let pkgs = genPkgsWithOverlays system;
        in
        darwin.lib.darwinSystem {
          inherit system;
          specialArgs = { inherit lib pkgs inputs self darwin; };
          modules = (lib.my.mapModulesRec' (toString ./modules) (m: attrs: import m (attrs // { username = "ben"; }))) ++ [
            ./darwin-common.nix
            home-manager.darwinModules.home-manager
            {
              networking.hostName = hostName;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; username = "ben"; };
              home-manager.users.ben = hmConfig;
            }
          ] ++ extraModules;
        };
    in
    {
      darwinConfigurations."laptop2" = darwinSystem "aarch64-darwin" [ ./hosts/laptop2/default.nix ] "laptop2";
    };
}

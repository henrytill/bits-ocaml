{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    opam-repository = {
      url = "github:ocaml/opam-repository";
      flake = false;
    };
    opam-nix = {
      url = "github:tweag/opam-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.opam-repository.follows = "opam-repository";
    };
    flake-utils = {
      follows = "opam-nix/flake-utils";
    };
  };
  outputs =
    {
      self,
      flake-utils,
      opam-nix,
      nixpkgs,
      ...
    }@inputs:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        on = opam-nix.lib.${system};
        scope = on.buildOpamProject' { resolveArgs.with-test = true; } ./. {
          ocaml-base-compiler = "5.3.0";
        };
        overlay = final: prev: { };
      in
      rec {
        legacyPackages = scope.overrideScope overlay;
        packages.default = packages.all;
        packages.bits = self.legacyPackages.${system}.bits;
        packages.bits-goedel = self.legacyPackages.${system}.bits-goedel;
        packages.all = pkgs.symlinkJoin {
          name = "all";
          paths = with packages; [
            bits
            bits-goedel
          ];
        };
      }
    );
}

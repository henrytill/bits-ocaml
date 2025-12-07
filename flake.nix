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

  nixConfig = {
    extra-substituters = [ "https://henrytill.cachix.org" ];
    extra-trusted-public-keys = [
      "henrytill.cachix.org-1:EOoUIk8e9627viyFmT6mfqghh/xtfnpzEtqT4jnyn1M="
    ];
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
        devPackagesQuery = {
          ocaml-lsp-server = "*";
          ocamlformat = "*";
          # the following are necessary because the default scope is not created using with-test
          mdx = "*";
          sqlite3 = "*";
        };
        query = devPackagesQuery // {
          ocaml-base-compiler = "5.4.0";
        };
        pkgs = nixpkgs.legacyPackages.${system};
        on = opam-nix.lib.${system};
        scope = on.buildOpamProject' { } ./. query;
        overlay = final: prev: { };
        legacyPackages = scope.overrideScope overlay;
        devPackages = builtins.attrValues (
          pkgs.lib.getAttrs (builtins.attrNames devPackagesQuery) legacyPackages
        );
        bitsShell = pkgs.mkShell {
          inputsFrom = with legacyPackages; [
            bits
            bits-goedel
          ];
          packages = devPackages ++ (with pkgs; [ aflplusplus ]);
        };
      in
      rec {
        inherit legacyPackages;
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
        devShells.default = bitsShell;
      }
    );
}

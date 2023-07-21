{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, flake-utils, nixpkgs }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlay = final: prev: {
          ocamlPackages = prev.ocamlPackages.overrideScope' (ofinal: oprev: {
            top-k = ofinal.buildDunePackage rec {
              pname = "top-k";
              version = "0.1";
              duneVersion = "3";
              propagatedBuildInputs = [ ofinal.bheap ];
              checkInputs = [ ofinal.ppx_expect ];
              src = ./.;
            };
          });
        };

        pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlay ];
        };
      in {
        packages = {
          top-k = pkgs.ocamlPackages.top-k;
          default = self.packages.${system}.top-k;
        };
        overlays.default = overlay;
        devShell = pkgs.mkShell {
          nativeBuildInputs = [
            pkgs.ocamlformat
            pkgs.opam
            pkgs.ocamlPackages.ocaml-lsp
            pkgs.ocamlPackages.odoc
            pkgs.ocamlPackages.ppx_expect
          ];
          inputsFrom = [ self.packages.${system}.default ];
        };
      });
}

{ nixpkgs ? import <nixpkgs> {}, compiler ? "ghc928" }:
  let
    inherit (nixpkgs) pkgs;
    ghc = pkgs.haskell.packages.${compiler}.ghcWithPackages (ps: with ps; [
            stack
            haskell-language-server
            fast-tags
            hoogle
          ]);
  in
  pkgs.mkShell {
    buildInputs = [
      ghc
    ];
  }

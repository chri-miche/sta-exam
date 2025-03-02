let
    pkgs = import (builtins.fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/21808d22b1cda1898b71cf1a1beb524a97add2c4.tar.gz";
    }) {};

    myPkg = pkgs.typst;
in
  pkgs.mkShell {
    nativeBuildInputs = with pkgs.buildPackages; [ 
      typst
    ];
  }

# created according to
# https://wiki.nixos.org/wiki/Python
let
  pkgs = import <nixpkgs> {};

  python = pkgs.python3.override {
    self = python;
    packageOverrides = pyfinal: pyprev: {
      toolz = pyfinal.callPackage ./toolz.nix { };
    };
  };
in pkgs.mkShell {
  packages = [
    (pkgs.python3.withPackages (python-pkgs: with python-pkgs; [
      # select Python packages here
      python-pkgs.bibtexparser
      python-pkgs.pandas
      python-pkgs.pyaml #called pyyaml in pip
      python-pkgs.titlecase
    ]))
  ];
}

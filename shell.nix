# created according to
# https://wiki.nixos.org/wiki/Python
let
  pkgs = import <nixpkgs> {};
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

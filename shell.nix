# created according to
# https://wiki.nixos.org/wiki/Python
let
  pkgs = import <nixpkgs> {};
in pkgs.mkShell {
  packages = [
    # We need LaTeX, Java, and Python...
    pkgs.texliveFull
    pkgs.jdk
    (pkgs.python3.withPackages (python-pkgs: [
      # ... and these python packages:
      python-pkgs.bibtexparser
      python-pkgs.pandas
      python-pkgs.pyaml #called pyyaml in pip
      python-pkgs.titlecase
    ]))
  ];
}

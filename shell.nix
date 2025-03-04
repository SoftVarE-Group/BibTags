# created according to
# https://wiki.nixos.org/wiki/Python
let
  pkgs = import <nixpkgs> {};
in pkgs.mkShell {
  packages = [
    pkgs.jdk # We need Java...
    # ... and python ...
    (pkgs.python3.withPackages (python-pkgs: [
      # ... with these packages:
      python-pkgs.bibtexparser
      python-pkgs.pandas
      python-pkgs.pyaml #called pyyaml in pip
      python-pkgs.titlecase
    ]))
  ];
}

{
  description = "Casual Pre-loader development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        python = pkgs.python3.override {
          self = python;
          packageOverrides = pyfinal: pyprev: {
            # not packaged in nixpkgs
            type-lens = pyfinal.buildPythonPackage rec {
              pname = "type_lens";
              version = "0.2.6";
              format = "wheel";
              src = pyfinal.fetchPypi {
                inherit pname version format;
                dist = "py3";
                python = "py3";
                hash = "sha256-qt5r6z7KM3yQ0bYntQl2hHO71ZHiM+1rV/uT7CoBvKY=";
              };
              dependencies = [ pyfinal.typing-extensions ];
            };

            cappa = pyfinal.buildPythonPackage rec {
              pname = "cappa";
              version = "0.33.0";
              format = "wheel";
              src = pyfinal.fetchPypi {
                inherit pname version format;
                dist = "py3";
                python = "py3";
                hash = "sha256-/cKtCogMwrSV2WlOzlJK3UruCbD219k8T3Hdgspq41Q=";
              };
              dependencies = with pyfinal; [
                rich
                type-lens
                typing-extensions
              ];
            };

            valve-parsers = pyfinal.buildPythonPackage rec {
              pname = "valve_parsers";
              version = "1.2.2";
              format = "wheel";
              src = pyfinal.fetchPypi {
                inherit pname version format;
                dist = "py3";
                python = "py3";
                hash = "sha256-omWEitZaAEc26PQzP5ZwiA8PBz/pmxsgvva4rFsdz3A=";
              };
            };
          };
        };

        pythonEnv = python.withPackages (
          ps: with ps; [
            # GUI
            pyqt6

            # core
            cappa
            more-itertools
            packaging
            pillow
            platformdirs
            pygithub
            rich
            valve-parsers

            # tests
            pytest
            pytest-cov
          ]
        );
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            pythonEnv
            pkgs.wine # runs studiomdl.exe for model precaching
            pkgs.mkdocs
            pkgs.python3Packages.mkdocs-material
          ];

          # let PyQt6 find its platform plugins
          QT_PLUGIN_PATH = "${pkgs.qt6.qtbase}/${pkgs.qt6.qtbase.qtPluginPrefix}:${pkgs.qt6.qtwayland}/${pkgs.qt6.qtbase.qtPluginPrefix}";
        };
      }
    );
}

{
  description = "Infrastructure layer of PythonEDA Git Repositories";

  inputs = rec {
    nixos.url = "github:NixOS/nixpkgs/nixos-22.11";
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
    poetry2nix = {
      url = "github:nix-community/poetry2nix/v1.28.0";
      inputs.nixpkgs.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
    };
    pythoneda-git-repositories = {
      url = "github:rydnr/pythoneda-git-repositories/0.0.1a1";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.poetry2nix.follows = "poetry2nix";
    };
  };
  outputs = inputs:
    with inputs;
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixos { inherit system; };
        python = pkgs.python3;
        pythonPackages = python.pkgs;
        description = "Infrastructure layer of PythonEDA Git Repositories";
        license = pkgs.lib.licenses.gpl3;
        maintainers = with pkgs.lib.maintainers; [ ];
      in rec {
        packages = {
          pythoneda-git-repositories-infrastructure =
            pythonPackages.buildPythonPackage rec {
              pname = "pythoneda-git-repositories-infrastructure";
              version = "0.0.1a1";
              src = ./.;
              format = "pyproject";

              nativeBuildInputs = [ pkgs.poetry ];

              propagatedBuildInputs = with pythonPackages;
                [
                  pythoneda-git-repositories.packages.${system}.pythoneda-git-repositories
                ];

              checkInputs = with pythonPackages; [
                pytest
                pythoneda-git-repositories.packages.${system}.pythoneda-git-repositories
              ];

              pythonImportsCheck = [ ];

              meta = with pkgs.lib; {
                inherit description license homepage maintainers;
              };
            };
          default = packages.pythoneda-git-repositories-infrastructure;
          meta = with lib; {
            inherit description license homepage maintainers;
          };
        };
        defaultPackage = packages.default;
        devShell = pkgs.mkShell {
          buildInputs = with pkgs.python3Packages; [ packages.default ];
        };
        shell = flake-utils.lib.mkShell {
          packages = system: [ self.packages.${system}.default ];
        };
      });
}

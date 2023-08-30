{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let systems = [ "x86_64-linux" ];
    in flake-utils.lib.eachSystem systems (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages = rec {
          vpm = pkgs.buildDotnetGlobalTool {
            pname = "vpm";
            nugetName = "vrchat.vpm.cli";
            version = "0.1.17";
            nugetSha256 = "sha256-14LNQxZ3yMwTzahXaftHidSVr+isjL7qExnhFffGSa8=";
          };
          default = vpm;
        };
        formatter = pkgs.nixfmt;
      });
}

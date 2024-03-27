{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let systems = [ "x86_64-linux" ];
    in flake-utils.lib.eachSystem systems (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        };
      in {
        packages = {
          inherit (pkgs) vpm;
          default = pkgs.vpm;
        };
        formatter = pkgs.nixfmt;
      }) // {
        overlays.default = final: prev: {
          vpm = final.buildDotnetGlobalTool {
            pname = "vpm";
            nugetName = "vrchat.vpm.cli";
            version = "0.1.24";
            nugetSha256 = "sha256-2kulYzOtyrid3NFXwNivK3V0KcF7MvXGRMhpXN+Mab4=";
          };
        };
      };
}

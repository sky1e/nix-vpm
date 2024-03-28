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
          vpm = final.buildDotnetGlobalTool rec {
            pname = "vpm";
            nugetName = "vrchat.vpm.cli";
            version = "0.1.24";
            nugetSha256 = "sha256-2kulYzOtyrid3NFXwNivK3V0KcF7MvXGRMhpXN+Mab4=";

            passthru.update = final.writeShellScriptBin "update-vpm" ''
              set -eufo pipefail

              IFS=" " read -r -a latest <<< "$(${final.dotnetPackages.Nuget}/bin/nuget list ${nugetName})"
              latest_version=''${latest[1]}

              sha256="$(${final.nix}/bin/nix-prefetch-url "http://www.nuget.org/api/v2/package/${nugetName}/$latest_version" 2>/dev/null)"

              hash="$(${final.nix}/bin/nix-hash --to-sri --type sha256 "$sha256")"

              drift rewrite --current-hash="${nugetSha256}" --new-hash="$hash" --new-version "$latest_version" --file "flake.nix"
            '';
          };
        };
      };
}

{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
    zig.url = "github:mitchellh/zig-overlay";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      zig,
      ...
    }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        zigPkgs = zig.packages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            zigPkgs.master
          ];
        };
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "zig-playground";
          version = "dev";

          src = ./.;

          buildInputs = [ zigPkgs.master ];
          buildPhase = ''
            export ZIG_GLOBAL_CACHE_DIR=$TMPDIR/zig-cache
            zig build
          '';
          installPhase = ''
            mkdir -p $out/bin
            cp ./zig-out/bin/zig-playground $out/bin/
          '';
        };

        packages.docker = pkgs.dockerTools.buildLayeredImage {
          name = "zig-playground";
          tag = "latest";
          contents = [ self.packages.${system}.default ];
          config = {
            Cmd = [ "/bin/zig-playground" ];
          };
        };
      }
    );
}

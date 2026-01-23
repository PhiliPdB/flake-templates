{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    { flake-parts, nixpkgs, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;

      perSystem =
        { pkgs, ... }:
        {
          devShells.default = pkgs.mkShell rec {
            name = "Dotnet shell";
            dotnetPkg = (
              with pkgs.dotnetCorePackages;
              combinePackages [
                # TODO: Always check if this is the latest .NET
                sdk_10_0
              ]
            );

            dependencies = with pkgs; [
              zlib
              zlib.dev
              icu
              openssl

              dotnetPkg
            ];

            NIX_LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (
              [
                pkgs.stdenv.cc.cc
              ]
              ++ dependencies
            );
            NIX_LD = "${pkgs.stdenv.cc.libc_bin}/bin/ld.so";

            nativeBuildInputs = dependencies;

            DOTNET_ROOT = "${dotnetPkg}/share/dotnet";

            packages = with pkgs; [ roslyn-ls ];
          };
        };
    };
}

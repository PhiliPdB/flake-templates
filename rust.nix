{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      flake-parts,
      nixpkgs,
      rust-overlay,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;

      perSystem =
        { system, pkgs, ... }:
        {
          _module.args.pkgs = import nixpkgs {
            inherit system;
            overlays = [ (import rust-overlay) ];
          };

          devShells.default = pkgs.mkShell {
            name = "Rust shell";

            buildInputs = with pkgs; [
              # Required Rust packages
              (rust-bin.stable.latest.default.override {
                extensions = [
                  "clippy"
                  "rust-analyzer"
                  "rust-src"
                ];
              })
              libclang.lib
            ];

            # Needed if using bindgen to wrap C libraries in Rust
            LIBCLANG_PATH = "${pkgs.libclang.lib}/lib";
            # Uncomment and add libs if requires dlopen libraries
            # LD_LIBRARY_PATH = with pkgs; lib.makeLibraryPath [ ];

            packages = with pkgs; [
              cargo-expand
              cargo-show-asm
            ];
          };
        };
    };
}

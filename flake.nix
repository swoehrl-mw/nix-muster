{
  outputs = { self, nixpkgs }:
    let
      # System types to support.
      supportedSystems =
        [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

    in {

      # Provide some binary packages for selected system types.
      packages = forAllSystems (system:
        let 
          pkgs = nixpkgsFor.${system};
          pkg_version = "5.63.2";
          # Map nix system names to download names for muster releases
          name_mapping = {
            "x86_64-linux" = "linux-amd64";
            "aarch64-linux" = "linux-arm64";
            "x86_64-darwin" = "darwin-amd64";
            "aarch64-darwin" = "darwin-arm64";
          };
          # Hashes for the different architectures, calculated using ./calc_hashes.sh
          source_hashes = {
            "linux-amd64" = "FLh5w7OiTPq0vsh5r2atdcszY4rjKf/fojZaTObmWoQ=";
            "linux-arm64" = "6J8RV9CXHSBqMh4Kdw//2QLnF+ASqlpk3J9baO5Ecmc=";
            "darwin-amd64" = "67Ep+4UGzpF9gcCefoq0OJMOu8TJNdRSugCSQ0TnpW0=";
            "darwin-arm64" = "0ISw6+thmt0FhC02ZBej3y7XynVSp2QkIy9oafDz1L4=";
          };
        in rec {
          muster = pkgs.stdenv.mkDerivation rec {
            pname = "muster";
            version = "${pkg_version}";
            src = pkgs.fetchurl {
              url =
                "https://github.com/giantswarm/muster/releases/download/v${pkg_version}/muster-${name_mapping.${system}}";
              sha256 = "${source_hashes.${name_mapping.${system}}}";
            };
            dontUnpack = true;
            dontConfigure = true;
            dontBuild = true;
            installPhase = ''
              mkdir -p "$out/bin"
              install -m755 "$src" "$out/bin/muster"
            '';
          };
          default = muster;
        });
    };
}

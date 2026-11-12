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
          pkg_version = "5.62.8";
          # Map nix system names to download names for muster releases
          name_mapping = {
            "x86_64-linux" = "linux-amd64";
            "aarch64-linux" = "linux-arm64";
            "x86_64-darwin" = "darwin-amd64";
            "aarch64-darwin" = "darwin-arm64";
          };
          # Hashes for the different architectures, calculated using ./calc_hashes.sh
          source_hashes = {
            "linux-amd64" = "ua2hDAHbb7MGZ0KRZjHntGEuooaSJNP0d95fWzPKT78=";
            "linux-arm64" = "tFFpNHdhynCdDq4eLJjnMUyhMH7oLZXAlO9v3JLeC1s=";
            "darwin-amd64" = "9s2/U4woAHO75W7Zhevj/2wZuknw17UDcFCgNwiNxxI=";
            "darwin-arm64" = "4O+9mCebb4yZOtA2zor7TvOuOTMAFgen8SF/MzQptO8=";
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

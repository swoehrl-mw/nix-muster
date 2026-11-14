# Nix Flake for muster

This repository contains a very basic [Nix Flake](https://nixos.wiki/wiki/Flakes) providing the [Giantswarm Muster MCP Aggregator](https://github.com/giantswarm/muster) as a package. It is intended to be added to dev shells to use the `muster agent` cli.

## Usage

To reference this flake use the following format: `github:swoehrl-mw/nix-muster/v<version>`. If you just want the latest version and don't care about version pinning, remove the `/v<version>` part.

Example: `github:swoehrl-mw/nix-muster/v5.63.7`

To use the package with [devbox](https://www.jetify.com/devbox/docs/), simply add the reference to your `devbox.json` `packages`:

```json
{
    "packages": [
        "github:swoehrl-mw/nix-muster/v5.63.7"
    ]
}
```

To add the package to a classic [nix-shell](https://nix.dev/tutorials/first-steps/declarative-shell), use the following snippet in your `shell.nix`:

```nix
pkgs.mkShellNoCC {
  packages = [
    (builtins.getFlake "github:swoehrl-mw/nix-muster/v5.63.7").packages.${builtins.currentSystem}.muster
  ];
}
```

## Development

Steps to update the Flake to a new version:

1. Run `update_flake.py` with the new version as argument:

   ```sh
   python ./update_flake.py x.x.x
   nix build --no-link # To verify the flake builds
   ```

2. Commit and push the changes
3. Tag the commit with the new version

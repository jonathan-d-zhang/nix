# Nix Config

## Secrets

Secrets live encrypted in `secrets/secrets.yaml` (sops + age) and are decrypted at
activation into `/run/secrets`. Nothing secret is ever in a `.nix` file — the Nix
store is world-readable.

The age key at `~/.config/sops/age/keys.txt` must exist **before the first
`nixos-rebuild switch`**, or activation fails with a decryption error.

On a new machine, copy the key over from an existing one:

```shell
mkdir -p ~/.config/sops/age
scp othermachine:~/.config/sops/age/keys.txt ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
```

### Editing secrets

```shell
sops secrets/secrets.yaml          # decrypts to $EDITOR, re-encrypts on save
sops -d secrets/secrets.yaml       # just look
```

To add a secret without it ever hitting the terminal or shell history:

```shell
sops set secrets/secrets.yaml '["name"]' "$(jq -Rs . < /path/to/file)"
```

Then declare it in `modules/common.nix` so activation installs it:

```nix
sops.secrets.name = { owner = "jz9"; mode = "0400"; };
```

Consume it by **path** (`config.sops.secrets.name.path`), never by value. Multi-line
values like private keys go in as YAML block scalars (`name: |`).


## To bootstrap on WSL:

Assumes NixOS installed into WSL via https://nix-community.github.io/NixOS-WSL/.

```shell
sudo nix-shell -p git --run "git clone https://github.com/jonathan-d-zhang/nix.git /etc/nixos-flake"
cd /etc/nixos-flake
sudo nixos-rebuild switch --flake .#wsl
```


## To bootstrap on a NixOS VM.

Assumes disk is formatted and partitioned.

```shell
sudo nix-shell -p git --run "git clone https://github.com/jonathan-d-zhang/nix.git /mnt/root/nix"
nixos-generate-config --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix /mnt/root/nix/hosts/vm/hardware-configuraiton.nix

nixos-install --flake /mnt/root/nix#vm --root /mnt
```

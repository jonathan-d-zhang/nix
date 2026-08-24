# Nix Config

## To bootstrap on WSL:

Assumes NixOS installed into WSL via https://nix-community.github.io/NixOS-WSL/.

```shell
sudo nix-shell -p git --run "git clone https://github.com/jonathan-d-zhang/nix.git /etc/nixos-flake
cd /etc/nixos-flake
sudo nixos-rebuild switch --flake .#wsl
```


## To bootstrap on a NixOS VM.

Assumes disk is formatted and partitioned.

```shell
sudo nix-shell -p git --run "git clone https://github.com/jonathan-d-zhang/nix.git /mnt/root/nix
nixos-generate-config --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix /mnt/root/nix/hosts/vm/hardware-configuraiton.nix

nixos-install --flake /mnt/root/nix#vm --root /mnt
```

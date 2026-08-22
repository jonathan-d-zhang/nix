# Generic target for a fresh NixOS VM (QEMU/VirtualBox/UTM/Proxmox/...).
#
# Before first `nixos-rebuild switch`, replace hardware-configuration.nix in
# this directory with the one `nixos-generate-config` produces on the actual
# VM (disk device names, filesystems and boot mode vary per hypervisor).
{ lib, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos-vm";
  networking.networkmanager.enable = true;

  services.openssh.enable = true;

  system.stateVersion = "24.11";
}

# PLACEHOLDER — replace this whole file with the output of
# `nixos-generate-config --root /mnt` run on the target VM before deploying.
# This one assumes a typical single-disk UEFI QEMU/virtio VM just so the
# flake evaluates; it will not match your real VM's disk/UUIDs.
{ lib, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" ];
  boot.kernelModules = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  swapDevices = [ ];
  nixpkgs.hostPlatform = "x86_64-linux";
}

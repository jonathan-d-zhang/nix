{ lib, pkgs, ... }:

{
  wsl = {
    enable = true;
    defaultUser = "jz9";
    startMenuLaunchers = true;
    # Reuse the Windows-side PATH/interop like the current Ubuntu distro does.
    interop.includePath = true;
  };

  networking.hostName = "nixos-wsl";
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
}

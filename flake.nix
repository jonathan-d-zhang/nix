{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixos-wsl, home-manager, ... }: {
    nixosConfigurations = {
      # Installed side-by-side with the existing Ubuntu WSL distro:
      #   wsl --install --from-file result/nixos.wsl   (or: nix build .#nixosConfigurations.wsl.config.system.build.tarballBuilder, see NixOS-WSL docs)
      wsl = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-wsl.nixosModules.default
          home-manager.nixosModules.home-manager
          ./modules/common.nix
          ./modules/home.nix
          ./hosts/wsl
        ];
      };

      # For a fresh NixOS VM (QEMU/VirtualBox/UTM/etc). Before first switch, replace
      # hosts/vm/hardware-configuration.nix with the one `nixos-generate-config`
      # produces on that actual VM.
      vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./modules/common.nix
          ./modules/home.nix
          ./hosts/vm
        ];
      };
    };
  };
}

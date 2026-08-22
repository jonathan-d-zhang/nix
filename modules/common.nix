{ lib, config, pkgs, ... }:

let
  berkeleyMonoNerdFont = pkgs.stdenvNoCC.mkDerivation {
    pname = "berkeley-mono-nerd-font";
    version = "1";
    src = ./dotfiles/fonts/BerkeleyMonoNerdFont.zip;
    nativeBuildInputs = [ pkgs.unzip ];
    unpackPhase = "unzip $src -d .";
    installPhase = ''
      mkdir -p $out/share/fonts/opentype
      cp BerkeleyMonoNerdFont/*.otf $out/share/fonts/opentype/
    '';
  };
in
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "claude-code"
  ];

  fonts.packages = [ berkeleyMonoNerdFont ];
  fonts.fontconfig.enable = true;

  services.tailscale.enable = true;

  time.timeZone = "America/New_York";

  users.users.jz9 = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.powershell;
  };

  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    # core cli
    git gh curl wget jq ripgrep fzf bat eza tree unzip xz p7zip
    plocate whois sshfs fortune cowsay lolcat hyperfine cloc
    fastfetch universal-ctags parallel pciutils nettools smartmontools
    valgrind mold graphviz pandoc sops age cosign tailscale starship
    kdePackages.kcachegrind

    # build toolchain
    gcc clang gfortran cmake automake bison flex gperf nasm yasm
    pkg-config binutils swig gnumake

    # editor / terminal
    neovim powerline powershell

    # language runtimes
    luajit
    graalvmPackages.graalvm-ce
    uv
    nodejs

    ## rust
    cargo
    rustc
    rustup
    rust-analyzer

    # k8s / containers
    docker k9s minikube kubernetes-helm

    # tex: minimal + lualatex. tlmgr is bundled with any texlive.combine output.
    (texlive.combine { inherit (texlive) scheme-basic collection-luatex; })
  ];
}

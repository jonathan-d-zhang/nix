{ config, pkgs, ... }:

{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.jz9 = { pkgs, ... }:
  let
    # Mirrors ~/.claude/plugins/known_marketplaces.json + installed_plugins.json.
    claudePluginsOfficial = pkgs.fetchFromGitHub {
      owner = "anthropics";
      repo = "claude-plugins-official";
      rev = "340e33aef211d95769d252324854497af871dafe"; # main as of 2026-08-22
      hash = "sha256-bGdXvzhWPwGdz3T2Yh2h6lf+3PBRFAfdBxP5pESmCHI=";
    };
    ponytailPlugin = pkgs.fetchFromGitHub {
      owner = "DietrichGebert";
      repo = "ponytail";
      rev = "2ed6c52c9d7e5e56942508591085fd45dea277d3"; # pinned to the commit currently installed
      hash = pkgs.lib.fakeHash;
    };
  in {
    home.stateVersion = "24.11";

    programs.claude-code = {
      enable = true;
      marketplaces.ponytail = ponytailPlugin;
      plugins = {
        pyright-lsp = "${claudePluginsOfficial}/plugins/pyright-lsp";
        rust-analyzer-lsp = "${claudePluginsOfficial}/plugins/rust-analyzer-lsp";
        ponytail = ponytailPlugin;
      };
    };

    programs.git = {
      enable = true;
      signing = {
        key = "CD3D82C9CC12BAF6";
        signByDefault = true;
      };
      settings = {
        user.name = "jonathan-d-zhang";
        user.email = "69145546+jonathan-d-zhang@users.noreply.github.com";
        push.followTags = true;
        safe.directory = "*";
        core.editor = "vim";
        credential."https://github.com".helper = [ "" "!${pkgs.gh}/bin/gh auth git-credential" ];
        credential."https://gist.github.com".helper = [ "" "!${pkgs.gh}/bin/gh auth git-credential" ];
      };
    };

    programs.starship.enable = true;

    programs.jujutsu = {
      enable = true;
      settings = builtins.fromTOML (builtins.readFile ./dotfiles/jj/config.toml);
    };

    programs.tmux = {
      enable = true;
      keyMode = "vi";
      terminal = "tmux-256color";
      mouse = true;
      escapeTime = 0;
      plugins = with pkgs.tmuxPlugins; [ resurrect continuum ];
      extraConfig = ''
        bind r source-file ~/.tmux.conf

        bind | split-window -h -c "#{pane_current_path}"
        bind - split-window -v -c "#{pane_current_path}"
        unbind '"'
        unbind %

        bind -r Left resize-pane -L 5
        bind -r Down resize-pane -D 5
        bind -r Up resize-pane -U 5
        bind -r Right resize-pane -R 5

        bind -n M-h select-pane -L
        bind -n M-j select-pane -D
        bind -n M-k select-pane -U
        bind -n M-l select-pane -R

        set -g pane-active-border-style bg='#222222',fg='#21ffff'
        set -g pane-border-style bg='#222222',fg=white

        set -g window-style bg="#222222"
        set -g window-active-style bg="#222222"

        set -g pane-border-lines "simple"
        set -g pane-border-format ""
        set -g pane-border-status bottom

        set-option -g allow-rename off
        set-option -ga terminal-overrides ",xterm-256color:Tc"

        source "${pkgs.powerline}/share/powerline/bindings/tmux/powerline.conf"

        set -g @continuum-restore 'on'
        set -g @continuum-save-interval '1'
      '';
    };

    home.file = {
      ".config/nvim/init.vim".source = ./dotfiles/nvim/init.vim;
      ".config/nvim/plugin/lspconfig.lua".source = ./dotfiles/nvim/plugin/lspconfig.lua;
      ".config/nvim/plugin/monokai.lua".source = ./dotfiles/nvim/plugin/monokai.lua;

      ".config/powershell/Microsoft.PowerShell_profile.ps1".source = ./dotfiles/powershell/profile.ps1;
      ".local/share/powershell/Modules/jz9.Utils/jz9.Utils.psm1".source = ./dotfiles/powershell/jz9.Utils.psm1;
    };
  };
}

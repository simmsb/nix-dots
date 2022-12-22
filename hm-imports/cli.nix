{ inputs, config, lib, pkgs, ... }:
{
  home.stateVersion = "23.05";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    cachix
    nixpkgs-fmt
    update-nix-fetchgit
    just
    assh
    fish
    jq
    htop
    exa
    curl
    fd
    file
    fzf
    git
    neofetch
    ripgrep
    direnv
    unzip
    pv
    killall
    yt-dlp
    aria2
    libqalculate
    rsync
    perl
    netcat
    openssh
  ];
  programs = {
    gpg = {
      enable = true;
    };
    fish = {
      enable = true;
    };
    git = {
      enable = true;
      lfs.enable = true;

      # Default configs
      extraConfig = {
        commit.gpgSign = true;

        user.name = "Ben Simms";
        user.email = "ben@bensimms.moe";
        user.signingKey = "3C3A2E1E088D295B";

        color.ui = true;
        core = {
          editor = "nvim";
          autocrlf = "input";
          excludesfile = "~/.gitignore";
        };

        alias = {
          lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'";
          pushall = "!git remote | xargs -L1 git push --all";
          prunemerged = "git branch --merged | egrep -v \"(^\\*|master|dev)\" | xargs git branch -d";
        };

        pull = {
          rebase = true;
          twohead = "ort";
        };

        rebase.autostash = "true";
      };
    };
    # Htop configurations
    htop = {
      enable = true;
      settings = {
        hide_userland_threads = true;
        highlight_base_name = true;
        shadow_other_users = true;
        show_program_path = false;
        tree_view = false;
      };
    };


  };
}



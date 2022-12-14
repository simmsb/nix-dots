{ pkgs, ... }:
let
  my-emacs = (pkgs.emacsPackagesFor pkgs.emacsGit).withPackages
    (epkgs: [ epkgs.emacsql-sqlite epkgs.vterm epkgs.pdf-tools ]);
  python = pkgs.python3.withPackages (ppkgs: with ppkgs; [ pipx pip virtualenv numpy scipy ]);
in
{
  environment.systemPackages = with pkgs; [
    nix-index

    neovim
    tailscale
    my-emacs
    libgccjit
    llvmPackages_latest.llvm
    llvmPackages_latest.lld
    llvmPackages_latest.bintools

    coreutils
    findutils
    gnugrep
    gnused

    zlib.out
    qemu
    python

    gradle

    mold

    gnuradio
    hackrf
    p7zip
    ffmpeg
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ "root" "ben" ];

  services.tailscale.enable = true;

  # this fish enable is needed to get nix-darwin's config stuff
  programs.fish.enable = true;
  users.users.ben.shell = pkgs.fish;
  environment.shells = with pkgs; [ bashInteractive fish ];
  environment.loginShell = pkgs.fish;

  users.users.ben = {
    name = "ben";
    home = "/Users/ben";
  };

  fonts.fontDir.enable = true;
  fonts.fonts = [
    (pkgs.nerdfonts.override {
      fonts = [ "FiraCode" "FantasqueSansMono" ];
    })
  ];

  homebrew = {
    enable = true;

    global = {
      autoUpdate = false;
      brewfile = true;
    };
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };

    brews = [ 
      "urh"
      "inspectrum"
    ];

    caskArgs.no_quarantine = true;

    casks = [
      "discord"
      "stats"
      "maccy"
      "alt-tab"
      "gqrx"
      "zulu17" # java
      "prismlauncher"
      "raycast"
      "shottr"
      "iina"
      "reflex"
      "spotify"
      "hiddenbar"
      "steam"
      "rectangle"
      "ghidra"
      "remoteviewer"
      "sigdigger"
      "obs"
      "karabiner-elements"
    ];

    taps = [
      "homebrew/cask"
      "homebrew/cask-versions"
    ];
  };

  home-manager.users.ben = { pkgs, lib, inputs, config, ... }: {
    home.username = "ben";
    astronvim.enable = true;

    disabledModules = [ "targets/darwin/linkapps.nix" ];

    home.packages = with pkgs; [
      cargo-outdated
      cargo-edit
      cargo-expand
      cargo-generate
      cargo-espflash
      cargo-show-asm

      nmap
      du-dust

      rustup
      rust-analyzer-nightly

      poetry

      tokei

      binwalk
      
      # nix language server
      nil

      # nix url fetcher
      nurl

      kubectl
    ];

    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      withPython3 = true;
      extraPackages = with pkgs; [ tree-sitter nodejs ripgrep fd unzip ];
    };

    programs.fish = {
      enable = true;

      functions = {
        assh_ts = ''
          begin
                echo 'hosts:'
                tailscale status --json | jq -r '.Peer[] | ("  " + (.DNSName | split("."))[0] + ":\n    hostname: " + .TailscaleIPs[0] + "\n    user: root\n")'
          end > ~/.ssh/assh-ts.yml
          assh config build > ~/.ssh/config
          echo "done!"
        '';
      };

      shellInit = ''
        set -gx ATUIN_NOBIND "true"
        if test (uname) = Darwin
          fish_add_path --prepend --global "$HOME/.cargo/bin" "$HOME/.nix-profile/bin" "/etc/profiles/per-user/$USER/bin" /nix/var/nix/profiles/default/bin /run/current-system/sw/bin
        end
        fish_add_path --global "$HOME/.local/bin" 
      '';

      interactiveShellInit = ''
        fzf_configure_bindings --directory=\cf --history=

        function start_zellij
          if set -q ZELLIJ
          else
            zellij a -c
          end
        end

        if test "$TERM" != "dumb" -a \( -z "$INSIDE_EMACS" -o "$INSIDE_EMACS" = vterm \)
          start_zellij
        end

        bind \cr _atuin_search
      '';

      plugins = [
        {
          name = "catppuccin";
          src = pkgs.fetchFromGitHub {
            owner = "catppuccin";
            repo = "fish";
            rev = "8d0b07ad927f976708a1f875eb9aacaf67876137";
            sha256 = "0f9y36d3hjmizjwgsjl03njvrdv8j8c3qka31fiyss73252hm4pw";
          };
        }

        {
          name = "fzf";
          src = pkgs.fetchFromGitHub {
            owner = "PatrickF1";
            repo = "fzf.fish";
            rev = "3666395bc10752c7afd21210fe5c3458d0f502bf";
            sha256 = "1yzsv3w02qbxgw7046dq7k68pms1zqsmaqq314p4rlmp3hsqwz07";
          };
        }

        {
          name = "pisces";
          src = pkgs.fetchFromGitHub {
            owner = "laughedelic";
            repo = "pisces";
            rev = "e45e0869855d089ba1e628b6248434b2dfa709c4";
            sha256 = "073wb83qcn0hfkywjcly64k6pf0d7z5nxxwls5sa80jdwchvd2rs";
          };
        }

      ];
    };

    programs.alacritty = {
      enable = true;
      settings = {
        window = {
          padding = { x = 10; y = 10; };
          decorations = "buttonless";
        };
        font = {
          normal.family = "FantasqueSansMono Nerd Font";
          size = 15;
        };
        shell = {
          program = "${pkgs.fish}/bin/fish";
          args = [ "--login" ];
        };
        key_bindings = [
          {
            key = "Key3";
            mods = "Alt";
            chars = "#";
          }
        ];
      };
    };

    programs.starship = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        character = {
          success_symbol = "[??](bold green)";
          error_symbol = "[??](bold red)";
        };

        git_status = {
          style = "bold blue";
        };
      };
    };

    programs.zellij = {
      enable = true;
      settings = {
        default_shell = "${pkgs.fish}/bin/fish";
      };
    };

    programs.zoxide = {
      enable = true;
      enableFishIntegration = true;
    };

    programs.exa = {
      enable = true;
      enableAliases = true;
    };

    programs.atuin = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        dialect = "uk";
        auto_sync = true;
        sync_frequency = "5m";
        sync_address = "http://100.82.95.116:8888";
        search_mode = "fulltext";
      };
    };

    programs.password-store = {
      enable = true;
    };
  };
}

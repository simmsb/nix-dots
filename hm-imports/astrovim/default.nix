{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.astronvim;
  astronvim = pkgs.fetchFromGitHub {
    owner = "AstroNvim";
    repo = "AstroNvim";
    rev = "176265812355a53559497c0f0ada7ab62a2d1ba8";
    sha256 = "03346sh8ddhmp16d2zdjvm0h7w2ffsmbh9d7m9ysimqs5l4348ds";
  };
in {
  options.astronvim = {
    enable = mkOption {
      default = false;
      description = "Enable AstronVim";
      type = types.bool;
    };

    userConfig = mkOption {
      default = null;
      description = "AstronVim User Config";
      type = with types; nullOr path;
    };
  };
  config = mkIf (cfg.enable) {
    home = {
      file = {
        ".config/nvim" = {
          recursive = true;
          source = astronvim;
        };
        ".config/nvim/lua/user" = mkIf (cfg.userConfig != null) {
          recursive = true;
          source = cfg.userConfig;
        };
      };
    };
  };
}


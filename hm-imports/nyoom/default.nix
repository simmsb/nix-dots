{ config
, pkgs
, lib
, ...
}:
with lib; let
  cfg = config.nyoom;
  nyoom = pkgs.fetchFromGitHub {
    owner = "nyoom-engineering";
    repo = "nyoom.nvim";
    rev = "6062aefdcbda1754a772622f866c2e3ff6f4d580";
    sha256 = "1s2kv9qgh3v8cr2zylcy1gl33q1yxsvrhigkihaj3hp33gafqvi7";
  };
in
{
  options.nyoom = {
    enable = mkOption {
      default = false;
      description = "Enable Nyoom";
      type = types.bool;
    };

  };
  config = mkIf (cfg.enable) {
    home = {
      file = {
        ".config/nvim" = {
          recursive = true;
          source = nyoom;
        };
      };
    };
  };
}



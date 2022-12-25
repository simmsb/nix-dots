{ config
, lib
, pkgs
, ...
}:
{
  system.activationScripts.applications.text = lib.mkForce ''
    # Install MacOS applications to the user environment.
    APPS="$HOME/Applications/Nix Apps"
    # Reset current state
    [ -e "$APPS" ] && $DRY_RUN_CMD rm -r "$APPS"
    $DRY_RUN_CMD mkdir -p "$APPS"
    # .app dirs need to be actual directories for Finder to detect them as Apps.
    # In the env of Apps we build, the .apps are symlinks. We pass all of them as
    # arguments to cp and make it dereference those using -H
    $DRY_RUN_CMD cp --archive -H --dereference ${config.system.build.applications}/Applications/* "$APPS"
    $DRY_RUN_CMD chmod +w -R "$APPS"
  '';
}

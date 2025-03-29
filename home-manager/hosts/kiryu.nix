{
  config,
  pkgs,
  ...
}: {
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
    ../../modules/home-manager/default.nix
  ];

  targets.genericLinux.enable = true;

  home.activation.setupOpenGLDriverSymlinks = config.lib.dag.entryAfter ["writeBoundary"] ''
    OPENGL_PROFILE="/nix/var/nix/profiles/opengl-driver"
    OPENGL_PROFILE_32="/nix/var/nix/profiles/opengl-driver-32"
    OPENGL_SYMLINK_CONF="/etc/tmpfiles.d/nix-opengl-driver.conf"
    sudo rm -f "$OPENGL_SYMLINK_CONF"
    printf "L+ /run/opengl-driver - - - - %s\nL+ /run/opengl-driver-32 - - - - %s\n" "$OPENGL_PROFILE" "$OPENGL_PROFILE_32" | sudo tee "$OPENGL_SYMLINK_CONF"
    sudo systemd-tmpfiles --create "$OPENGL_SYMLINK_CONF"
  '';
}

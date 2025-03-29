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

  # Activation script to manage OpenGL driver symlinks
  home.activation.openglLink = pkgs.lib.hm.dag.entryAfter ["writeBoundary"] ''
    echo "Setting up OpenGL driver symlinks..."
    OPENGL_PROFILE="/nix/var/nix/profiles/opengl-driver"
    OPENGL_PROFILE_32="/nix/var/nix/profiles/opengl-driver-32"
    OPENGL_SYMLINK_CONF="/etc/tmpfiles.d/nix-opengl-driver.conf"
    # Ensure commands use paths from Nix store for reproducibility
    # Note: This requires the user running home-manager switch to have sudo privileges without a password for these specific commands,
    # or for sudoers to be configured appropriately.
    ${pkgs.sudo}/bin/sudo rm -f "$OPENGL_SYMLINK_CONF"
    printf "L+ /run/opengl-driver - - - - %s\nL+ /run/opengl-driver-32 - - - - %s\n" "$OPENGL_PROFILE" "$OPENGL_PROFILE_32" | ${pkgs.sudo}/bin/sudo ${pkgs.coreutils}/bin/tee "$OPENGL_SYMLINK_CONF"
    ${pkgs.sudo}/bin/sudo ${pkgs.systemd}/bin/systemd-tmpfiles --create "$OPENGL_SYMLINK_CONF"
    echo "OpenGL symlink setup complete."
  '';


}

OPENGL_PROFILE="/nix/var/nix/profiles/opengl-driver"
OPENGL_PROFILE_32="/nix/var/nix/profiles/opengl-driver-32"
OPENGL_SYMLINK_CONF="/etc/tmpfiles.d/nix-opengl-driver.conf"

echo "Setting up drivers symlink..."
sudo rm -f "$OPENGL_SYMLINK_CONF"
printf "L+ /run/opengl-driver - - - - %s\nL+ /run/opengl-driver-32 - - - - %s\n" "$OPENGL_PROFILE" "$OPENGL_PROFILE_32" | sudo tee "$OPENGL_SYMLINK_CONF"
sudo systemd-tmpfiles --create "$OPENGL_SYMLINK_CONF"

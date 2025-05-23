{
  config,
  pkgs,
  ...
}: {
  services = {
    syncthing = {
      enable = true;
      user = "mateusp";
      dataDir = "/home/mateusp/Documents"; # Default folder for new synced folders
      configDir = "/home/mateusp/Documents/.config/syncthing"; # Folder for Syncthing's settings and keys
    };
  };
}

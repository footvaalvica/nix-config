{
  config,
  lib,
  pkgs,
  ...
}: {
  services.home-assistant = {
    enable = true;
    config = null;
    configWritable = true;
  };
}

{
  config,
  lib,
  pkgs,
  ...
}: {
  services.home-assistant = {
    enable = true;
    openFirewall = true;
    config = null;
    configWritable = true;
  };
}

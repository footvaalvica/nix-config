{ pkgs, lib, ... }:

{
  services.authelia.instances.main = {
    enable = false;
  };
}
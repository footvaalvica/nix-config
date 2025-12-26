{
  config,
  lib,
  pkgs,
  ...
}: {
  virtualisation = {
    libvirtd = {
      enable = true;
      # Used for UEFI boot of Home Assistant OS guest image
      qemuOvmf = true;
    };
  };

  environment.systemPackages = with pkgs; [
    # For virt-install
    virt-manager

    # For lsusb
    usbutils
  ];

  # Access to libvirtd
  users.users.mateusp = {
    extraGroups = ["libvirtd"];
  };

  # /etc/nixos/configuration.nix
  networking.defaultGateway = "10.0.0.1";
  networking.bridges.br0.interfaces = ["eno1"];
  networking.interfaces.br0 = {
    useDHCP = false;
    ipv4.addresses = [{
      "address" = "10.0.0.5";
      "prefixLength" = 24;
    }];
  };
}

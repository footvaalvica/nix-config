# Home Assistant OS as a VM in NixOS using Incus
{
  config,
  pkgs,
  lib,
  ...
}: {
  virtualisation = {
    incus = {
      enable = true;
      ui.enable = true; # Enable web UI
      preseed = {
        networks = [
          {
            name = "incusbr0";
            type = "bridge";
            config = {
              "ipv4.address" = "10.0.100.1/24";
              "ipv4.nat" = "true";
            };
          }
        ];
        storage_pools = [
          {
            name = "dir-incus";
            driver = "dir";
            config = {
              source = "/var/lib/incus/storage-pools/dir-incus";
            };
          }
        ];
        profiles = [
          {
            name = "default";
            devices = {
              eth0 = {
                name = "eth0";
                network = "incusbr0";
                type = "nic";
              };
              root = {
                path = "/";
                pool = "dir-incus";
                type = "disk";
              };
            };
          }
        ];
      };
    };

    # Also enable libvirtd for virt-manager
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
      };
    };
  };

  networking = {
    # Use systemd-networkd for bridge management
    useNetworkd = true;
    # Required for Incus networking
    nftables.enable = true;
    # Disable firewall for simplified setup (local network only)
    firewall = {
      allowedTCPPorts = [8123];
    };
    # Create bridge interface with NixOS
    bridges.br0 = {
      interfaces = ["eno1"]; # Your ethernet interface
    };

    # Configure bridge with DHCP
    interfaces.br0 = {
      useDHCP = true;
    };
  };

  users.users."mateusp" = {
    extraGroups = [
      "incus-admin"
      "libvirtd"
    ];
  };

  environment.systemPackages = with pkgs; [
    # Virtualization packages
    qemu_kvm # QEMU with KVM support
    virt-manager # GUI for VM management
    libvirt # libvirt client tools
    bridge-utils # Network bridge utilities
  ];
}

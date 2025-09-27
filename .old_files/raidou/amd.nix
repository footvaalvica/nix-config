{
  pkgs,
  lib,
  config,
  ...
}: {
  # AMD

  boot.initrd.kernelModules = [ "amdgpu" ];

  # Enable OpenGL
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    amdgpu.amdvlk = {
      enable = true;
      support32Bit.enable = true;
    };
  };

  services.xserver.videoDrivers = [ "amdgpu" ];
  
  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  ];

  hardware.graphics.extraPackages = with pkgs; [
    amdvlk
  ];
  # For 32 bit applications 
  hardware.graphics.extraPackages32 = with pkgs; [
    driversi686Linux.amdvlk
  ];
  
  environment.systemPackages = with pkgs; [ lact ];
  systemd.packages = with pkgs; [ lact ];
  systemd.services.lactd.wantedBy = ["multi-user.target"];
}

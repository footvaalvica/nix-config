{
  config,
  pkgs,
  ...
}: {
  # Start vscode at startup
  systemd.services.code-tunnel = {
    enable = true;
    description = "Enable VS Code tunnel";
    serviceConfig = {
      User = "mateusp";
      Type = "simple";
      Restart = "always";
      RestartSec = "10s";
      ExecStart = "/bin/sh -lc '${pkgs.vscode.fhs}/bin/code tunnel --accept-server-license-terms'";
    };

    wantedBy = ["multi-user.target"];
  };

  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [
    vscode-fhs
    gh
  ];
}
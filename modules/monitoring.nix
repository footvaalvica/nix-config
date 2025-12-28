{
  config,
  pkgs,
  ...
}: {
  services.caddy = {
    enable = true;
    virtualHosts."grafana.footvaalvica.com".extraConfig = ''
      reverse_proxy localhost:3001
    '';
    acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
  };

  cloudflare-dyndns.domains = ["grafana.footvaalvica.com"];

  services.prometheus.exporters.node = {
    enable = true;
    port = 9100;
    enabledCollectors = [
      "logind"
      "systemd"
    ];
    disabledCollectors = [
      "textfile"
    ];
    nut = {
      enable = true;
      nutUser = "upsmon";
      passwordPath = "/home/mateusp/nix-config/hosts/omi/upsmon.pass";
      openFirewall = true;
    };
    openFirewall = true;
    firewallFilter = "-i br0 -p tcp -m tcp --dport 9100";
  };

  services.grafana = {
    enable = true;
    settings.server = {
      http_addr = "0.0.0.0";
      http_port = 3000;
      root_url = "https://grafana.footvaalvica.com/";
      enable_gzip = true;
    };
    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          url = "http://127.0.0.1:9100";
        }
      ];
    };
  };
}
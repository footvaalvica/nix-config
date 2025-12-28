{
  config,
  pkgs,
  agenix,
  ...
}: {
  services.caddy = {
    enable = true;
    virtualHosts."grafana.footvaalvica.com".extraConfig = ''
      reverse_proxy localhost:3001
    '';
    acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
  };

  age.secrets.prometheus-nut-exporter-password = {
    file = "../secrets/upsmon.pass.age";
    user = "nut-exporter";
    group = "nut-exporter";
  };

  services.cloudflare-dyndns.domains  = ["grafana.footvaalvica.com"];

  services.prometheus = {
    enable = true;
    globalConfig.scrape_interval = "10s"; # "1m"
    scrapeConfigs = [
      {
        job_name = "all_exporters";
        static_configs = [
          {
            targets = [
              "localhost:${toString config.services.prometheus.exporters.node.port}" 
              "localhost:${toString config.services.prometheus.exporters.nut.port}"
            ];
          }
        ];
      }
    ];
  };

  services.prometheus.exporters = {
    node = {
      enable = true;
      port = 9100;
      enabledCollectors = [
        "systemd"
      ];
      openFirewall = true;
    };
    nut = {
      enable = true;
      nutUser = "upsmon";
      passwordPath = config.age.secrets.prometheus-nut-exporter-password.path;
      openFirewall = true;
    };
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
          url = "http://127.0.0.1:9090";
        }
      ];
    };
  };
}
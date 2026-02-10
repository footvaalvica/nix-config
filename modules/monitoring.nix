{
  config,
  pkgs,
  agenix,
  secrets,
  ...
}: {
  services.caddy = {
    enable = true;
    virtualHosts."grafana.footvaalvica.com".extraConfig = ''
      reverse_proxy localhost:3000
    '';
    acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
  };

  age.secrets.prometheus-nut-exporter-password = {
    file = ../secrets/upsmon.pass.age;
    mode = "777";
  };

  services.cloudflare-dyndns.domains  = ["grafana.footvaalvica.com"];

  services.prometheus = {
    enable = true;
    globalConfig.scrape_interval = "10s"; # "1m"
    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          {
            targets = [
              "localhost:${toString config.services.prometheus.exporters.node.port}" 
            ];
          }
        ];
      }
      {
        job_name = "nut";
        metrics_path = "/ups_metrics";
        static_configs = [
          {
            targets = ["localhost:${toString config.services.prometheus.exporters.nut.port}"];
          }
        ];
      }
      {
        job_name = "blackbox";
        metrics_path = "/probe";
        params = {
          module = [ "my_tcp" "my_icmp" "my_udp" ];
        };
        static_configs = [
          {
            targets = [
              "https://cloud.footvaalvica.com/"
              "https://photos.footvaalvica.com/"
              "https://homeassistantvlc.footvaalvica.com/"
              "https://overleaf.footvaalvica.com/"
              "https://firefly.footvaalvica.com/"
              "https://grafana.footvaalvica.com/"
              "https://www.footvaalvica.com/"
              "https://footvaalvica.com/"
              "https://matrix.footvaalvica.com/"
              "https://discord-bridge.footvaalvica.com/"
              "http://omi:12345/"
            ];
          }
        ];
        relabel_configs = [
          {
            source_labels = [ "__address__" ];
            target_label = "__param_target";
          }
          {
            source_labels = [ "__param_target" ];
            target_label = "instance";
          }
          {
            target_label = "__address__";
            replacement = "localhost:${toString config.services.prometheus.exporters.blackbox.port}";
          }
        ];
      }
      # ! NOTE TO SELF: this is kinda useless since idk what to do with the
      # ! metrics, but whatever, it's here if I need it later
      {
        job_name = "hass-vlc";
        scrape_interval = "60s";
        metrics_path = "/api/prometheus";
        authorization.credentials = "${secrets.hass.prometheus.token}";
        scheme = "https";
        static_configs = [
          {
            targets = ["homeassistantvlc.footvaalvica.com"];
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
      port = 9199;
      nutUser = "upsmon";
      passwordPath = config.age.secrets.prometheus-nut-exporter-password.path;
      openFirewall = true;
    };
    blackbox = {
      enable = true;
      port = 9115;
      openFirewall = true;
      configFile = (pkgs.formats.json {}).generate "config.json" {
        modules = {
          my_tcp = {
            prober = "http";
              timeout = "5s";
              http = {
                valid_status_codes = [ 200 201 300 301 ];
              };
          };
          my_icmp = {
            prober = "icmp";
            timeout = "5s";
            icmp = {
              preferred_ip_protocol = "ip4";
            };
          };
          my_udp = {
            prober = "icmp";
            timeout = "5s";
            icmp = {
              preferred_ip_protocol = "udp";
            };
          };
        };
      };
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
          name = "prometheus";
          type = "prometheus";
          url = "http://127.0.0.1:9090";
        }
      ];
    };
  };
}

{
  pkgs,
  lib,
  secrets,
  ...
}: {
  services.caddy = {
    enable = true;
    virtualHosts."footvaalvica.com".extraConfig = ''
      reverse_proxy localhost:5423
    '';
    acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
  };

  services.cloudflare-dyndns.domains = ["footvaalvica.com"];

  services.glance = {
    enable = true;
    openFirewall = true;
    settings = {
      server = {
        port = 5423;
        host = "0.0.0.0";
      };
      pages = [
        {
          name = "Startpage";
          width = "slim";
          hide-desktop-navigation = true;
          center-vertically = true;
          columns = [
            {
              size = "full";
              widgets = [
                {
                  type = "search";
                  autofocus = true;
                }
                {
                  type = "monitor";
                  cache = "1m";
                  title = "Services";
                  sites = [
                    {
                      title = "Nextcloud";
                      url = "https://cloud.footvaalvica.com/";
                      icon = "si:nextcloud";
                    }
                    {
                      title = "Immich";
                      url = "https://photos.footvaalvica.com/";
                      icon = "si:immich";
                    }
                    {
                      title = "Home Assistant - VLC";
                      url = "https://homeassistantvlc.footvaalvica.com/";
                      icon = "mdi:home";
                    }
                    {
                      title = "Overleaf";
                      url = "https://overleaf.footvaalvica.com/";
                      icon = "si:overleaf";
                    }
                    {
                      title = "Firefly III";
                      url = "https://firefly.footvaalvica.com/";
                      icon = "si:fireflyiii";
                    }
                    {
                      title = "Grafana";
                      url = "https://grafana.footvaalvica.com/";
                      icon = "si:grafana";
                    }
                    {
                      title = "Website";
                      url = "https://www.footvaalvica.com/";
                      icon = "mdi:web";
                    }
                  ];
                }
              ];
            }
          ];
        }
      ];
    };
  };
}

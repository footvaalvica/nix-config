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
    dataDir = "/var/lib/glance";
    openFirewall = true;
    port = 5423;
    host = "0.0.0.0";
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
                  { title = "Jellyfin";
                    url = "https://yourdomain.com/";
                    icon = "si:jellyfin";
                  }
                  { title = "Gitea";
                    url = "https://yourdomain.com/";
                    icon = "si:gitea";
                  }
                  { title = "qBittorrent"; # only for Linux ISOs, of course
                    url = "https://yourdomain.com/";
                    icon = "si:qbittorrent";
                  }
                  { title = "Immich";
                    url = "https://yourdomain.com/";
                    icon = "si:immich";
                  }
                  { title = "AdGuard Home";
                    url = "https://yourdomain.com/";
                    icon = "si:adguard";
                  }
                  { title = "Vaultwarden";
                    url = "https://yourdomain.com/";
                    icon = "si:vaultwarden";
                  }
                ];    
              }
            ];
          }
        ];
      }
    ];
  };
}
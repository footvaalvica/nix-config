{
  config,
  pkgs,
  ...
}: {
  services.caddy = {
    enable = true;
    virtualHosts."coder.footvaalvica.com".extraConfig = ''
      reverse_proxy localhost:3000
    '';
    virtualHosts."code.footvaalvica.com".extraConfig = ''
      reverse_proxy localhost:4444
    '';
    acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
  };

  services.cloudflare-dyndns.domains = ["coder.footvaalvica.com" "code.footvaalvica.com" ];

  services.coder = { 
    enable = true;
    accessUrl = "https://coder.footvaalvica.com";
    listenAddress = "0.0.0.0:3000";
  };

  users.users.coder = {
    extraGroups = [ "docker" ];
  };


  services.code-server = {
    enable = true;
    host = "0.0.0.0";
    hashedPassword = "$argon2i$v=19$m=4096,t=3,p=1$Rm5FSDlHTHBNUVRvZnJrNjdXMlZIRlptTUJRPQ$jw3xcOCe8hL33qVm3BURtZeoJuTWWzmZ70iuU0pJDFk";
  };
}

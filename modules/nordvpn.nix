{
  config,
  lib,
  pkgs,
  ...
}: let
  nordVpnPkg = pkgs.callPackage ({
    autoPatchelfHook,
    buildFHSEnvChroot,
    dpkg,
    fetchurl,
    lib,
    stdenv,
    sysctl,
    iptables,
    iproute2,
    procps,
    cacert,
    libxml2,
    libidn2,
    libnl,
    libcap_ng,
    zlib,
    wireguard-tools,
  }: let
    pname = "nordvpn";
    version = "3.20.0";

    nordVPNBase = stdenv.mkDerivation {
      inherit pname version;

      src = fetchurl {
        url = "https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/n/nordvpn/nordvpn_${version}_amd64.deb";
        hash = "sha256-3/HSCTPt/1CprrpVD60Ga02Nz+vBwNBE1LEl+7z7ADs=";
      };

      buildInputs = [libxml2 libidn2 libnl libcap_ng ];
      nativeBuildInputs = [dpkg autoPatchelfHook stdenv.cc.cc.lib];

      dontConfigure = true;
      dontBuild = true;

      unpackPhase = ''
        runHook preUnpack
        dpkg --extract $src .
        runHook postUnpack
      '';

      installPhase = ''
        runHook preInstall
        mkdir -p $out
        mv usr/* $out/
        mv var/ $out/
        mv etc/ $out/
        runHook postInstall
      '';
    };

    nordVPNfhs = buildFHSEnvChroot {
      name = "nordvpnd";
      runScript = "nordvpnd";

      # hardcoded path to /sbin/ip
      targetPkgs = pkgs: [
        nordVPNBase
        sysctl
        iptables
        iproute2
        procps
        cacert
        libxml2
        libidn2
        zlib
        wireguard-tools
      ];
    };
  in
    stdenv.mkDerivation {
      inherit pname version;

      dontUnpack = true;
      dontConfigure = true;
      dontBuild = true;

      installPhase = ''
        runHook preInstall
        mkdir -p $out/bin $out/share
        ln -s ${nordVPNBase}/bin/nordvpn $out/bin
        ln -s ${nordVPNfhs}/bin/nordvpnd $out/bin
        ln -s ${nordVPNBase}/share/* $out/share/
        ln -s ${nordVPNBase}/var $out/
        runHook postInstall
      '';

      meta = with lib; {
        description = "CLI client for NordVPN";
        homepage = "https://www.nordvpn.com";
        license = licenses.unfreeRedistributable;
        maintainers = with maintainers; [dr460nf1r3];
        platforms = ["x86_64-linux"];
      };
    }) {};
in
  with lib; {
    options.myypo.services.custom.nordvpn.enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable the NordVPN daemon. Note that you'll have to set
        `networking.firewall.checkReversePath = false;`, add UDP 1194
        and TCP 443 to the list of allowed ports in the firewall and add your
        user to the "nordvpn" group (`users.users.<username>.extraGroups`).
      '';
    };

    config = mkIf config.myypo.services.custom.nordvpn.enable {
      networking.firewall.checkReversePath = false;
      networking.firewall.allowedTCPPorts = [ 443 ];
      networking.firewall.allowedUDPPorts = [ 1194 ];
      users.users.mateusp.extraGroups = ["nordvpn"];

      # This kinda sucks and it's not very declarative but it works!
      environment.etc.hosts.mode = "0644";
      environment.systemPackages = [nordVpnPkg];

      users.groups.nordvpn = {};
      users.groups.nordvpn.members = ["mateusp"];
      systemd = {
        services.nordvpn = {
          description = "NordVPN daemon.";
          serviceConfig = {
            ExecStart = "${nordVpnPkg}/bin/nordvpnd && /bin/sh -lc 'nordvpn set meshnet off && nordvpn set meshnet on'";
            ExecStartPre = pkgs.writeShellScript "nordvpn-start" ''
              mkdir -m 700 -p /var/lib/nordvpn;
              if [ -z "$(ls -A /var/lib/nordvpn)" ]; then
                cp -r ${nordVpnPkg}/var/lib/nordvpn/* /var/lib/nordvpn;
              fi
            '';
            NonBlocking = true;
            KillMode = "process";
            Restart = "on-failure";
            RestartSec = 5;
            RuntimeDirectory = "nordvpn";
            RuntimeDirectoryMode = "0750";
            Group = "nordvpn";
          };
          wantedBy = ["multi-user.target"];
          after = ["network-online.target"];
          wants = ["network-online.target"];
        };
      };
    };
  }

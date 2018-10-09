{ config, pkgs, ... }:
with pkgs.lib;
{

  systemd.network.networks = mkIf (!config.networking.enableIPv6) (mapAttrs' (name: value: nameValuePair ("40-${name}") ({ networkConfig.IPv6AcceptRA = "no"; networkConfig.LinkLocalAddressing = "no";}) ) config.networking.interfaces);

}
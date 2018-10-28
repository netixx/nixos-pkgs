{ config, lib, pkgs, ... }:
{
  imports = [
    ./hardening.nix
    ./hostapd.nix
    # ./iptools.nix
    ./network-ipv6-fixes.nix
    ./caches.nix
  ];
}

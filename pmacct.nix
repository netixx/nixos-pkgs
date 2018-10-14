{ config, pkgs, ... }:
let
  pmacct = pkgs.callPackage ./pmacct {};
in
{
environment.systemPackages = [
    pmacct
  ];
}
{ config, lib, pkgs, ... }:
{
  nix = {
    binaryCaches = [
      "https://netixx.cachix.org"
    ];
    binaryCachePublicKeys = [
      "netixx.cachix.org-1:UeQ3yXggR/nBSWlY+qxZItWpPX3BkPRSycm+cHMEmfc="
    ];
  };
}
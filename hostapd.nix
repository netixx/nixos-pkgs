{ config, lib, pkgs, ... }:

# TODO:
#
# asserts
#   ensure that the nl80211 module is loaded/compiled in the kernel
#   wpa_supplicant and hostapd on the same wireless interface doesn't make any sense

with lib;

let

  cfg = config.services.hostapd;

  configFile = pkgs.writeText "hostapd.conf" ''
    interface=${cfg.interface}
    driver=${cfg.driver}
    ssid=${cfg.ssid}
    hw_mode=${cfg.hwMode}
    # channel=${toString cfg.channel}
    # logging (debug level)
    logger_syslog=-1
    logger_syslog_level=2
    logger_stdout=-1
    logger_stdout_level=2
    ctrl_interface=/var/run/hostapd
    ctrl_interface_group=${cfg.group}
    ${if cfg.wpa then ''
      wpa=1
      wpa_passphrase=${cfg.wpaPassphrase}
      '' else ""}
    ${cfg.extraConfig}
  '' ;

in

{
  ###### interface

  options = {

  };


  ###### implementation

  config = mkIf cfg.enable {
    assertions = mkForce [];
  };
}

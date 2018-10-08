{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.security.hardening;

  writeConfig = cfg: pkgs.writeText "hardening.sh"
    ''
      #! ${pkgs.bash}/bin/bash

      chgrp nix-users /nix/var/nix/daemon-socket
      chmod ug=rwx,o= /nix/var/nix/daemon-socket
    '';

    /*writeConfig = cfg: (import ./writeSecureText.nix).writeSecureText "hardening.sh"
      ''
        #! ${pkgs.bash}/bin/bash

        chgrp nix-users /nix/var/nix/daemon-socket
        chmod ug=rwx,o= /nix/var/nix/daemon-socket
      '' "o-r" "root:root";*/

  hardeningService = cfg:
  {
    description = "Hardening configuration";
    wantedBy = ["multi-user.target"];
    serviceConfig =
      let
        configFile = writeConfig cfg;
      in {
        ExecStart = "${pkgs.bash}/bin/bash ${configFile}";
        User = "root";

      };
  };

  hardeningConfig = {

    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable the hardening measures.
      '';
    };
  };
in

{
  ###### interface

  options = {
    security.hardening = hardeningConfig;
  };

  ###### implementation

  # TODO: make it work
  # imports = pkgs.lib.optional (cfg.enable) [
  #   <nixpkgs>/nixos/modules/profiles/hardened.nix
  # ];

  config = mkIf (cfg.enable) {
    ## REMOVE
    boot.kernelPackages = mkDefault pkgs.linuxPackages_hardened;

    security.hideProcessInformation = mkDefault true;

    security.lockKernelModules = mkDefault true;

    security.apparmor.enable = mkDefault true;

    boot.blacklistedKernelModules = [
      # Obscure network protocols
      "ax25"
      "netrom"
      "rose"
    ];

    # Restrict ptrace() usage to processes with a pre-defined relationship
    # (e.g., parent/child)
    boot.kernel.sysctl."kernel.yama.ptrace_scope" = mkOverride 500 1;

    # Prevent replacing the running kernel image w/o reboot
    boot.kernel.sysctl."kernel.kexec_load_disabled" = mkDefault true;

    # Restrict access to kernel ring buffer (information leaks)
    boot.kernel.sysctl."kernel.dmesg_restrict" = mkDefault true;

    # Hide kptrs even for processes with CAP_SYSLOG
    boot.kernel.sysctl."kernel.kptr_restrict" = mkOverride 500 2;

    # Unprivileged access to bpf() has been used for privilege escalation in
    # the past
    boot.kernel.sysctl."kernel.unprivileged_bpf_disabled" = mkDefault true;

    # Disable bpf() JIT (to eliminate spray attacks)
    boot.kernel.sysctl."net.core.bpf_jit_enable" = mkDefault false;

    # ... or at least apply some hardening to it
    boot.kernel.sysctl."net.core.bpf_jit_harden" = mkDefault true;

    # A recurring problem with user namespaces is that there are
    # still code paths where the kernel's permission checking logic
    # fails to account for namespacing, instead permitting a
    # namespaced process to act outside the namespace with the
    # same privileges as it would have inside it.  This is particularly
    # bad in the common case of running as root within the namespace.
    #
    # Setting the number of allowed user namespaces to 0 effectively disables
    # the feature at runtime.  Attempting to create a user namespace
    # with unshare will then fail with "no space left on device".
    # incompatible with nix.useSandbox = true (default as of nixos-18.09) see https://github.com/NixOS/nix/issues/1915
    #boot.kernel.sysctl."user.max_user_namespaces" = mkDefault 1;

    # Raise ASLR entropy for 64bit & 32bit, respectively.
    #
    # Note: mmap_rnd_compat_bits may not exist on 64bit.
    boot.kernel.sysctl."vm.mmap_rnd_bits" = mkDefault 32;
    boot.kernel.sysctl."vm.mmap_rnd_compat_bits" = mkDefault 16;

    # Allowing users to mmap() memory starting at virtual address 0 can turn a
    # NULL dereference bug in the kernel into code execution with elevated
    # privilege.  Mitigate by enforcing a minimum base addr beyond the NULL memory
    # space.  This breaks applications that require mapping the 0 page, such as
    # dosemu or running 16bit applications under wine.  It also breaks older
    # versions of qemu.
    #
    # The value is taken from the KSPP recommendations (Debian uses 4096).
    boot.kernel.sysctl."vm.mmap_min_addr" = mkDefault 65536;
    ## REMOVE

    boot.kernelParams = [
      # Disable legacy virtual syscalls
      "vsyscall=none"

      # Disable hibernation (allows replacing the running kernel)
      "nohibernate"
    ];

    systemd.services.hardening = hardeningService cfg;

    users.extraUsers.root.extraGroups = [ "nix-users" ];
    # security.hideProcessInformation = true;
    # security.apparmor = {
    #   enable = true;
    # };

    # TODO: fix, does not work haveged ?
    security.rngd.enable = true;

    /*security.audit = {

    };*/

    # syn flood protection
    boot.kernel.sysctl."net.ipv4.tcp_syncookies" = 1;
    boot.kernel.sysctl."net.ipv4.tcp_max_syn_backlog" = 2048;
    boot.kernel.sysctl."net.ipv4.tcp_synack_retries" = 3;
    # turn of debbugging
    boot.kernel.sysctl."kernel.sysrq" = 0;
    #
    boot.kernel.sysctl."net.ipv4.icmp_echo_ignore_broadcasts" = 1;
    # ASLR
    boot.kernel.sysctl."kernel.randomize_va_space" = 2;
    # log protection
    # boot.kernel.sysctl."kernel.dmesg_restrict" = 1;

    # boot.kernel.sysctl."net.core.bpf_jit_enable" = 0;
  };


}

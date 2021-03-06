{ stdenv, fetchurl,
libpcap, pkgconfig, libtool,
autoconf, automake,
}:

with stdenv.lib;

let
  # _kernel = kernel;
  # python = python27.withPackages (ps: with ps; [ six ]);
in stdenv.mkDerivation rec {
  version = "1.7.0";
  name = "pmacct-${version}";

  src = fetchurl {
    url = "https://github.com/pmacct/pmacct/archive/${version}.tar.gz";
    sha256 = "0jf18n248qq4y65l23v01i8da83z3lnd1ihc56nlsykbn6ag45al";
  };

  # kernel = optional (_kernel != null) _kernel.dev;

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ libpcap libtool autoconf automake ];

  preConfigure = ''
    patchShebangs bin/configure-help-replace.sh
    ./autogen.sh
  '';

  configureFlags = [
    "--with-pcap-includes=${libpcap}/include"
  ];

  # # Leave /var out of this!
  # installFlags = [
  #   "LOGDIR=$(TMPDIR)/dummy"
  #   "RUNDIR=$(TMPDIR)/dummy"
  #   "PKIDIR=$(TMPDIR)/dummy"
  # ];

  # postBuild = ''
  #   # fix tests
  #   substituteInPlace xenserver/opt_xensource_libexec_interface-reconfigure --replace '/usr/bin/env python' '${python.interpreter}'
  #   substituteInPlace vtep/ovs-vtep --replace '/usr/bin/env python' '${python.interpreter}'
  # '';

  # enableParallelBuilding = true;
  # doCheck = false; # bash-completion test fails with "compgen: command not found"

  # meta = with stdenv.lib; {
  #   platforms = platforms.linux;
  #   description = "A multilayer virtual switch";
  #   longDescription =
  #     ''
  #     Open vSwitch is a production quality, multilayer virtual switch
  #     licensed under the open source Apache 2.0 license. It is
  #     designed to enable massive network automation through
  #     programmatic extension, while still supporting standard
  #     management interfaces and protocols (e.g. NetFlow, sFlow, SPAN,
  #     RSPAN, CLI, LACP, 802.1ag). In addition, it is designed to
  #     support distribution across multiple physical servers similar
  #     to VMware's vNetwork distributed vswitch or Cisco's Nexus 1000V.
  #     '';
  #   homepage = http://openvswitch.org/;
  #   license = licenses.asl20;
  # };
}

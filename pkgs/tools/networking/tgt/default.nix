{ stdenv, lib, fetchFromGitHub, libxslt, libaio, systemd, perl
, docbook_xsl, coreutils, lsof, rdma-core, makeWrapper, sg3_utils, util-linux
}:

stdenv.mkDerivation rec {
  pname = "tgt";
  version = "1.0.85";

  src = fetchFromGitHub {
    owner = "fujita";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-hjP+1uBcUfIFdRd0gbZXR+VsAF+6QrvV3//GrQhOKWc=";
  };

  nativeBuildInputs = [ libxslt docbook_xsl makeWrapper ];

  buildInputs = [ systemd libaio ];

  makeFlags = [
    "PREFIX=${placeholder "out"}"
    "SD_NOTIFY=1"
  ];

  NIX_CFLAGS_COMPILE = [
    # Needed with GCC 12
    "-Wno-error=maybe-uninitialized"
  ];

  installFlags = [
    "sysconfdir=${placeholder "out"}/etc"
  ];

  preConfigure = ''
    sed -i 's|/usr/bin/||' doc/Makefile
    sed -i 's|/usr/include/libaio.h|${libaio}/include/libaio.h|' usr/Makefile
    sed -i 's|/usr/include/sys/|${stdenv.cc.libc.dev}/include/sys/|' usr/Makefile
    sed -i 's|/usr/include/linux/|${stdenv.cc.libc.dev}/include/linux/|' usr/Makefile
  '';

  postInstall = ''
    substituteInPlace $out/sbin/tgt-admin \
      --replace "#!/usr/bin/perl" "#! ${perl.withPackages (p: [ p.ConfigGeneral ])}/bin/perl"
    wrapProgram $out/sbin/tgt-admin --prefix PATH : \
      ${lib.makeBinPath [ lsof sg3_utils (placeholder "out") ]}

    install -D scripts/tgtd.service $out/etc/systemd/system/tgtd.service
    substituteInPlace $out/etc/systemd/system/tgtd.service \
      --replace "/usr/sbin/tgt" "$out/bin/tgt"

    # See https://bugzilla.redhat.com/show_bug.cgi?id=848942
    sed -i '/ExecStart=/a ExecStartPost=${coreutils}/bin/sleep 5' $out/etc/systemd/system/tgtd.service
  '';

  enableParallelBuilding = true;

  meta = with lib; {
    description = "iSCSI Target daemon with RDMA support";
    homepage = "https://github.com/fujita/tgt";
    license = licenses.gpl2;
    platforms = platforms.linux;
    maintainers = with maintainers; [ johnazoidberg ];
  };
}

{ lib, clangStdenv, fetchFromGitHub, autoconf, automake, libtool, autoreconfHook
, installShellFiles
, libuuid
, pkgs
, libdispatch
, libobjc ? null
, darwin_target ? "darwin19"
}:

let
  stdenv = clangStdenv;

  # The targetPrefix prepended to binary names to allow multiple binuntils on the
  # PATH to both be usable.
  targetPrefix = lib.optionalString
    (stdenv.targetPlatform != stdenv.hostPlatform)
    "${stdenv.targetPlatform.config}-";
in

clangStdenv.mkDerivation {
  pname = "${targetPrefix}cctools-port";
  version = "1010.6";

  src = fetchFromGitHub {
    owner  = "tpoechtrager";
    repo   = "cctools-port";
    /*
    rev    = "6540086c5e12e9c1649fed524b527d8c1793ddc0";
    sha256 = "sha256-s0Pzbk+h23UYlhqQkOt6NbvPSi6aSjk/FVY0VkbPQ0o=";
    */

    rev    = "81f205e8ca6bbf2fdbcb6948132454fd1f97839e";
    sha256 = "sha256-a5ip0e/nQrCOEwIO3qrNGP8246cjEXNPk2/TQnccZU4=";

  };

  outputs = [ "out" "dev" "man" ];

  nativeBuildInputs = [ autoconf automake libtool autoreconfHook installShellFiles pkgs.darwin.libdispatch ];
  buildInputs = [ libuuid libdispatch ]
    ++ lib.optionals stdenv.isDarwin [ libobjc ];

  # patches = [ ./ld-ignore-rpath-link.patch ./ld-rpath-nonfinal.patch ];

  __propagatedImpureHostDeps = [
    # As far as I can tell, otool from cctools is the only thing that depends on these two, and we should fix them
    "/usr/lib/libobjc.A.dylib"
    "/usr/lib/libobjc.dylib"
  ];

  enableParallelBuilding = true;

  configurePlatforms = [ "build" "host" ];
    # We pass --target explicitly.
    # ++ lib.optional (stdenv.targetPlatform != stdenv.hostPlatform) "target";
  configureFlags = [ "--disable-clang-as" "--target=x86_64-apple-${darwin_target}" ];

  postPatch = lib.optionalString stdenv.hostPlatform.isDarwin ''
    substituteInPlace cctools/Makefile.am --replace libobjc2 ""
  '' + ''
    # FIXME: there are far more absolute path references that I don't want to fix right now
    substituteInPlace cctools/configure.ac \
      --replace "-isystem /usr/local/include -isystem /usr/pkg/include" "" \
      --replace "-L/usr/local/lib" "" \

    patchShebangs tools
    sed -i -e 's/which/type -P/' tools/*.sh

    # Workaround for https://www.sourceware.org/bugzilla/show_bug.cgi?id=11157
    cat > cctools/include/unistd.h <<EOF
    #ifdef __block
    #  undef __block
    #  include_next "unistd.h"
    #  define __block __attribute__((__blocks__(byref)))
    #else
    #  include_next "unistd.h"
    #endif
    EOF

    cd cctools
  '';

  preInstall = ''
    installManPage ar/ar.{1,5}
  '';

  passthru = {
    inherit targetPrefix;
  };

  meta = {
    homepage = "http://www.opensource.apple.com/source/cctools/";
    description = "MacOS Compiler Tools (cross-platform port)";
    license = lib.licenses.apsl20;
    maintainers = with lib.maintainers; [ matthewbauer ];
  };
}


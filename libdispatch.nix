{ lib, clangStdenv, fetchFromGitHub, pkgsBuildBuild, cmake, python3, ncurses }:

clangStdenv.mkDerivation {
  pname = "libdispatch";
  version = "6.0.3"; # determined by looking at VERSION.txt

  src = fetchFromGitHub {
    owner = "tpoechtrager";
    repo = "apple-libdispatch";
    rev = "fdf3fc85a9557635668c78801d79f10161d83f12";
    sha256 = "sha256-YQjYjBYRObRPgcRZgm5R2RFsuT6P2KBzWzJ3nB70Jk8=";
  };

  #sourceRoot = "source/src/llvm";

  # Backported from newer llvm, fixes configure error when cross compiling.
  # Also means we don't have to manually fix the result with install_name_tool.
  patches = [];

  nativeBuildInputs = [ cmake python3 ];

  # ncurses is required here to avoid a reference to bootstrap-tools, which is
  # not allowed for the stdenv.
  buildInputs = [ ncurses ];

  cmakeFlags = [ "-DLLVM_INCLUDE_TESTS=OFF" ]
    ++ lib.optional (clangStdenv.buildPlatform != clangStdenv.hostPlatform) [
      "-DCMAKE_CROSSCOMPILING=True"
      (
        let
          nativeCC = pkgsBuildBuild.clangStdenv.cc;
          nativeBintools = nativeCC.bintools.bintools;
          nativeToolchainFlags = [
            "-DCMAKE_C_COMPILER=${nativeCC}/bin/${nativeCC.targetPrefix}cc"
            "-DCMAKE_CXX_COMPILER=${nativeCC}/bin/${nativeCC.targetPrefix}c++"
            "-DCMAKE_AR=${nativeBintools}/bin/${nativeBintools.targetPrefix}ar"
            "-DCMAKE_STRIP=${nativeBintools}/bin/${nativeBintools.targetPrefix}strip"
            "-DCMAKE_RANLIB=${nativeBintools}/bin/${nativeBintools.targetPrefix}ranlib"
          ];
        in "-DCROSS_TOOLCHAIN_FLAGS_NATIVE:list=${lib.concatStringsSep ";" nativeToolchainFlags}"
      )
    ];

/*
  # fixes: fatal error: 'clang/Basic/Diagnostic.h' file not found
  # adapted from upstream
  # https://github.com/tpoechtrager/apple-libtapi/blob/3cb307764cc5f1856c8a23bbdf3eb49dfc6bea48/build.sh#L58-L60
  preConfigure = ''
    INCLUDE_FIX="-I $PWD/projects/clang/include"
    INCLUDE_FIX+=" -I $PWD/build/projects/clang/include"

    cmakeFlagsArray+=(-DCMAKE_CXX_FLAGS="$INCLUDE_FIX")
  '';
  */

  #buildFlags = [ "clangBasic" "libtapi" "tapi" ];

  #installTargets = [ "install-libtapi" "install-tapi-headers" "install-tapi" ];

  meta = with lib; {
    description = "Replaces the Mach-O Dynamic Library Stub files in Apple's SDKs to reduce the size";
    homepage = "https://github.com/tpoechtrager/apple-libtapi";
    license = licenses.apsl20;
    maintainers = with maintainers; [ matthewbauer ];
  };
}

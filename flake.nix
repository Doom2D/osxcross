{
  description = "OSXCross";

  nixConfig.bash-prompt = "\[\\u@osxcross:\\w\]$ ";

  inputs = {
    nixpkgs.url      = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url      = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }: {
    lib.toolchain = { llvmPackages, osxcross-wrapper, macos_sdk, cctools, makeWrapper, runCommand }: runCommand "osxcross-toolchain" {
      buildInputs = [ makeWrapper ];
      passthru = {
        inherit macos_sdk;
        target = macos_sdk.target;
        version = macos_sdk.version;
      };
    } ''
      TARGET=${macos_sdk.target}
      mkdir -p $out/SDK
      ln -s ${macos_sdk} $out/SDK/MacOSX${macos_sdk.version}.sdk
      SDK_ROOT=$out/SDK/MacOSX${macos_sdk.version}.sdk

      function create_wrapper_link
      {
        # arg 1:
        #  program name
        # arg 2:
        #  1: create a standalone link and links with the target triple prefix
        #  2: create links with target triple prefix and shortcut links such
        #     as o32, o64, ...
        #
        # example:
        #  create_wrapper_link osxcross 1
        # creates the following symlinks:
        #  -> osxcross
        #  -> x86_64-apple-darwinXX-osxcross
        #  -> x86_64h-apple-darwinXX-osxcross

        if [ $# -ge 2 ] && [ $2 -eq 1 ]; then
          makeWrapper "${osxcross-wrapper}/bin/wrapper" \
            "$out/bin/$1" --argv0 "$1" --prefix PATH : $out/bin --set OSXCROSS_CLANG_INTRINSIC_PATH "${llvmPackages.clang-unwrapped.lib}/lib/clang/" --set OSXCROSS_TARGET "$TARGET" --set OSXCROSS_SDKROOT "$SDK_ROOT" --prefix PATH : "${llvmPackages.clang-unwrapped}/bin/" --set OSXCROSS_LINKERPATH "${llvmPackages.lld}/bin/ld64.lld"
        fi

        makeWrapper "${osxcross-wrapper}/bin/wrapper" \
          "$out/bin/x86_64-apple-$TARGET-$1" --argv0 "x86_64-apple-$TARGET-$1" --prefix PATH : $out/bin --set OSXCROSS_CLANG_INTRINSIC_PATH "${llvmPackages.clang-unwrapped.lib}/lib/clang/" --set OSXCROSS_TARGET "$TARGET" --set OSXCROSS_SDKROOT "$SDK_ROOT" --prefix PATH : "${llvmPackages.clang-unwrapped}/bin/" --set OSXCROSS_LINKERPATH "${llvmPackages.lld}/bin/ld64.lld"

        if ([[ $1 != gcc* ]] && [[ $1 != g++* ]] && [[ $1 != *gstdc++ ]]); then
          makeWrapper "${osxcross-wrapper}/bin/wrapper" \
            "$out/bin/x86_64h-apple-$TARGET-$1" --argv0 "x86_64h-apple-$TARGET-$1" --prefix PATH : $out/bin --set OSXCROSS_CLANG_INTRINSIC_PATH "${llvmPackages.clang-unwrapped.lib}/lib/clang/" --set OSXCROSS_TARGET "$TARGET" --set OSXCROSS_SDKROOT "$SDK_ROOT" --prefix PATH : "${llvmPackages.clang-unwrapped}/bin/" --set OSXCROSS_LINKERPATH "${llvmPackages.lld}/bin/ld64.lld"

          makeWrapper "${osxcross-wrapper}/bin/wrapper" \
            "$out/bin/aarch64-apple-$TARGET-$1" --argv0 "aarch64-apple-$TARGET-$1" --prefix PATH : $out/bin --set OSXCROSS_CLANG_INTRINSIC_PATH "${llvmPackages.clang-unwrapped.lib}/lib/clang/" --set OSXCROSS_TARGET "$TARGET" --set OSXCROSS_SDKROOT "$SDK_ROOT" --prefix PATH : "${llvmPackages.clang-unwrapped}/bin/" --set OSXCROSS_LINKERPATH "${llvmPackages.lld}/bin/ld64.lld"
          makeWrapper "${osxcross-wrapper}/bin/wrapper" \
            "$out/bin/arm64-apple-$TARGET-$1" --argv0 "arm64-apple-$TARGET-$1" --prefix PATH : $out/bin --set OSXCROSS_CLANG_INTRINSIC_PATH "${llvmPackages.clang-unwrapped.lib}/lib/clang/" --set OSXCROSS_TARGET "$TARGET" --set OSXCROSS_SDKROOT "$SDK_ROOT" --prefix PATH : "${llvmPackages.clang-unwrapped}/bin/" --set OSXCROSS_LINKERPATH "${llvmPackages.lld}/bin/ld64.lld"
          makeWrapper "${osxcross-wrapper}/bin/wrapper" \
            "$out/bin/arm64e-apple-$TARGET-$1" --argv0 "arm64e-apple-$TARGET-$1" --prefix PATH : $out/bin --set OSXCROSS_CLANG_INTRINSIC_PATH "${llvmPackages.clang-unwrapped.lib}/lib/clang/" --set OSXCROSS_TARGET "$TARGET" --set OSXCROSS_SDKROOT "$SDK_ROOT" --prefix PATH : "${llvmPackages.clang-unwrapped}/bin/" --set OSXCROSS_LINKERPATH "${llvmPackages.lld}/bin/ld64.lld"
        fi

        if [ $# -ge 2 ] && [ $2 -eq 2 ]; then
          makeWrapper "${osxcross-wrapper}/bin/wrapper" \
            "$out/bin/o64-$1" --argv0 "o64-$1" --prefix PATH : $out/bin --set OSXCROSS_CLANG_INTRINSIC_PATH "${llvmPackages.clang-unwrapped.lib}/lib/clang/" --set OSXCROSS_TARGET "$TARGET" --set OSXCROSS_SDKROOT "$SDK_ROOT" --prefix PATH : "${llvmPackages.clang-unwrapped}/bin/" --set OSXCROSS_LINKERPATH "${llvmPackages.lld}/bin/ld64.lld"

          if ([[ $1 != gcc* ]] && [[ $1 != g++* ]] && [[ $1 != *gstdc++ ]]); then
            makeWrapper "${osxcross-wrapper}/bin/wrapper" \
              "$out/bin/o64h-$1" --argv0 "o64h-$1" --prefix PATH : $out/bin --set OSXCROSS_CLANG_INTRINSIC_PATH "${llvmPackages.clang-unwrapped.lib}/lib/clang/" --set OSXCROSS_TARGET "$TARGET" --set OSXCROSS_SDKROOT "$SDK_ROOT" --prefix PATH : "${llvmPackages.clang-unwrapped}/bin/" --set OSXCROSS_LINKERPATH "${llvmPackages.lld}/bin/ld64.lld"
          fi

          makeWrapper "${osxcross-wrapper}/bin/wrapper" \
            "$out/bin/oa64-$1" --argv0 "oa64-$1" --prefix PATH : $out/bin --set OSXCROSS_CLANG_INTRINSIC_PATH "${llvmPackages.clang-unwrapped.lib}/lib/clang/" --set OSXCROSS_TARGET "$TARGET" --set OSXCROSS_SDKROOT "$SDK_ROOT" --prefix PATH : "${llvmPackages.clang-unwrapped}/bin/" --set OSXCROSS_LINKERPATH "${llvmPackages.lld}/bin/ld64.lld"
          makeWrapper "${osxcross-wrapper}/bin/wrapper" \
            "$out/bin/oa64e-$1" --argv0 "oa64e-$1" --prefix PATH : $out/bin --set OSXCROSS_CLANG_INTRINSIC_PATH "${llvmPackages.clang-unwrapped.lib}/lib/clang/" --set OSXCROSS_TARGET "$TARGET" --set OSXCROSS_SDKROOT "$SDK_ROOT" --prefix PATH : "${llvmPackages.clang-unwrapped}/bin/" --set OSXCROSS_LINKERPATH "${llvmPackages.lld}/bin/ld64.lld"
        fi
      }


      create_wrapper_link clang 2
      create_wrapper_link clang++ 2
      create_wrapper_link clang++-libc++ 2
      create_wrapper_link clang++-stdc++ 2
      create_wrapper_link clang++-gstdc++ 2
      create_wrapper_link cc
      create_wrapper_link c++

      create_wrapper_link osxcross 1
      create_wrapper_link osxcross-conf 1
      create_wrapper_link osxcross-env 1
      create_wrapper_link osxcross-cmp 1
      create_wrapper_link osxcross-man 1
      create_wrapper_link pkg-config

      create_wrapper_link sw_vers 1

      create_wrapper_link xcrun 1
      create_wrapper_link xcodebuild 1

      for arch in "x86_64h" "x86_64" "aarch64" "arm64" "arm64e" ; do
        for CCTOOL in ${cctools}/bin/*; do
          CCTOOL_FNAME=$(basename $CCTOOL)
          ln -s "$CCTOOL" "$out/bin/$(echo "$CCTOOL_FNAME" | sed "s/x86_64/$arch/g" | sed "s/darwin20.4/$TARGET/g")"
        done
      done
    '';
  } // flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      selfpkgs = self.packages.${system};
    in
      rec {
        packages.libtapi = pkgs.callPackage ./libtapi.nix { };
        packages.cctools = pkgs.callPackage ./cctools.nix { libtapi = selfpkgs.libtapi; darwin_target = "darwin20.4"; };
        packages.osxcross-wrapper = pkgs.stdenv.mkDerivation {
          name = "osxcross-wrapper";
          version = "";
          src = pkgs.fetchFromGitHub {
            owner = "tpoechtrager";
            repo = "osxcross";
            rev = "be2b79f444aa0b43b8695a4fb7b920bf49ecc01c";
            sha256 = "sha256-3/dXHrzuLFXFL2h+P4hpCN1ejCp0RIcoZVISdFv9CVs=";
          } + "/wrapper";

          patches = [
            ./add-isystem.patch
            ./set_default_target.patch
            ./add-clang-intrinsic-path.patch
            ./ignore-target-arg.patch
            ./pass-intrinsic-on-darwin.patch
            ./add-osxcross-linkerpath.patch
          ];

          buildInputs = pkgs.lib.optional pkgs.stdenv.isDarwin pkgs.darwin.apple_sdk.frameworks.CoreServices;
          makeFlags = [ "LINKER_VERSION=609" ];

          installPhase = ''
            runHook preInstall

            install -D wrapper $out/bin/wrapper

            runHook postInstall
          '';
        };
        packages.macossdk_11_3 = pkgs.fetchzip {
          url = "https://github.com/phracker/MacOSX-SDKs/releases/download/11.3/MacOSX11.3.sdk.tar.xz";
          sha256 = "sha256-BoFWhRSHaD0j3dzDOFtGJ6DiRrdzMJhkjxztxCluFKo=";
          passthru = {
            version = "11.3";
            target = "darwin20.4";
            x86_64h_supported = true;
            i386_supported = false;
            arm_supported = true;
            osx_version_min = "10.9";
          };
        };
        packages.macossdk_12_3 = pkgs.fetchzip {
          url = "https://github.com/roblabla/MacOSX-SDKs/releases/download/12.x/MacOSX12.3.sdk.tar.xz";
          sha256 = "sha256-/z2m/MjwQ8j+F3kZw+/ZnI69bF4UA9hZJrJtKj+A9kU";
          passthru = {
            version = "12.3";
            target = "darwin21.4";
            x86_64h_supported = true;
            i386_supported = false;
            arm_supported = true;
            osx_version_min = "10.9";
          };
        };
        packages.macossdk_13_0 = pkgs.fetchzip {
          url = "https://github.com/roblabla/MacOSX-SDKs/releases/download/13.0/MacOSX13.0.sdk.tar.xz";
          sha256 = "sha256-b47xXh/ZwdRpQVvS1m6z+HFfxktrn5iLspiL0dl46qk=";
          passthru = {
            version = "13.0";
            target = "darwin22.1";
            x86_64h_supported = true;
            i386_supported = false;
            arm_supported = true;
            osx_version_min = "10.13";
          };
        }; 
        packages.toolchain_11_3 = self.lib.toolchain { llvmPackages = pkgs.llvmPackages_14; osxcross-wrapper = selfpkgs.osxcross-wrapper; macos_sdk = selfpkgs.macossdk_11_3; cctools = selfpkgs.cctools; makeWrapper = pkgs.makeWrapper; runCommand = pkgs.runCommand; };
        packages.toolchain_12_3 = self.lib.toolchain { llvmPackages = pkgs.llvmPackages_14; osxcross-wrapper = selfpkgs.osxcross-wrapper; macos_sdk = selfpkgs.macossdk_12_3; cctools = selfpkgs.cctools; makeWrapper = pkgs.makeWrapper; runCommand = pkgs.runCommand; };
        packages.toolchain_13_0 = self.lib.toolchain { llvmPackages = pkgs.llvmPackages_14; osxcross-wrapper = selfpkgs.osxcross-wrapper; macos_sdk = selfpkgs.macossdk_13_0; cctools = selfpkgs.cctools; makeWrapper = pkgs.makeWrapper; runCommand = pkgs.runCommand; };
        packages.toolchain = selfpkgs.toolchain_11_3;
      });
}

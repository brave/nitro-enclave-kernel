{
  pkgs ? import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/refs/tags/23.05.tar.gz";
    sha256 = "sha256:10wn0l08j9lgqcw8177nh2ljrnxdrpri7bp0g7nvrsn9rkawvlbf";
  }) {}
}:
pkgs.stdenv.mkDerivation rec {
  pname = "nitro-enclaves-kernel";
  version = "5.10.199";

  nativeBuildInputs = with pkgs; [
    git
    gcc
    flex
    bison
    elfutils
    openssl
    bc
    perl
    gawk
  ];

  src = pkgs.fetchFromGitHub {
    owner = "gregkh";
    repo = "linux";
    rev = "v5.10.199";
    sha256 = "sha256-WzxToE1JiYf1t16I7I9Xbb/saUCz+9G+wtwl+CkAdZs=";
  };

  patches = [
    ./nsm.patch
  ];

  files = [
    ./bzImage.config
  ];

  configurePhase = ''
    ( cat $files; echo CONFIG_NSM=m ) > .config
  '';

  buildPhase = ''
    patchShebangs ./scripts/ld-version.sh
    make olddefconfig bzImage modules -j$(nproc)
  '';

  installPhase = ''
    mkdir $out
    cp arch/x86/boot/bzImage drivers/misc/nsm.ko $out/
  '';

  meta = {
    description = "Linux Kernel 5.10.199 for Nitro Enclaves";
    homepage = https://kernel.org;
    license = "gpl2Only";
  };
}

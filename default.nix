{
  pkgs ? import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/refs/tags/24.05.tar.gz";
    sha256 = "sha256:1lr1h35prqkd1mkmzriwlpvxcb34kmhc9dnr48gkm8hh089hifmx";
  }) {}
}:
pkgs.stdenv.mkDerivation rec {
  pname = "nitro-enclaves-kernel";
  version = "5.10.223";

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
    rev = "v5.10.223";
    sha256 = "sha256-AhLX383ZESWowtHTIJDaQXaIWSXylJCkL8XDlDJCacs=";
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
    description = "Linux Kernel 5.10.223 for Nitro Enclaves";
    homepage = https://kernel.org;
    license = "gpl2Only";
  };
}

# Build a u-boot kpart image for ARM ChromeOS devices

{ lib, pkgs, stdenv
, fetchurl
}:

let

  version = "2023.07.02";
  src = fetchurl {
    url = "https://ftp.denx.de/pub/u-boot/u-boot-${version}.tar.bz2";
    hash = "sha256-a2pIWBwUq7D5W9h8GvTXQJIkBte4AQAqn5Ryf93gIdU=";
  };

in

stdenv.mkDerivation {
  name = "u-boot-veyron-speedy";

  inherit src;

  nativeBuildInputs = with pkgs; [
    ubootTools
    gcc-arm-embedded-10
    dtc
    flex
    bison
    python3
    swig
    ncurses
    python3Packages.setuptools
    openssl
    cmake
    pkg-config
    vboot_reference
    bc
    which
  ];

  enableParallelBuilding = true;

  makeFlags = [
    "ARCH=arm"
    "CROSS_COMPILE=arm-none-eabi-"
  ];

  configurePhase = ''
    runHook preConfigure

    make chromebook_speedy_defconfig

    runHook postConfigure
  '';

  installPhase = ''
    runHook preInstall

    ln -s u-boot.bin "$out"

    runHook postInstall
  '';

  dontStrip = true;

}

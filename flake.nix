{
  description = "Build u-boot for veyron-speedy";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      pkgs = (import nixpkgs) {
        system = "x86_64-linux";
      };
      plat = pkgs.pkgsCross.arm-embedded;
      ubootVersion = "2024.01-rc5";
      ubootSrc = pkgs.fetchurl {
        url = "https://ftp.denx.de/pub/u-boot/u-boot-${ubootVersion}.tar.bz2";
        hash = "sha256-X8jsKGWHEYrCqOnqEvXhn4EFhHBSQopVGvG+dy4Xsc0=";
      };
    in
    {
      bin.speedy = plat.buildUBoot {
        version = ubootVersion;
        src = ubootSrc;
        defconfig = "chromebook_speedy_defconfig";
        extraConfig = ''
          CONFIG_TEXT_BASE=0x02000100
          CONFIG_BOOTDELAY=-2
          CONFIG_BOOTCOMMAND="bootflow scan; reset"
          CONFIG_SKIP_LOWLEVEL_INIT=y
          CONFIG_BOARD_EARLY_INIT_R=n
          CONFIG_CONSOLE_TRUETYPE=n
          CONFIG_LEGACY_IMAGE_FORMAT=n
          CONFIG_BOOTSTD_DEFAULTS=n
          CONFIG_NET=n
          CONFIG_BOOTMETH_EFILOADER=y
          CONFIG_VIDEO_LOGO=n
        '';
        extraMeta.platforms = ["arm-none"];
        patches = [];
        extraMakeFlags = [ "DTC=${pkgs.dtc}/bin/dtc" ];
        filesToInstall = [ "u-boot.bin" "u-boot.dtb" ];
      };
      bin.speedy-kpart = pkgs.callPackage ./u-boot-kpart.nix {
        kernel = (self.bin.speedy + "/u-boot.bin");
        devicetree = (self.bin.speedy + "/u-boot.dtb");
      };
    };
}

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
      packages.x86_64-linux.ubootVeyronSpeedy = plat.buildUBoot {
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
        extraMakeFlags = [ "DTC=${pkgs.dtc}/bin/dtc" ];
        patches = [];
        filesToInstall = [ "u-boot-rockchip-spi.bin" "u-boot.kpart" ];
        postBuild = ''
          cp '${./image.its}' uboot.its
          '${pkgs.ubootTools}/bin/mkimage' -f uboot.its u-boot-dtb.img
          echo -e "\n" > dummy_config
          echo -e "\n" > dummy_bootloader
          '${pkgs.vboot_reference}/bin/vbutil_kernel' \
            --pack u-boot.kpart \
            --keyblock '${pkgs.vboot_reference + "/share/vboot/devkeys/kernel.keyblock"}' \
            --signprivate '${pkgs.vboot_reference + "/share/vboot/devkeys/kernel_data_key.vbprivk"}' \
            --version 1 \
            --arch arm \
            --config dummy_config \
            --bootloader dummy_bootloader \
            --vmlinuz u-boot-dtb.img
        '';
      };
    };
}

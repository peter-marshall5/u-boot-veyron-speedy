{
  description = "Build u-boot for veyron-speedy";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      pkgs = (import nixpkgs) {
        system = "x86_64-linux";
      };
      plat = pkgs.pkgsCross.armv7l-hf-multiplatform;
    in
    {
      bin.speedy = plat.buildUBoot {
        defconfig = "chromebook_speedy_defconfig";
        extraMeta.platforms = [ "armv7l-linux" ];
        extraConfig = ''
          CONFIG_TEXT_BASE=0x02000100
          CONFIG_BOOTDELAY=-2
          CONFIG_BOOTCOMMAND="bootflow scan; reset"
          CONFIG_SKIP_LOWLEVEL_INIT=y
          CONFIG_EFI_LOADER=y
          CONFIG_CONSOLE_TRUETYPE=n
        '';
        filesToInstall = [ "u-boot.bin" "u-boot.dtb" ];
      };
      bin.speedy-kpart = pkgs.callPackage ./u-boot-kpart.nix {
        kernel = (self.bin.speedy + "/u-boot.bin");
        devicetree = (self.bin.speedy + "/u-boot.dtb");
      };
    };
}

# Create a kpart image for ARM ChromeOS devices

{ lib, stdenv
, vboot_reference
, ubootTools
, dtc
, kernel
, devicetree
, keyblock ? (vboot_reference + "/share/vboot/devkeys/kernel.keyblock")
, signprivate ? (vboot_reference + "/share/vboot/devkeys/kernel_data_key.vbprivk")
}:

stdenv.mkDerivation {
  name = "u-boot-dtb-chromium.kpart";

  nativeBuildInputs = [
      vboot_reference
      ubootTools
      dtc
    ];

  buildCommand = ''
    cat "${kernel}" > u-boot.bin
    cat "${devicetree}" > u-boot.dtb
    cp "${./image.its}" image.its

    ${ubootTools}/bin/mkimage -f image.its u-boot-dtb.img

    echo -e "\n" > dummy_config
    echo -e "\n" > dummy_bootloader

    ${vboot_reference}/bin/vbutil_kernel \
      --pack "$out" \
      --keyblock "${keyblock}" \
      --signprivate "${signprivate}" \
      --version 1 \
      --arch arm \
      --config dummy_config \
      --bootloader dummy_bootloader \
      --vmlinuz u-boot-dtb.img
  '';
}

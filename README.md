# U-Boot package for veyron speedy boards

## Chromium chainload image

This is the file `u-boot.kpart`. It can be flashed to a Chrome OS kernel partition on an external device or even on internal storage, and booted with developer mode enabled.

See [Running U-Boot from coreboot on Chromebooks](https://docs.u-boot.org/en/latest/chromium/chainload.html#coreboot).

## SPI flash image

This is the file `u-boot-spi-rockchip.bin`. It can be flashed to the beginning of the SPI ROM.

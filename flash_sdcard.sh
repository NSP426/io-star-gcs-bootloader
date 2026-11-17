#!/bin/sh

dd if=./result/imx-boot-sd.bin of=/dev/sda bs=1K seek=33 conv=fsync

#!/bin/sh

CONTAINER_ID=$(podman-compose ps -q)

podman cp $CONTAINER_ID:/workspace/u-boot/imx-boot-tools/imx-boot-sd.bin ./result/
podman cp $CONTAINER_ID:/workspace/u-boot/.config ./result/u-boot.config

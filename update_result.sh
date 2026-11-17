#!/bin/sh

CONTAINER_ID=$(podman-compose ps -q)
TARGET_DIR="./result"

mkdir -p $TARGET_DIR
podman cp $CONTAINER_ID:/workspace/u-boot/imx-boot-tools/imx-boot-sd.bin $TARGET_DIR/
podman cp $CONTAINER_ID:/workspace/u-boot/.config $TARGET_DIR/u-boot.config

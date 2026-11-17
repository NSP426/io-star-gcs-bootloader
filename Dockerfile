FROM debian:trixie-slim

RUN apt-get update \
   && apt-get install -y --no-install-recommends \
      build-essential \
      bison \
      flex \
      wget \
      gcc-aarch64-linux-gnu \
      g++-aarch64-linux-gnu \
      binutils-aarch64-linux-gnu \
      git \
      device-tree-compiler \
      libssl-dev \
      openssl \
      ca-certificates \
      expect \
      zlib1g-dev \
      bc \
      u-boot-tools \
      libncurses-dev \
    && rm -rf /var/lib/apt/lists/*

ENV ARCH=arm64
ENV CROSS_COMPILE=aarch64-linux-gnu-

ARG UBOOT_PATH="u-boot"
ARG IMX_BOOT_TOOLS="${UBOOT_PATH}/imx-boot-tools"
ARG FIRMWARE_IMX="${IMX_BOOT_TOOLS}/firmware-imx-8.26-d4c33ab"
ARG IMX_MKIMAGE="${IMX_BOOT_TOOLS}/imx-mkimage"
ARG IMX_ATF="${IMX_BOOT_TOOLS}/imx-atf"
ARG RESULT_DIR="result"

LABEL org.opencontainers.image.vendor="Drotek" \
      org.opencontainers.image.title="Bootloader" \
      org.opencontainers.image.description="io-star-gcs bootloader" \
      org.opencontainers.image.url="https://registry.drotek.com/io-star-gcs-bootloader"

WORKDIR /workspace

COPY cache/uboot-imx ./${UBOOT_PATH}
COPY configs/u-boot.config ./${UBOOT_PATH}/.config

RUN cd ${UBOOT_PATH} \
# && make imx8mm_var_dart_defconfig \
   && make -j$(nproc)

COPY cache/imx-boot-tools ${IMX_BOOT_TOOLS}

RUN cp ${FIRMWARE_IMX}/firmware/ddr/synopsys/* \
   ${IMX_BOOT_TOOLS}

RUN cd ${IMX_MKIMAGE} \
   && cp iMX8M/soc.mak iMX8M/*.c iMX8M/*.sh scripts/*.sh .. \
   && cp scripts/dtb_check.sh ../../scripts/.

RUN cd ${IMX_BOOT_TOOLS} \
   && cp ../tools/mkimage mkimage_uboot \
   && cp ../u-boot.bin . \
   && cp ../u-boot-nodtb.bin \
      ../spl/u-boot-spl.bin \
      ../arch/arm/dts/imx8mm-var-dart-dt8mcustomboard.dtb \
      ../arch/arm/dts/imx8mm-var-som-symphony.dtb  \
      .

RUN cd ${IMX_ATF} \
   && unset LDFLAGS \
   && make PLAT=imx8mm bl31 \
   && cp build/imx8mm/release/bl31.bin ..

RUN cd ${IMX_BOOT_TOOLS} \
   && make -f soc.mak clean \
   && make -f soc.mak \
      SOC=iMX8MM \
      SOC_DIR=imx-boot-tools \
      dtbs="imx8mm-var-dart-dt8mcustomboard.dtb imx8mm-var-som-symphony.dtb" \
      MKIMG=./mkimage_imx8 \
      PAD_IMAGE=./pad_image.sh \
      CC=gcc \
      OUTIMG=imx-boot-sd.bin \
      flash_lpddr4_ddr4_evk

CMD ["tail", "-f", "/dev/null"]

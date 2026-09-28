# Build μsk / PicoFly firmware
#   docker build -t usk .
#   docker run --rm -v "$PWD/out:/export" usk

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PICO_SDK_PATH=/opt/pico-sdk
ENV CMAKE_POLICY_VERSION_MINIMUM=3.5

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    cmake \
    gcc-arm-none-eabi \
    git \
    libnewlib-arm-none-eabi \
    libstdc++-arm-none-eabi-newlib \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Pico SDK 2.0.0 (same major as build.sh)
RUN git clone --depth 1 --branch 2.0.0 \
        https://github.com/raspberrypi/pico-sdk.git "${PICO_SDK_PATH}" \
    && cd "${PICO_SDK_PATH}" \
    && git submodule update --init --depth 1

# Build busk bootloader (needs a temporary RAM layout patch)
RUN git clone --depth 1 https://github.com/rehius/busk.git /tmp/busk \
    && ln -sf "${PICO_SDK_PATH}/external/pico_sdk_import.cmake" /tmp/busk/pico_sdk_import.cmake \
    && MEMMAP="${PICO_SDK_PATH}/src/rp2_common/pico_crt0/rp2040/memmap_default.ld" \
    && cp "${MEMMAP}" "${MEMMAP}.bak" \
    && sed -i 's/RAM(rwx) : ORIGIN =  0x20000000, LENGTH = 256k/RAM(rwx) : ORIGIN = 0x20038000, LENGTH = 32k/g' "${MEMMAP}" \
    && mkdir -p /tmp/busk-build \
    && cd /tmp/busk-build \
    && cmake /tmp/busk \
    && make -j"$(nproc)" \
    && cp busk.bin /opt/busk.bin \
    && mv "${MEMMAP}.bak" "${MEMMAP}" \
    && rm -rf /tmp/busk /tmp/busk-build

WORKDIR /src
COPY . .

RUN mkdir -p busk generated build out \
    && cp /opt/busk.bin busk/busk.bin \
    && cd build \
    && cmake .. \
    && make -j"$(nproc)" \
    && python3 ../prepare.py \
    && cp firmware.uf2 update.bin ../out/

# Mount a host dir at /export to get the artifacts out
CMD ["sh", "-c", "mkdir -p /export && cp -v /src/out/firmware.uf2 /src/out/update.bin /export/"]

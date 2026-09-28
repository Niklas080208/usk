#!/bin/bash
set -e
cd "$(dirname "$0")"
export PICO_SDK_PATH="$HOME/pico-sdk-2.0.0"
export CMAKE_POLICY_VERSION_MINIMUM=3.5
mkdir -p build
cd build
cmake ..
make -j
python3 ../prepare.py
mkdir -p ../out
cp firmware.uf2 update.bin ../out/

#!/bin/bash

## Download OSS modules from the official GitHub.
git clone https://github.com/NVIDIA/open-gpu-kernel-modules.git
cd open-gpu-kernel-modules

## Install kernel dev -- Note you must be using Kernel 6.8+
doas apk add linux-edge linux-edge-dev
doas apk remove linux-lts linux-lts-dev

## Build modules
make modules -j$(nproc)
make modules_install -j$(nproc)

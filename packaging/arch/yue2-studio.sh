#!/bin/sh
# WebKitGTK's DMA-BUF renderer dies with "Error 71 (Protocol error)" on Wayland
# with NVIDIA; the variable can still be overridden from the environment.
export WEBKIT_DISABLE_DMABUF_RENDERER="${WEBKIT_DISABLE_DMABUF_RENDERER:-1}"
# The CUDA trainer and captioner built with the package; they need the
# system's CUDA 13.
tools="/usr/lib/YuE2 Studio/resources/music-train"
if [ -e /opt/cuda/lib64/libcublas.so.13 ]; then
    export YUE_TRAIN_BIN="${YUE_TRAIN_BIN:-$tools/music-train}"
    export YUE_CAPTION_BIN="${YUE_CAPTION_BIN:-$tools/ace-caption}"
fi
exec "/usr/lib/YuE2 Studio/YuE2-Studio" "$@"

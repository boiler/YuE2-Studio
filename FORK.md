# YuE2 Studio — Linux fork

This is a fork of [timoncool/YuE2-Studio](https://github.com/timoncool/YuE2-Studio)
that makes the studio work fully on Linux and packages it for Arch.

- `main` mirrors upstream and carries nothing of its own.
- `linux` is upstream's release tag plus the commits below; it is rebased
  onto each new upstream release, and commits upstream has taken drop out.
- `vX.Y.Z-linux.N` tags mark the states the Arch package is built from.

## What differs from upstream

### LoRA training on Linux

Upstream ships the trainer (`music-train`) and the captioner (`ace-caption`)
for Windows only, and the studio refuses to train anywhere but Windows.
This fork:

- lets the trainer checks see the card's CUDA build on every platform
  (`card_cuda`), while the engine keeps computing on Vulkan;
- skips the downloaded cuBLAS check off Windows, where the trainer links the
  system's CUDA;
- builds HOT-Step's `ace-train` and `ace-caption` from the commit upstream
  pins (`engines/music-train-source.json`) against the system CUDA 13 and
  ships them in the package, found through `YUE_TRAIN_BIN` /
  `YUE_CAPTION_BIN`.

Reported upstream as
[#126](https://github.com/timoncool/YuE2-Studio/issues/126).

### "Show in folder" on Linux and macOS

The Files panel started `explorer.exe` on every platform. On Linux it now
uses the freedesktop `FileManager1` D-Bus interface (the file opens
selected) with `xdg-open` as the fallback, and `open -R` on macOS.
Reported upstream as
[#125](https://github.com/timoncool/YuE2-Studio/issues/125); upstream has
taken it for its next version.

### Arch package

[`packaging/arch`](packaging/arch) builds the whole studio from source:

- the Tauri shell and the music server, with the commits above;
- the yue2.cpp engine on Vulkan and the audio-to-MIDI transcriber, from the
  commits upstream pins in `engines/*-source.json`;
- the CUDA trainer and captioner (built for the build machine's card,
  `_cuda_arch=native` by default).

The launcher sets `WEBKIT_DISABLE_DMABUF_RENDERER=1`: WebKitGTK's DMA-BUF
renderer dies with "Error 71 (Protocol error)" on Wayland with NVIDIA.

```sh
cd packaging/arch
makepkg -si
```

Needs `cuda` to build, and at run time for training; a Vulkan driver for
generation.

## Notes

- Prefer the BF16 backbone over Q8 if the card has the memory: the GGUF
  holds the decoder as well as the planner, and Q8 leaves audible
  high-frequency artefacts that BF16 does not.

## Credits

All the studio is upstream's work, by Ilya Timonin and the projects it
credits. The Linux changes and the package in this fork were made with
[Claude](https://claude.com/claude-code) (Anthropic's Claude Code).

License: MIT, as upstream.

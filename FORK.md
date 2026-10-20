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

### The engine on CUDA

Upstream's Linux package computes on Vulkan whatever the card. The Windows
release keeps ggml's CUDA backend in `cuda12/` / `cuda13/` beside the engine
and hands the right one to it; this fork does the same on Linux:

- the package builds the CUDA backend module from the same yue2.cpp commit
  against the system CUDA 13 and puts it in `yue2-cpp/cuda13/`;
- the studio turns CUDA on off Windows only when the card runs CUDA 13 and
  that module is there, and fetches no cuBLAS (the module links the
  system's); without the module it stays on Vulkan as before.

On an RTX 4080 SUPER this generated a 60 s clip in 28.5 s instead of 59.9 s
on Vulkan (BF16 backbone), and drops the FP16 clamp the studio needs on
Vulkan.

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
- the yue2.cpp engine on Vulkan with its CUDA backend, and the audio-to-MIDI
  transcriber, from the commits upstream pins in `engines/*-source.json`;
- the CUDA trainer and captioner.

CUDA code is built for the build machine's card (`_cuda_arch=native`);
set `_cuda_arch` (e.g. `"75-real;86-real;89-real"`) to build for others.

The launcher sets `WEBKIT_DISABLE_DMABUF_RENDERER=1`: WebKitGTK's DMA-BUF
renderer dies with "Error 71 (Protocol error)" on Wayland with NVIDIA.

```sh
cd packaging/arch
makepkg -si
```

Depends on `cuda` (the engine's CUDA backend, the trainer and the captioner
link it); cards without CUDA 13 generate on Vulkan.

## Notes

- In Settings → Engine keep the backend on Auto or CUDA. A start that once
  fails under Auto makes the studio compute on the processor for the rest of
  the session; choosing CUDA explicitly avoids that.
- "Keep models loaded" saves reloading the decoder before every song (about
  5 s on CUDA, 18 s on Vulkan) if the card has the memory.
- Prefer the BF16 backbone over Q8 if the card has the memory: the GGUF
  holds the decoder as well as the planner, and Q8 leaves audible
  high-frequency artefacts that BF16 does not.

## Credits

All the studio is upstream's work, by Ilya Timonin and the projects it
credits. The Linux changes and the package in this fork were made with
[Claude](https://claude.com/claude-code) (Anthropic's Claude Code).

License: MIT, as upstream.

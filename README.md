# Alternative Remote Control ComposiTV Operating System

This repository contains a Nix flake for building a base system image and updates.

The compositor is Niri, with nearly the default keybindings.
The vi-style keybindings are removed, Mod+K toggles the on-screen keyboard.

TODO: mapping remote buttons to keyboard and mouse input

## How to Build the System Image

You need [Nix](https://nixos.org/) with enabled
[Flakes](https://wiki.nixos.org/wiki/Flakes). After that, you can
build the disk image:

```console
$ nix build .
```

After the build process, there will be a QEMU disk image `disk.qcow2`
in `result/`.

## Running the System

Use `qemu-img` on a live system to extract the image onto `/dev/sda` of the target hardware:
(The target disk currently *must* be `/dev/sda` due to hardcoded device paths.)
```console
$ qemu-img convert -f qcow2 -O raw /path/to/disk.qcow2 /dev/sda
```

## Updating the System

```console
$ nix build .#ctv_update
```

Switch to a different VT on the running system (try Ctrl+Alt+F2), which should log in as root automatically.
The update files should be copied to `/var/updates`, or you can mount an external drive there with the files.

(The prompt string is set to `$? > `, which usually looks like `0 > `)
```console
0 > systemd-sysupdate update
```

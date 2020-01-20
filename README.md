# libmcserverstatus

C library for Minecraft server status

## Status

Currently the project produces a testing binary which gets the raw JSON for a server at `127.0.0.1`.

## Building

### Unix

1. Run `make`
2. Run the binary `mcserverstatus`.

### Windows

Windows support is currently missing because `inet_pton` (method converting address to binary form) is missing and is essential to creating a TCP request. Windows support is important and will be in the final version.
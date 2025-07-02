# sf

A tool like unix find command utility but simpler. It does not support
regex and it strictly search for the exact file name. It does not have
support to search for directory, only files.

## Installation

You could build it from source. see **Build** section. Otherwise you
could also download the binary executable.

## Build
**Requirements**:
- [zig](https://ziglang.org/download/)

Run
```
zig build-exe sf.zig
```

## TODO
- [ ] Add support for regex

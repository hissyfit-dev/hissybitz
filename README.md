# hissybitz

Bits and bobs. Utility functions and structures for Zig.
Enjoy, or my cat may hiss at you.

Utility functions and structures:
- [ULID](https://github.com/ulid/spec) (Universally Unique Lexicographically Sortable Identifiers)
    - `Ulid` type
    - `Ulid` generator
- Out-of-the-box log output friendly to cloud deployments (EKS, LOKI, etc) and log scrapers
- Thread-safe (where relevant), yet performant with efficient resource usage

Non-goals:
- Do everything (loading config from various sources, dynamic-whathaveyou, etc)
- Become baggage-laden (dependencies on everything else out there)

These are early days, and the feature set will grow, bugs will be found and fixed.

## Overview

So far, these bits and bobs are provided:
- `Ulid` struct and `Generator`.
    - The `Ulid` struct is packed such that it is trivially bit-castable to `u128` or `[16]u8`.
    - Maintains monotonic sort order (correctly detects and handles the same millisecond) per `generator`.

## Getting Started
---

### Fetch the package

Let zig fetch the package and integrate it into your `build.zig.zon` automagically:

```shell
zig fetch --save https://github.com/hissyfit-dev/hissybitz/archive/refs/tags/v0.0.1.tar.gz
```

### Integrate into your build

Add dependency import in `build.zig`:

```zig
    const hissybitz = b.dependency("hissybitz", .{
        .target = target,
        .optimize = optimize,
    });

    // .
    // .
    // .
    lib.root_module.addImport("hissybitz", hissybitz.module("hissybitz"));
    // .
    // .
    // .
    exe.root_module.addImport("hissybitz", hissybitz.module("hissybitz"));
    // .
    // .
    // .
    lib_unit_tests.addImport("hissybitz", hissybitz.module("hissybitz"));
    // .
    // .
    // .

```


## Usage

### ULID support

Simply create a ULID generator (call `hissybitz.ulid.generator()`), and each call to `generator.next()` will yield a new `Ulid`.

There are various conversion methods, allocating decoders etc. Peek around.

### Example

```zig

const hissybitz = @import("hissybitz");
const ulid = hissybitz.ulid;

pub fn main() !void {

    var gen = ulid.generator();

    const ulid_0 = try gen.next();
    const ulid_1 = try gen.next();

    const str = ulid_0.encode();
    const ulid_from_str = try ulid.decode(&str);

    const bytes = ulid_0.bytes();
    const ulid_from_bytes = try ulid.fromBytes(&bytes);

}
```

## Dependencies

### `hissylogz`

This module uses [`hissylogz`](https://github.com/hissyfit-dev/hissylogz) for logging in tests and benchmarks.

## Acknowledgements

I re-purposed bits lifted from [ulid-zig](https://github.com/rsepassi/ulid-zig) under 0BSD. This is a solid library and comes with plenty of bells and whistles, a nice C ABI, the works.
I've added known error sets, and a heavily trimmed down, restructured API.

## License

This project is licensed under the [MIT License](./LICENSE.md).

## Project status

*Active*.

---
hissybitz.

(c) 2024 Kevin Poalses

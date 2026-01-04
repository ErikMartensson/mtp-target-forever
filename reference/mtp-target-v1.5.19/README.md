# MTP Target v1.5.19 - Reference Only

**DO NOT EDIT THESE FILES.**

This is the last official release of MTP Target (September 2008), preserved here for reference. The active codebase in this repository is based on **v1.2.2a**, which is an earlier version.

## Source

Downloaded from the Internet Archive:
https://web.archive.org/web/20130630212354/http://www.mtp-target.org/files/mtp-target-src.19.tar.bz2

Original website (archived):
https://web.archive.org/web/20130630212354/http://www.mtp-target.org/

## Contents

| Directory | Description |
|-----------|-------------|
| `client/` | Client source code with v1.5.19 features |
| `common/` | Shared code between client and server |
| `data/` | Game assets (levels, shapes, textures, sounds, lua scripts) |

**Note:** This archive contains **client source only**. There is no server source code in v1.5.19.

## Use Cases

- **Comparing code** - Understand what changed between v1.2.2a and v1.5.19
- **Extracting assets** - The `data/` folder contains shapes and textures for space/sun/city themes that are missing from the v1.2.2a build
- **Porting features** - Reference implementation for features added after v1.2.2a

## Asset Locations

Potentially useful assets for fixing unavailable levels:

| Asset Type | Path |
|------------|------|
| 3D Models | `data/shape/` |
| Textures | `data/texture/` |
| Levels | `data/level/` |
| Lua Scripts | `data/lua/` |

## Why v1.2.2a?

The v1.2.2a codebase was chosen as the base because:
1. It includes both client AND server source code
2. It builds successfully against modern Ryzom Core/NeL libraries
3. The v1.5.19 release only contains client code

The goal is to port useful features and assets from v1.5.19 into the working v1.2.2a codebase.

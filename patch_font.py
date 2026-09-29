#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
QIDI Client Ubuntu Mono Vietnamese Font Patcher
Applies 190 anti-aliased typographic glyphs across all 4 font sizes safely via atomic replace.
"""
import sys
import os
import struct
import shutil

TARGET_BIN = "/home/qidi/QIDI_Client/bin/qidiclient"
BACKUP_BIN = "/home/qidi/QIDI_Client/bin/qidiclient.original"
TMP_BIN    = "/home/qidi/QIDI_Client/bin/qidiclient.tmp"
PATCH_DATA = os.path.join(os.path.dirname(os.path.abspath(__file__)), "font_patches.bin")

def main():
    if not os.path.exists(TARGET_BIN):
        print(f"[!] Error: Target binary not found: {TARGET_BIN}")
        sys.exit(1)

    if not os.path.exists(PATCH_DATA):
        print(f"[!] Error: Patch data not found: {PATCH_DATA}")
        sys.exit(1)

    # 1. Backup if not already backed up
    if not os.path.exists(BACKUP_BIN):
        print(f"[*] Creating factory backup: {BACKUP_BIN}...")
        shutil.copyfile(TARGET_BIN, BACKUP_BIN)
    else:
        print(f"[+] Factory backup already exists at {BACKUP_BIN}")

    # 2. Always base new patched binary on pristine backup to ensure clean state
    source_bin = BACKUP_BIN if os.path.exists(BACKUP_BIN) else TARGET_BIN
    print(f"[*] Preparing temporary binary from {source_bin}...")
    shutil.copyfile(source_bin, TMP_BIN)

    # 3. Apply patches to TMP_BIN
    print(f"[*] Applying Ubuntu Mono Vietnamese font patches...")
    with open(PATCH_DATA, "rb") as pf:
        num_records = struct.unpack("<I", pf.read(4))[0]
        print(f"[*] Total patch segments: {num_records}")

        with open(TMP_BIN, "r+b") as bf:
            for i in range(num_records):
                off, dlen = struct.unpack("<II", pf.read(8))
                pdata = pf.read(dlen)
                bf.seek(off)
                bf.write(pdata)

    os.chmod(TMP_BIN, 0o755)

    # 4. Atomic replace
    shutil.move(TMP_BIN, TARGET_BIN)
    os.chmod(TARGET_BIN, 0o755)
    print(f"[SUCCESS] Patched {num_records} font records into {TARGET_BIN}!")

if __name__ == "__main__":
    main()

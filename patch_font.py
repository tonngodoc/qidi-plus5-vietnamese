#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
QIDI Plus 5 Ubuntu Mono Vietnamese Font Patcher
Applies 190 anti-aliased typographic glyphs safely via atomic replace with strict hardware compatibility checks.
"""
import sys
import os
import struct
import shutil
import hashlib

TARGET_BIN = "/home/qidi/QIDI_Client/bin/qidiclient"
BACKUP_BIN = "/home/qidi/QIDI_Client/bin/qidiclient.original"
TMP_BIN    = "/home/qidi/QIDI_Client/bin/qidiclient.tmp"
PATCH_DATA = os.path.join(os.path.dirname(os.path.abspath(__file__)), "font_patches.bin")

# Strict compatibility signatures (QIDI Plus 5 only)
EXPECTED_SIZE = 90312400
EXPECTED_ORIG_MD5 = "dfe9db00a13e40cf08d8a376d09a9aca"
MAGIC_STRING_OFF = 0x541c490

def main():
    if not os.path.exists(TARGET_BIN):
        print(f"[!] Lỗi: Không tìm thấy file {TARGET_BIN}")
        sys.exit(1)

    if not os.path.exists(PATCH_DATA):
        print(f"[!] Lỗi: Không tìm thấy dữ liệu bản vá {PATCH_DATA}")
        sys.exit(1)

    # 1. Hardware & Build Compatibility Check
    target_size = os.path.getsize(TARGET_BIN)
    if os.path.exists(BACKUP_BIN):
        source_bin = BACKUP_BIN
        source_size = os.path.getsize(BACKUP_BIN)
    else:
        source_bin = TARGET_BIN
        source_size = target_size

    if source_size != EXPECTED_SIZE:
        print(f"[!] CẢNH BÁO TƯƠNG THÍCH: File qidiclient có dung lượng {source_size} bytes (yêu cầu đúng {EXPECTED_SIZE} bytes)!")
        print("[!] Bản vá này chỉ dành riêng cho dòng máy QIDI Plus 5 đúng phiên bản build.")
        print("[!] Đã hủy bỏ thao tác vá để chống hỏng hóc hoặc đen màn hình.")
        sys.exit(1)

    # Check magic signature at offset
    with open(source_bin, "rb") as f:
        f.seek(MAGIC_STRING_OFF)
        sig = f.read(19)
        if not (sig.startswith(b"Qu\xe1\xba\xa1t th\xc3\xb4ng gi\xc3\xb3") or sig.startswith(b"Qu\xe1\xba\xa1t\x00")):
            print("[!] CẢNH BÁO TƯƠNG THÍCH: Chữ ký nhị phân tại offset 0x541c490 không khớp!")
            print("[!] Bản vá nhị phân không tương thích với firmware máy này. Hủy bỏ an toàn.")
            sys.exit(1)

    # 2. Backup factory binary if not present
    if not os.path.exists(BACKUP_BIN):
        print(f"[*] Tạo bản sao lưu nguyên bản nhà máy: {BACKUP_BIN}...")
        shutil.copyfile(TARGET_BIN, BACKUP_BIN)
    else:
        print(f"[+] Bản sao lưu nguyên bản đã có sẵn tại {BACKUP_BIN}")

    # 3. Prepare temporary binary from pristine backup
    print(f"[*] Đang chuẩn bị tệp nhị phân tạm thời...")
    shutil.copyfile(BACKUP_BIN, TMP_BIN)

    # 4. Apply patches to TMP_BIN
    print(f"[*] Đang nạp bản vá font Ubuntu Mono Tiếng Việt (190 ký tự)...")
    with open(PATCH_DATA, "rb") as pf:
        num_records = struct.unpack("<I", pf.read(4))[0]
        print(f"[*] Tổng số phân đoạn vá: {num_records}")

        with open(TMP_BIN, "r+b") as bf:
            for i in range(num_records):
                off, dlen = struct.unpack("<II", pf.read(8))
                pdata = pf.read(dlen)
                bf.seek(off)
                bf.write(pdata)

    os.chmod(TMP_BIN, 0o755)

    # 5. Atomic replace
    shutil.move(TMP_BIN, TARGET_BIN)
    os.chmod(TARGET_BIN, 0o755)
    print(f"[THÀNH CÔNG] Đã vá thành công {num_records} mục font vào {TARGET_BIN}!")

if __name__ == "__main__":
    main()

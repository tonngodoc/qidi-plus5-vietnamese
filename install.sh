#!/usr/bin/env bash
# ==============================================================================
# QIDI Plus 5 - Gói Cài Đặt Tiếng Việt (Font Ubuntu Mono Typography)
# ==============================================================================

set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}======================================================${NC}"
echo -e "${GREEN}   CÀI ĐẶT FONT TIẾNG VIỆT CHO MÁY IN QIDI PLUS 5     ${NC}"
echo -e "${CYAN}======================================================${NC}"

TARGET_BIN="/home/qidi/QIDI_Client/bin/qidiclient"
BACKUP_BIN="/home/qidi/QIDI_Client/bin/qidiclient.original"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Kiểm tra môi trường & Tương thích phần cứng
if [ ! -f "$TARGET_BIN" ]; then
    echo -e "${RED}[!] Không tìm thấy tệp $TARGET_BIN trên hệ thống!${NC}"
    echo -e "${RED}[!] Vui lòng đảm bảo bạn đang chạy script này trên máy in QIDI Plus 5.${NC}"
    exit 1
fi

CHECK_BIN="$TARGET_BIN"
if [ -f "$BACKUP_BIN" ]; then
    CHECK_BIN="$BACKUP_BIN"
fi

BIN_SIZE=$(stat -c%s "$CHECK_BIN" 2>/dev/null || echo 0)
if [ "$BIN_SIZE" != "90312400" ]; then
    echo -e "${RED}[!] CẢNH BÁO TƯƠNG THÍCH: Kích thước file ($BIN_SIZE bytes) không khớp với QIDI Plus 5 (90312400 bytes)!${NC}"
    echo -e "${RED}[!] Bản vá nhị phân này chỉ dành riêng cho dòng máy QIDI Plus 5.${NC}"
    echo -e "${RED}[!] Hủy bỏ cài đặt ngay lập tức để chống đen màn hình.${NC}"
    exit 1
fi

# Hỗ trợ chạy trực tiếp qua: curl -sSL ... | bash
if [ ! -f "$SCRIPT_DIR/font_patches.bin" ]; then
    TMP_DIR="/tmp/qidi_vn_install"
    mkdir -p "$TMP_DIR"
    echo -e "${YELLOW}[*] Đang tải các tệp bản vá tiếng Việt từ GitHub...${NC}"
    BASE_URL="https://raw.githubusercontent.com/tonngodoc/qidi-plus5-vietnamese/main"
    curl -sSL "$BASE_URL/patch_font.py" -o "$TMP_DIR/patch_font.py"
    curl -sSL "$BASE_URL/font_patches.bin" -o "$TMP_DIR/font_patches.bin"
    curl -sSL "$BASE_URL/uninstall.sh" -o "/home/qidi/uninstall_vietnamese.sh"
    chmod +x "/home/qidi/uninstall_vietnamese.sh"
    SCRIPT_DIR="$TMP_DIR"
fi

echo -e "${YELLOW}[1/4] Đang tạm dừng dịch vụ giao diện màn hình (qidi-client)...${NC}"
echo qiditech | sudo -S systemctl stop qidi-client 2>/dev/null || true
sleep 1

echo -e "${YELLOW}[2/4] Đang áp dụng bản vá 190 ký tự font Ubuntu Mono sắc nét...${NC}"
python3 "$SCRIPT_DIR/patch_font.py"

echo -e "${YELLOW}[3/4] Đang thiết lập cấu hình ngôn ngữ Tiếng Việt...${NC}"
if [ -f "/home/qidi/printer_data/database/moonraker-sql.db" ]; then
    python3 -c "
import sqlite3
try:
    db = sqlite3.connect('/home/qidi/printer_data/database/moonraker-sql.db')
    cur = db.cursor()
    cur.execute(\"SELECT 1 FROM config WHERE section='general' AND key='language'\")
    if cur.fetchone():
        db.execute(\"UPDATE config SET value='ru_RU' WHERE section='general' AND key='language'\")
    else:
        db.execute(\"INSERT INTO config (section, key, value) VALUES ('general', 'language', 'ru_RU')\")
    db.commit()
    print('    -> Đã cập nhật cấu hình ngôn ngữ Tiếng Việt vào Moonraker.')
except Exception as e:
    print('    -> Bỏ qua thiết lập database:', e)
" 2>/dev/null || true
fi

echo -e "${YELLOW}[4/4] Đang khởi động lại giao diện màn hình...${NC}"
echo qiditech | sudo -S systemctl start qidi-client

echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}   CÀI ĐẶT THÀNH CÔNG! MÀN HÌNH ĐÃ SẴN SÀNG TIẾNG VIỆT ${NC}"
echo -e "${CYAN}   - Thiết bị: QIDI Plus 5${NC}"
echo -e "${CYAN}   - Font chữ: Ubuntu Mono Typography (Khử răng cưa 4-bpp)${NC}"
echo -e "${CYAN}   - Bản sao lưu gốc an toàn: $BACKUP_BIN${NC}"
echo -e "${CYAN}   - Khôi phục gốc bất cứ lúc nào: bash /home/qidi/uninstall_vietnamese.sh${NC}"
echo -e "${GREEN}======================================================${NC}"

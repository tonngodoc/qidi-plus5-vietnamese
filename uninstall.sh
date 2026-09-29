#!/usr/bin/env bash
# ==============================================================================
# QIDI Plus 5 (Bản Nội Địa) - Gỡ Cài Đặt (Khôi Phục Gốc Factory)
# ==============================================================================

set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

TARGET_BIN="/home/qidi/QIDI_Client/bin/qidiclient"
BACKUP_BIN="/home/qidi/QIDI_Client/bin/qidiclient.original"

echo -e "${CYAN}======================================================${NC}"
echo -e "${YELLOW}   KHÔI PHỤC FONT MẶC ĐỊNH GỐC CỦA NHÀ SẢN XUẤT QIDI ${NC}"
echo -e "${CYAN}======================================================${NC}"

if [ ! -f "$BACKUP_BIN" ]; then
    echo -e "${RED}[!] Không tìm thấy bản sao lưu gốc tại $BACKUP_BIN!${NC}"
    exit 1
fi

echo -e "${YELLOW}[1/3] Đang tạm dừng dịch vụ giao diện (qidi-client)...${NC}"
echo qiditech | sudo -S systemctl stop qidi-client 2>/dev/null || true
sleep 1

echo -e "${YELLOW}[2/3] Đang khôi phục tệp thực thi gốc từ bản sao lưu...${NC}"
cp -f "$BACKUP_BIN" "$TARGET_BIN"
chmod 755 "$TARGET_BIN"

echo -e "${YELLOW}[3/3] Đang khởi động lại giao diện màn hình...${NC}"
echo qiditech | sudo -S systemctl start qidi-client

echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}   ĐÃ KHÔI PHỤC THÀNH CÔNG VỀ NGUYÊN BẢN CỦA NHÀ MÁY!  ${NC}"
echo -e "${GREEN}======================================================${NC}"

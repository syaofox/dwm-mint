#!/bin/bash

# 确保以 root 权限运行
if [ "$EUID" -ne 0 ]; then 
  echo "请使用 sudo 运行此脚本"
  exit
fi

echo "1. 正在安装/检查 zram-tools..."
apt update && apt install -y zram-tools

echo "2. 解除系统默认的 256M 上限限制..."
# 某些版本的 zramswap 脚本硬编码了 256M 的上限，这里将其改为 32GB 宽限值
if [ -f /usr/bin/zramswap ]; then
    sed -i 's/MAXVAL=256/MAXVAL=32768/' /usr/bin/zramswap
fi

echo "3. 写入 zram 配置 (PERCENT=75, PRIORITY=100)..."
cat << 'EOF' > /etc/default/zramswap
ALGO=zstd
PERCENT=75
PRIORITY=100
EOF

echo "4. 优化内核 swappiness (设为 100 以优先使用 zram)..."
sysctl vm.swappiness=100
sed -i '/vm.swappiness/d' /etc/sysctl.conf
echo "vm.swappiness=100" >> /etc/sysctl.conf

echo "5. 重置并重启 zram 服务..."
systemctl stop zramswap
# 强制重置设备确保大小更新
zramctl --reset /dev/zram0 2>/dev/null || true
systemctl start zramswap

echo "------------------------------------------------"
echo "配置更新完成！"
swapon --show
echo "------------------------------------------------"
zramctl
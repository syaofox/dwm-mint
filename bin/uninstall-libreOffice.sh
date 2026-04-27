#!/bin/bash


echo "=========================================="
echo "    正在准备彻底卸载 LibreOffice..."
echo "=========================================="

# 1. 移除所有 LibreOffice 相关的软件包
# 使用 purge 会同时删除配置文件
echo "--- 正在移除软件包 ---"
sudo apt-get purge -y libreoffice*

# 2. 移除孤立的依赖包
echo "--- 正在清理无用的依赖 ---"
sudo apt-get autoremove -y

# 3. 清理下载的包缓存
sudo apt-get autoclean

# 4. 删除用户目录下的个人配置 (可选)
# 这一步会删除所有用户的 LibreOffice 配置（如自定义快捷键、模板等）
echo "--- 正在清理用户配置文件 ---"
sudo rm -rf /home/*/.config/libreoffice
sudo rm -rf /root/.config/libreoffice

echo "=========================================="
echo "      LibreOffice 已成功从系统移除！"
echo "=========================================="
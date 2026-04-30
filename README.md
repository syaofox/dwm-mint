# dwm-mint

Linux Mint 22.3 + DWM（Dynamic Window Manager）安装配置脚本。

## 快速开始

```bash
# 1. live 环境分区,选择btrfs,在分区后选择时区时运行脚本 Btrfs 子卷优化（需 sudo）
sudo bash tools/btrfs.sh

# 2. 正常安装流程,完成后重启电脑,进行 ZRAM 交换设置（推荐，需 sudo）

sudo bash tools/zram.sh

# 3. 运行 DWM 安装程序
bash install.sh

# 重启进入系统后

# 4 还原备份配置
bash tools/config-manager.sh



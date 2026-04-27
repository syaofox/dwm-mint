#!/bin/bash

# 分区完之后，弹出选择时区的时候执行

# 检查是否以 root 权限运行
if [ "$EUID" -ne 0 ]; then
  echo "请使用 sudo 运行此脚本"
  exit 1
fi

# --- 第一步：交互式选择设备 ---
echo "=========================================="
echo "      Btrfs 子卷重构脚本 - 交互版"
echo "=========================================="

# 列出所有块设备供参考
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINTS,LABEL

echo "------------------------------------------"

# 获取 Btrfs 分区
read -p "请输入 Btrfs 根分区设备路径 (默认 /dev/vda3): " DEV_BTRFS
DEV_BTRFS=${DEV_BTRFS:-/dev/vda3}

# 获取 EFI 分区
read -p "请输入 EFI 分区设备路径 (默认 /dev/vda1): " DEV_EFI
DEV_EFI=${DEV_EFI:-/dev/vda1}

# 确认信息
echo "确认配置: Btrfs=$DEV_BTRFS, EFI=$DEV_EFI"
read -p "按回车键开始执行，或按 Ctrl+C 退出..."

# 内部固定变量
TARGET="/target"
MOUNT_TMP="/mnt"

echo "--- 开始 Btrfs 多子卷重构及性能优化任务 ---"

# 1. 彻底卸载 /target 下的所有挂载点
echo "正在卸载现有挂载..."
umount -R $TARGET 2>/dev/null

# 2. 挂载 Btrfs 根分区处理子卷
echo "正在挂载根分区并创建子卷..."
mount $DEV_BTRFS $MOUNT_TMP
cd $MOUNT_TMP

# 处理 @ 根子卷
if [ -d "@rootfs" ]; then
    mv @rootfs @
    echo "已重命名 @rootfs 为 @"
fi

# 批量创建子卷列表
SUBVOLS=("@home" "@cache" "@log" "@docker" "@vir")
for sv in "${SUBVOLS[@]}"; do
    if [ ! -d "$sv" ]; then
        btrfs subvolume create "$sv"
        echo "已创建子卷: $sv"
    else
        echo "子卷 $sv 已存在，跳过创建。"
    fi
done

cd /
umount $MOUNT_TMP

# 3. 重新建立挂载层级并挂载
echo "正在执行多子卷挂载..."
mount -o noatime,compress=zstd,subvol=@ $DEV_BTRFS $TARGET

declare -A VOL_MAP=(
    ["@home"]="/home"
    ["@cache"]="/var/cache"
    ["@log"]="/var/log"
    ["@docker"]="/var/lib/docker"
    ["@vir"]="/var/lib/libvirt/images"
)

for sv in "${!VOL_MAP[@]}"; do
    mkdir -p "${TARGET}${VOL_MAP[$sv]}"
    mount -o noatime,compress=zstd,subvol=$sv $DEV_BTRFS "${TARGET}${VOL_MAP[$sv]}"
done

# 挂载 EFI
mkdir -p $TARGET/boot/efi
mount $DEV_EFI $TARGET/boot/efi

# 4. 关键步骤：针对 Docker 和 虚拟机 禁用 CoW (nodatacow)
echo "正在对特定目录禁用写时复制 (chattr +C)..."
# 注意：chattr +C 必须在目录为空时设置才对新文件生效
chattr +C $TARGET/var/lib/docker
chattr +C $TARGET/var/lib/libvirt/images

# 验证属性 (输出应包含 'C')
echo "当前属性验证："
lsattr -d $TARGET/var/lib/docker $TARGET/var/lib/libvirt/images

# 5. 自动生成新的 /etc/fstab
echo "正在生成 /target/etc/fstab..."
BTRFS_UUID=$(blkid -s UUID -o value $DEV_BTRFS)
EFI_UUID=$(blkid -s UUID -o value $DEV_EFI)
SWAP_LINE=$(grep "swap" $TARGET/etc/fstab 2>/dev/null | grep -v "#")

cat <<EOF > $TARGET/etc/fstab
# /etc/fstab: Modified for Btrfs Subvolumes, Timeshift & Performance
# <file system> <mount point>   <type>  <options>       <dump>  <pass>

# Btrfs 核心子卷
UUID=$BTRFS_UUID /               btrfs   noatime,compress=zstd,subvol=@       0       1
UUID=$BTRFS_UUID /home           btrfs   noatime,compress=zstd,subvol=@home   0       2

# Btrfs 数据与日志子卷
UUID=$BTRFS_UUID /var/cache      btrfs   noatime,compress=zstd,subvol=@cache  0       2
UUID=$BTRFS_UUID /var/log        btrfs   noatime,compress=zstd,subvol=@log    0       2

# Btrfs 禁用 CoW 目录 (nodatacow)
# 注意：即便 fstab 使用 compress，对已设置 +C 的目录也会自动禁用压缩以保持兼容
UUID=$BTRFS_UUID /var/lib/docker btrfs   noatime,nodatacow,subvol=@docker     0       2
UUID=$BTRFS_UUID /var/lib/libvirt/images btrfs noatime,nodatacow,subvol=@vir 0       2

# EFI 分区
UUID=$EFI_UUID  /boot/efi       vfat    umask=0077,noatime      0       1

# Swap 分区
$SWAP_LINE
EOF

echo "--- 脚本执行完毕！ ---"
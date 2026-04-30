#!/bin/bash

# 分区完之后，弹出选择时区的时候执行

# ==========================================
# Configuration - edit here only
# ==========================================

# Device paths (leave empty for interactive prompt)
DEV_BTRFS=""
DEV_EFI=""

# Mount base directories
TARGET="/target"
MOUNT_TMP="/mnt"
EFI_MOUNT="/boot/efi"

# Root subvolume rename.
# Set RENAME_SRC if the installer created a different name (e.g. "rootfs" for @rootfs).
# The script will rename @<RENAME_SRC> to @.
RENAME_SRC=""

# Subvolume definitions: "name|mount_point|nodatacow(yes/no)"
# Change this array to add/remove/modify subvolumes — everything else derives from it.
SUBVOLUMES=(
    "@home|/home|no"
    "@cache|/var/cache|no"
    "@log|/var/log|no"
    "@docker|/var/lib/docker|yes"
    "@virt|/var/lib/libvirt|yes"
)

# ==========================================
# Main
# ==========================================

if [ "$EUID" -ne 0 ]; then
    echo "请使用 sudo 运行此脚本"
    exit 1
fi

echo "=========================================="
echo "      Btrfs 子卷重构脚本"
echo "=========================================="

lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINTS,LABEL
echo "------------------------------------------"

# Device selection
read -p "请输入 Btrfs 根分区设备路径 (默认 /dev/vda3): " input
DEV_BTRFS=${input:-${DEV_BTRFS:-/dev/vda3}}

read -p "请输入 EFI 分区设备路径 (默认 /dev/vda1): " input
DEV_EFI=${input:-${DEV_EFI:-/dev/vda1}}

echo "确认配置: Btrfs=$DEV_BTRFS, EFI=$DEV_EFI"
read -p "按回车键开始执行，或按 Ctrl+C 退出..."

echo "--- 开始 Btrfs 多子卷重构及性能优化 ---"

# 1. Unmount existing mounts
echo "正在卸载现有挂载..."
umount -R "$TARGET" 2>/dev/null

# 2. Mount and create subvolumes
echo "正在挂载根分区并创建子卷..."
mount "$DEV_BTRFS" "$MOUNT_TMP"
cd "$MOUNT_TMP" || exit

# Rename root subvolume if needed
if [ -n "$RENAME_SRC" ] && [ -d "@${RENAME_SRC}" ]; then
    mv "@${RENAME_SRC}" @
    echo "已重命名 @${RENAME_SRC} 为 @"
fi

# Create subvolumes from SUBVOLUMES array
for entry in "${SUBVOLUMES[@]}"; do
    name="${entry%%|*}"
    if [ ! -d "$name" ]; then
        btrfs subvolume create "$name"
        echo "已创建子卷: $name"
    else
        echo "子卷 $name 已存在，跳过"
    fi
done

cd /
umount "$MOUNT_TMP"

# 3. Mount hierarchy
echo "正在执行多子卷挂载..."
mount -o noatime,compress=zstd,subvol=@ "$DEV_BTRFS" "$TARGET"

for entry in "${SUBVOLUMES[@]}"; do
    IFS='|' read -r name target _ <<< "$entry"
    mkdir -p "${TARGET}${target}"
    mount -o noatime,compress=zstd,subvol="$name" "$DEV_BTRFS" "${TARGET}${target}"
done

# Mount EFI
mkdir -p "${TARGET}${EFI_MOUNT}"
mount "$DEV_EFI" "${TARGET}${EFI_MOUNT}"

# 4. Disable CoW for designated subvolumes
echo "正在对特定目录禁用写时复制 (chattr +C)..."
cow_paths=()
for entry in "${SUBVOLUMES[@]}"; do
    IFS='|' read -r name target cow <<< "$entry"
    if [ "$cow" = "yes" ]; then
        chattr +C "${TARGET}${target}"
        cow_paths+=("${TARGET}${target}")
        echo "  已禁用 CoW: $target"
    fi
done

if [ ${#cow_paths[@]} -gt 0 ]; then
    echo "当前属性验证："
    lsattr -d "${cow_paths[@]}"
fi

# 5. Generate fstab from SUBVOLUMES array
echo "正在生成 $TARGET/etc/fstab..."
BTRFS_UUID=$(blkid -s UUID -o value "$DEV_BTRFS")
EFI_UUID=$(blkid -s UUID -o value "$DEV_EFI")
SWAP_LINE=$(grep "swap" "$TARGET/etc/fstab" 2>/dev/null | grep -v "#")

{
    cat <<FSTAB_HEADER
# /etc/fstab: Modified for Btrfs Subvolumes & Performance
# <file system> <mount point>   <type>  <options>       <dump>  <pass>

# Btrfs root subvolume
UUID=$BTRFS_UUID /               btrfs   noatime,compress=zstd,subvol=@       0       1

FSTAB_HEADER

    # Data subvolumes — loop generates one entry per SUBVOLUMES item
    for entry in "${SUBVOLUMES[@]}"; do
        IFS='|' read -r name target cow <<< "$entry"
        if [ "$cow" = "yes" ]; then
            opts="noatime,nodatacow"
        else
            opts="noatime,compress=zstd"
        fi
        echo "UUID=$BTRFS_UUID $target      btrfs   $opts,subvol=$name       0       2"
    done
    echo ""

    echo "# EFI partition"
    echo "UUID=$EFI_UUID  $EFI_MOUNT       vfat    umask=0077,noatime      0       1"
    echo ""

    # Swap
    if [ -n "$SWAP_LINE" ]; then
        echo "# Swap"
        echo "$SWAP_LINE"
        echo ""
    fi

    cat <<FSTAB_FOOTER
# ============================================
# Additional mounts (uncomment as needed)
# ============================================

# ssd
#UUID=cb6285a3-5e94-4376-a9fc-38b10c28d40e /mnt/github btrfs rw,noatime,ssd,compress=zstd:3,discard=async,space_cache=v2,subvol=/@github 0 0
#UUID=cb6285a3-5e94-4376-a9fc-38b10c28d40e /mnt/data btrfs rw,noatime,ssd,compress=zstd:3,discard=async,space_cache=v2,subvol=/@data 0 0

# dnas
#10.10.10.2:/fs/1000/nfs /mnt/dnas nfs noauto,x-systemd.automount,_netdev,addr=10.10.10.2 0 0

# xiaoxin
#10.10.10.6:/fs/1000/nfs /mnt/xiaoxin nfs noauto,x-systemd.automount,_netdev,addr=10.10.10.6 0 0
FSTAB_FOOTER

} > "$TARGET/etc/fstab"

echo "--- 脚本执行完毕！ ---"

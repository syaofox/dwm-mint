#!/bin/bash

# 分区完之后，弹出选择时区的时候执行

# ==========================================
# Configuration
# ==========================================

DEV_BTRFS=""
DEV_EFI=""

TARGET="/target"
MOUNT_TMP="/mnt"
EFI_MOUNT="/boot/efi"

MOUNT_OPTS="noatime,compress=zstd:3,ssd"

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

read -p "请输入 Btrfs 根分区设备路径 (默认 /dev/vda3): " input
DEV_BTRFS=${input:-${DEV_BTRFS:-/dev/vda3}}

read -p "请输入 EFI 分区设备路径 (默认 /dev/vda1): " input
DEV_EFI=${input:-${DEV_EFI:-/dev/vda1}}

echo "确认配置: Btrfs=$DEV_BTRFS, EFI=$DEV_EFI"
read -p "按回车键开始执行，或按 Ctrl+C 退出..."

# ==========================================
# Phase 1: Mount btrfs root
# ==========================================
echo ""
echo "--- 阶段 1/4: 挂载 Btrfs 根分区 ---"
umount -R "$TARGET" 2>/dev/null
mount "$DEV_BTRFS" "$MOUNT_TMP"
cd "$MOUNT_TMP" || exit

# ==========================================
# Phase 2: Pre-flight validation
# ==========================================
echo "--- 阶段 2/4: 前置检查 ---"
errors=()

# 2a. Root subvolume must exist
if [ -d "@" ]; then
    echo "  [OK] 找到根子卷 @"
elif [ -d "@rootfs" ]; then
    echo "  [OK] 找到根子卷 @rootfs (将被重命名为 @)"
else
    errors+=("未找到 @ 或 @rootfs 子卷")
fi

# 2b. Mount @ temporarily to inspect mount points
mount -o subvol=@ "$DEV_BTRFS" "$TARGET"

for entry in "${SUBVOLUMES[@]}"; do
    IFS='|' read -r name target cow <<< "$entry"

    if [ -d "${TARGET}${target}" ] && [ "$(ls -A "${TARGET}${target}")" ]; then
        echo "  [迁移] ${target} 根子卷中已有内容，将迁至子卷 $name"
    fi

    if [ "$cow" = "yes" ]; then
        if [ -d "${TARGET}${target}" ] && [ "$(ls -A "${TARGET}${target}")" ]; then
            errors+=("${target} 非空，无法对其禁用 CoW (chattr +C 要求目录为空)")
        else
            echo "  [OK] ${target} 为空，可禁用 CoW"
        fi
    fi
done

umount "$TARGET"
cd /

# 2c. Report
if [ ${#errors[@]} -gt 0 ]; then
    echo ""
    echo "=========================================="
    echo "  前置检查失败，需先处理以下问题："
    for err in "${errors[@]}"; do
        echo "    - $err"
    done
    echo "=========================================="
    umount "$MOUNT_TMP"
    exit 1
fi

echo "所有前置检查通过，继续执行..."

# ==========================================
# Phase 3: Create subvolumes
# ==========================================
echo ""
echo "--- 阶段 3/4: 创建子卷 ---"
cd "$MOUNT_TMP" || exit

if [ -d "@rootfs" ]; then
    mv @rootfs @
    echo "已重命名 @rootfs 为 @"
fi

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

# ==========================================
# Phase 4: Mount hierarchy and configure
# ==========================================
echo ""
echo "--- 阶段 4/4: 挂载与配置 ---"

mount -o "$MOUNT_OPTS",subvol=@ "$DEV_BTRFS" "$TARGET"

for entry in "${SUBVOLUMES[@]}"; do
    IFS='|' read -r name target _ <<< "$entry"

    if [ -d "${TARGET}${target}" ] && [ "$(ls -A "${TARGET}${target}")" ]; then
        echo "  迁移 ${target} 至子卷 $name..."
        migrate_mnt="${MOUNT_TMP}/.migrate-${name#@}"
        mkdir -p "$migrate_mnt"
        mount -o "$MOUNT_OPTS",subvol="$name" "$DEV_BTRFS" "$migrate_mnt"
        cp -a --reflink=auto "${TARGET}${target}/." "$migrate_mnt/"
        umount "$migrate_mnt"
        rmdir "$migrate_mnt"
        mount -o "$MOUNT_OPTS",subvol="$name" "$DEV_BTRFS" "${TARGET}${target}"
        echo "  已迁移 ${target} 至子卷 $name"
    else
        mkdir -p "${TARGET}${target}"
        mount -o "$MOUNT_OPTS",subvol="$name" "$DEV_BTRFS" "${TARGET}${target}"
    fi
done

mkdir -p "${TARGET}${EFI_MOUNT}"
mount "$DEV_EFI" "${TARGET}${EFI_MOUNT}"

echo "禁用写时复制 (chattr +C)..."
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
    echo "属性验证："
    lsattr -d "${cow_paths[@]}"
fi

echo "正在生成 $TARGET/etc/fstab..."
BTRFS_UUID=$(blkid -s UUID -o value "$DEV_BTRFS")
EFI_UUID=$(blkid -s UUID -o value "$DEV_EFI")
SWAP_LINE=$(grep "swap" "$TARGET/etc/fstab" 2>/dev/null | grep -v "#")

{
    cat <<FSTAB_HEADER
# /etc/fstab: Modified for Btrfs Subvolumes & Performance
# <file system> <mount point>   <type>  <options>       <dump>  <pass>

# Btrfs root subvolume
UUID=$BTRFS_UUID /               btrfs   $MOUNT_OPTS,subvol=@       0       1

FSTAB_HEADER

    for entry in "${SUBVOLUMES[@]}"; do
        IFS='|' read -r name target _ <<< "$entry"
        echo "UUID=$BTRFS_UUID $target      btrfs   $MOUNT_OPTS,subvol=$name       0       2"
    done
    echo ""

    echo "# EFI partition"
    echo "UUID=$EFI_UUID  $EFI_MOUNT       vfat    umask=0077,noatime      0       1"
    echo ""

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
#10.10.10.2:/fs/1000/nfs /mnt/dnas nfs defaults,_netdev,rw,nofail,hard,intr,timeo=600,retrans=2,x-systemd.automount 0 0

# xiaoxin
#10.10.10.6:/fs/1000/nfs /mnt/xiaoxin nfs defaults,_netdev,rw,nofail,hard,intr,timeo=600,retrans=2,x-systemd.automount 0 0


# //10.10.10.6/data /mnt/xiaoxin/data cifs  credentials=/home/syaofox/.smbcredentials,uid=1000,gid=1000,iocharset=utf8,vers=3.0,rw,_netdev,nofail,x-systemd.automount,x-systemd.idle-timeout=60  0  0
# //10.10.10.2/wd12t /mnt/dnas/wd12t cifs  credentials=/home/syaofox/.smbcredentials,uid=1000,gid=1000,iocharset=utf8,vers=3.0,rw,_netdev,nofail,x-systemd.automount,x-systemd.idle-timeout=60  0  0
# //10.10.10.2/data /mnt/dnas/data cifs  credentials=/home/syaofox/.smbcredentials,uid=1000,gid=1000,iocharset=utf8,vers=3.0,rw,_netdev,nofail,x-systemd.automount,x-systemd.idle-timeout=60  0  0
# //10.10.10.2/download /mnt/dnas/download cifs  credentials=/home/syaofox/.smbcredentials,uid=1000,gid=1000,iocharset=utf8,vers=3.0,rw,_netdev,nofail,x-systemd.automount,x-systemd.idle-timeout=60  0  0
# //10.10.10.2/backup /mnt/dnas/backup cifs  credentials=/home/syaofox/.smbcredentials,uid=1000,gid=1000,iocharset=utf8,vers=3.0,rw,_netdev,nofail,x-systemd.automount,x-systemd.idle-timeout=60  0  0

FSTAB_FOOTER

} > "$TARGET/etc/fstab"

echo ""
echo "--- 脚本执行完毕！ ---"

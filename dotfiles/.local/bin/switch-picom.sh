#!/bin/bash

# 配置路径
PICOM_DIR="$HOME/.config/picom"
ACTIVE="$PICOM_DIR/picom.conf"
BLUR_SRC="$PICOM_DIR/picom-blur.conf"
PERF_SRC="$PICOM_DIR/picom-perf.conf"

# 定义 Rofi 选项 (显示名称)
OPT_BLUR="Eye Candy"
OPT_PERF="Performance"

# 弹出 Rofi 菜单
# -dmenu: 开启列表模式
# -p: 设置提示文字
# -i: 忽略大小写
CHOICE=$(echo -e "$OPT_BLUR\n$OPT_PERF" | rofi -dmenu -p "选择 Picom 模式:" -i)

# 根据选择执行操作
case "$CHOICE" in
    "$OPT_BLUR")
        cp "$BLUR_SRC" "$ACTIVE"
        MODE="Blur"
        ;;
    "$OPT_PERF")
        cp "$PERF_SRC" "$ACTIVE"
        MODE="Performance"
        ;;
    *)
        # 如果用户直接关闭了 Rofi，则退出
        exit 0
        ;;
esac

# 杀掉旧进程并确保它已关闭
pkill -x picom
while pgrep -u $USER -x picom >/dev/null; do sleep 0.1; done

# 启动新的 picom 进程
# -b 表示后台运行 (daemon)
picom --config "$ACTIVE" -b &>/dev/null

# 发送通知
dunstify -r 9999 -t 2000 "Picom: $MODE"
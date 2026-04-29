#!/bin/bash

mode="$1"
shift # 移除第一个参数 (mode)，使 $@ 包含剩下的参数

case "$mode" in
    menu)
        rofi -show drun -show-icons
        ;;
    file)
        nemo --no-desktop
        ;;
    lock)
        slock -m "Single is simple, double is double."
        ;;
    clipman)
        xfce4-popup-clipman
        ;;
    term)
        # 现在的 $@ 已经是空的（如果你只传了 term）
        # 或者包含了 term 之后的参数
        exec wezterm "$@"
        ;;
    clip)
        maim -s | xclip -selection clipboard -t image/png && \
        dunstify -r 9988 -t 2000 '截图已保存到剪贴板' || \
        dunstify -r 9988 -t 2000 '截图失败'
        ;;
    save)
        mkdir -p "$HOME/Pictures/Screenshots"
        filepath="$HOME/Pictures/Screenshots/screenshot_$(date +%Y%m%d_%H%M%S).png"
        maim -s "$filepath" && \
        dunstify -r 9988 -t 2000 "截图已保存: $filepath" || \
        dunstify -r 9988 -t 2000 '截图失败'
        ;;    
esac
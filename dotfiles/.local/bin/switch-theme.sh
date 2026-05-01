#!/bin/bash

# Theme directories - adjust if using dotfiles symlinks

# 主题目录 - 软连接到 dotfiles 目录下的 .Xresources.d
THEME_DIR="$HOME/.Xresources.d"

ROFI_DIR="$HOME/.config/rofi/themes"
WEZTERM_DIR="$HOME/.config/wezterm/themes"
DUNST_DIR="$HOME/.config/dunst/themes"
YAZI_DIR="$HOME/.config/yazi/themes"

# Robust theme enumeration (handles spaces in names)
AVAILABLE_THEMES=()
if [ -d "$THEME_DIR" ]; then
    while IFS= read -r -d '' theme; do
        theme_name=$(basename "$theme")
        [[ "$theme_name" != \#* ]] && AVAILABLE_THEMES+=("$theme_name")
    done < <(find "$THEME_DIR" -maxdepth 1 -mindepth 1 \( -type f -o -type l \) -print0 | sort -z)
fi

echo "Available themes: ${AVAILABLE_THEMES[*]}"

show_menu() {
    # Check if themes available
    if [ ${#AVAILABLE_THEMES[@]} -eq 0 ]; then
        dunstify -r 9988 -t 3000 "错误: 未找到主题文件在 $THEME_DIR"
        return 1
    fi
    
    local menu=""
    for theme in "${AVAILABLE_THEMES[@]}"; do
        menu="$menu$theme\n"
    done
    
    # Try with theme parameter, fallback to without if fails
    echo -e "$menu" | rofi -dmenu -p "Theme" -i -theme-str "listview { columns: 2; lines: 6;} " 2>/dev/null || \
    echo -e "$menu" | rofi -dmenu -p "Theme" -i
}

# Validate GTK theme exists in standard locations
validate_gtk_theme() {
    local theme="$1"
    local theme_paths=("$HOME/.themes" "$HOME/.local/share/themes" "/usr/share/themes")
    
    for base in "${theme_paths[@]}"; do
        if [ -d "$base/$theme" ]; then
            return 0
        fi
    done
    return 1
}

# Restart xsettingsd to apply changes
restart_xsettingsd() {
    if pgrep -x xsettingsd > /dev/null; then
        killall -HUP xsettingsd 2>/dev/null || killall xsettingsd 2>/dev/null && sleep 0.5
    fi
    
    # Start xsettingsd if not running
    if ! pgrep -x xsettingsd > /dev/null; then
        xsettingsd -c "$HOME/.config/xsettingsd/xsettingsd.conf" &
        disown
    fi
}

switch_theme() {
    local theme="$1"
    local theme_file
    local base_theme

    # Xresources 使用完整主题名
    theme_file=$(readlink -f "$THEME_DIR/$theme")

    if [ ! -f "$theme_file" ]; then
        dunstify -r 9988 -t 2000 "主题 $theme 不存在"
        return 1
    fi

    echo "$theme" > "$HOME/.config/theme"

    # 生成所有应用的配置文件
    if [ -f "$HOME/.local/bin/generate-app-themes.py" ]; then
        python3 "$HOME/.local/bin/generate-app-themes.py" "$theme_file"
    fi

    # 应用 xfce4-terminal 配色
    xfce4_term_script="$HOME/.cache/xfce4-terminal-theme.sh"
    if [ -f "$xfce4_term_script" ]; then
        bash "$xfce4_term_script"
    fi

    # 验证 GTK 主题是否存在
    gtk_theme=$(grep -m1 '^gtk\.theme:' "$theme_file" | sed 's/^gtk\.theme:[[:space:]]*//')
    if [ -n "$gtk_theme" ] && ! validate_gtk_theme "$gtk_theme"; then
        dunstify -r 9988 -t 3000 "警告: GTK 主题 '$gtk_theme' 未找到，GTK 应用可能使用默认主题"
    fi

    # xsettingsd 配置已由 generate-app-themes.py 生成
    restart_xsettingsd

    xrdb -merge "$theme_file"

    pkill -USR1 dwm 2>/dev/null || true

    killall slstatus 2>/dev/null || true
    slstatus &

    killall dunst 2>/dev/null || true
    dunst &

    # PS1 配置已通过 PROMPT_COMMAND 自动检测更新（见 env.sh）
    # 下次显示提示符时会自动应用新主题

    dunstify -r 9988 -t 2000 "主题已切换: $theme"
}

main() {
    if [ -n "$1" ]; then
        theme="$1"
    else
        theme=$(show_menu)
    fi

    if [ -n "$theme" ]; then
        switch_theme "$theme"
    fi
}

main "$@"
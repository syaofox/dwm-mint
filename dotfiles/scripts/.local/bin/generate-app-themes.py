#!/usr/bin/env python3
"""
从 .Xresources.d/ 主题文件生成各应用的配置文件
类似 PS1 的方式：解析主题文件 → 生成配置
"""

import sys
import os
import subprocess

def hex_to_rgb(hex_color):
    """将十六进制颜色转换为 RGB 元组"""
    hex_color = hex_color.strip().lstrip('#')
    return int(hex_color[0:2], 16), int(hex_color[2:4], 16), int(hex_color[4:6], 16)

def parse_xresources(filepath):
    """解析 Xresources 主题文件，支持 #define 宏定义"""
    colors = {
        'dunst': {},
        'rofi': {},
        'wezterm': {},
        'yazi': {},
        'ps1': {},
        'gtk': {}
    }
    
    # 第一遍：收集 #define 宏定义
    defines = {}
    with open(filepath, 'r') as f:
        for line in f:
            line = line.strip()
            if line.startswith('#define'):
                parts = line.split(None, 2)
                if len(parts) >= 2:
                    macro_name = parts[1]
                    macro_value = parts[2].strip() if len(parts) > 2 else ''
                    defines[macro_name] = macro_value
    
    def expand_macro(value):
        """展开宏定义"""
        value = value.strip()
        if value in defines:
            return defines[value]
        return value
    
    # 第二遍：解析颜色定义，展开宏
    with open(filepath, 'r') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('!') or line.startswith('*') or line.startswith('#'):
                continue
            
            if ':' in line:
                key, value = line.split(':', 1)
                key = key.strip()
                value = expand_macro(value.strip())
                
                if key.startswith('dunst.'):
                    colors['dunst'][key] = value
                elif key.startswith('rofi.'):
                    colors['rofi'][key] = value
                elif key.startswith('wezterm.'):
                    colors['wezterm'][key] = value
                elif key.startswith('yazi.'):
                    colors['yazi'][key] = value
                elif key.startswith('ps1.'):
                    colors['ps1'][key] = value
                elif key.startswith('gtk.'):
                    colors['gtk'][key] = value
    
    return colors

def generate_dunst_config(colors, output_file):
    """生成 dunst 配置文件"""
    if not colors:
        return
    
    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    
    if os.path.islink(output_file):
        os.unlink(output_file)
    
    urgency_low_bg = colors.get('dunst.urgency_low_bg', '#2E3440')
    urgency_low_fg = colors.get('dunst.urgency_low_fg', '#D8DEE9')
    urgency_low_frame = colors.get('dunst.urgency_low_frame', '#88C0D0')
    
    urgency_normal_bg = colors.get('dunst.urgency_normal_bg', '#3B4252')
    urgency_normal_fg = colors.get('dunst.urgency_normal_fg', '#D8DEE9')
    urgency_normal_frame = colors.get('dunst.urgency_normal_frame', '#88C0D0')
    
    urgency_critical_bg = colors.get('dunst.urgency_critical_bg', '#2a1515')
    urgency_critical_fg = colors.get('dunst.urgency_critical_fg', '#ff9f90')
    urgency_critical_frame = colors.get('dunst.urgency_critical_frame', '#ff7f70')
    
    with open(output_file, 'w') as f:
        f.write('[global]\n')
        f.write('    monitor = 0\n')
        f.write('    follow = keyboard\n')
        f.write('    origin = top-right\n')
        f.write('    offset = 10x50\n')
        f.write('    width = 500\n')
        f.write('    height = 300\n')
        f.write('    indicate_hidden = yes\n')
        f.write('    shrink = no\n')
        f.write('    transparency = 0\n')
        f.write('    separator_height = 2\n')
        f.write('    padding = 15\n')
        f.write('    horizontal_padding = 15\n')
        f.write('    frame_width = 1\n')
        f.write('    frame_color = "{}"\n'.format(urgency_normal_frame))
        f.write('    separator_color = auto\n')
        f.write('    sort = yes\n')
        f.write('    idle_threshold = 120\n')
        f.write('\n')
        f.write('    font = JetBrainsMono Nerd Font 11\n')
        f.write('    line_height = 2\n')
        f.write('    markup = full\n')
        f.write('    format = "<b>%s</b>\\n%b"\n')
        f.write('    alignment = left\n')
        f.write('    vertical_alignment = center\n')
        f.write('    show_age_threshold = 30\n')
        f.write('    word_wrap = yes\n')
        f.write('    ellipsize = middle\n')
        f.write('    ignore_newline = yes\n')
        f.write('    stack_duplicates = true\n')
        f.write('    hide_duplicate_count = false\n')
        f.write('    show_indicators = yes\n')
        f.write('\n')
        f.write('    icon_position = off\n')
        f.write('    min_icon_size = 0\n')
        f.write('    max_icon_size = 0\n')
        f.write('    enable_recursive_icon_lookup = false\n')
        f.write('    icon_path = ""\n')
        f.write('\n')
        f.write('    sticky_history = yes\n')
        f.write('    history_length = 20\n')
        f.write('\n')
        f.write('    dmenu = /usr/bin/dmenu -p dunst:\n')
        f.write('    browser = /usr/bin/firefox -new-tab\n')
        f.write('    always_run_script = true\n')
        f.write('    title = Dunst\n')
        f.write('    class = Dunst\n')
        f.write('    corner_radius = 0\n')
        f.write('    force_xinerama = false\n')
        f.write('\n')
        f.write('    progress_bar = true\n')
        f.write('    progress_bar_height = 10\n')
        f.write('    progress_bar_frame_width = 1\n')
        f.write('    progress_bar_min_width = 150\n')
        f.write('    progress_bar_max_width = 300\n')
        f.write('    notification_limit = 5\n')
        f.write('    ignore_dbusclose = false\n')
        f.write('\n')
        f.write('    mouse_left_click = close_current\n')
        f.write('    mouse_middle_click = do_action\n')
        f.write('    mouse_right_click = close_all\n')
        f.write('\n')
        f.write('[experimental]\n')
        f.write('    per_monitor_dpi = false\n')
        f.write('\n')
        f.write('[urgency_low]\n')
        f.write('    background = "{}"\n'.format(urgency_low_bg))
        f.write('    foreground = "{}"\n'.format(urgency_low_fg))
        f.write('    frame_color = "{}"\n'.format(urgency_low_frame))
        f.write('    timeout = 10\n')
        f.write('    highlight = "{}"\n'.format(urgency_low_frame))
        f.write('\n')
        f.write('[urgency_normal]\n')
        f.write('    background = "{}"\n'.format(urgency_normal_bg))
        f.write('    foreground = "{}"\n'.format(urgency_normal_fg))
        f.write('    frame_color = "{}"\n'.format(urgency_normal_frame))
        f.write('    timeout = 10\n')
        f.write('    highlight = "{}"\n'.format(urgency_normal_frame))
        f.write('\n')
        f.write('[urgency_critical]\n')
        f.write('    background = "{}"\n'.format(urgency_critical_bg))
        f.write('    foreground = "{}"\n'.format(urgency_critical_fg))
        f.write('    frame_color = "{}"\n'.format(urgency_critical_frame))
        f.write('    timeout = 30\n')
        f.write('    highlight = "{}"\n'.format(urgency_critical_frame))

def generate_rofi_config(colors, output_file):
    """生成 rofi 配置文件"""
    if not colors:
        return
    
    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    
    if os.path.islink(output_file):
        os.unlink(output_file)
    
    icon_theme = colors.get('rofi.icontheme', 'Mint-Y-Cyan')
    background = colors.get('rofi.background', '#2E3440')
    foreground = colors.get('rofi.foreground', '#D8DEE9')
    selected_bg = colors.get('rofi.selected_bg', '#88C0D0')
    selected_fg = colors.get('rofi.selected_fg', '#2E3440')
    active_fg = colors.get('rofi.active_fg', '#88C0D0')
    
    bg_r, bg_g, bg_b = hex_to_rgb(background)
    sel_r, sel_g, sel_b = hex_to_rgb(selected_bg)
    
    with open(output_file, 'w') as f:
        f.write('configuration {\n')
        f.write('    icon-theme: "{}";\n'.format(icon_theme))
        f.write('}\n\n')
        f.write('* {\n')
        # f.write('    icon-theme:                  "{}";\n'.format(icon_theme))
        f.write('    background:                  {};\n'.format(background))
        f.write('    foreground:                  {};\n'.format(foreground))
        f.write('    normal-foreground:           @foreground;\n')
        f.write('    normal-background:           rgba ({}, {}, {}, 63%);\n'.format(bg_r, bg_g, bg_b))
        f.write('    selected-normal-foreground:  {};\n'.format(selected_fg))
        f.write('    selected-normal-background:  {};\n'.format(selected_bg))
        f.write('    selected-active-foreground:  {};\n'.format(active_fg))
        f.write('    selected-active-background:  rgba ({}, {}, {}, 100%);\n'.format(sel_r, sel_g, sel_b))
        f.write('    selected-urgent-foreground:  @selected-normal-foreground;\n')
        f.write('    selected-urgent-background:  rgba ({}, {}, {}, 100%);\n'.format(sel_r, sel_g, sel_b))
        f.write('    urgent-foreground:           @foreground;\n')
        f.write('    urgent-background:           rgba ({}, {}, {}, 15%);\n'.format(bg_r, bg_g, bg_b))
        f.write('    active-foreground:          {};\n'.format(active_fg))
        f.write('    active-background:           rgba ({}, {}, {}, 15%);\n'.format(bg_r, bg_g, bg_b))
        f.write('    bordercolor:                rgba ({}, {}, {}, 21%);\n'.format(bg_r, bg_g, bg_b))
        f.write('    separatorcolor:              rgba ({}, {}, {}, 18%);\n'.format(bg_r, bg_g, bg_b))
        f.write('    alternate-normal-background: rgba ({}, {}, {}, 63%);\n'.format(bg_r, bg_g, bg_b))
        f.write('    alternate-urgent-background: rgba ({}, {}, {}, 18%);\n'.format(bg_r, bg_g, bg_b))
        f.write('    alternate-active-background: rgba ({}, {}, {}, 18%);\n'.format(bg_r, bg_g, bg_b))
        f.write('    alternate-normal-foreground: @foreground;\n')
        f.write('    alternate-urgent-foreground: @urgent-foreground;\n')
        f.write('    alternate-active-foreground: @active-foreground;\n')
        f.write('    spacing:                     1;\n')
        f.write('    background-color:            rgba (0, 0, 0, 0%);\n')
        f.write('    border-color:                @foreground;\n')
        f.write('}\n\n')
        f.write('window {\n')
        f.write('    background-color: @background;\n')
        f.write('    border:           0;\n')
        f.write('    padding:          2;\n')
        f.write('    width:            30%;\n')
        f.write('}\n\n')
        f.write('mainbox {\n')
        f.write('    border:  0;\n')
        f.write('    padding: 0;\n')
        f.write('}\n\n')
        f.write('message {\n')
        f.write('    border:       0;\n')
        f.write('    padding:      0;\n')
        f.write('}\n\n')
        f.write('textbox {\n')
        f.write('    text-color: @foreground;\n')
        f.write('}\n\n')
        f.write('listview {\n')
        f.write('    fixed-height: 0;\n')
        f.write('    border:       0;\n')
        f.write('    spacing:      3px;\n')
        f.write('    scrollbar:    false;\n')
        f.write('    padding:      3px;\n')
        f.write('    columns:      3;\n')
        f.write('    lines:        8;\n')
        f.write('}\n\n')
        f.write('element {\n')
        f.write('    border:            0;\n')
        f.write('    padding:           4px 6px;\n')
        f.write('    background-color:  transparent;\n')
        f.write('    spacing:           0;\n')
        f.write('    margin:            2px 0px;\n')
        f.write('}\n\n')
        f.write('element-text {\n')
        f.write('    background-color: transparent;\n')
        f.write('    text-color:       inherit;\n')
        f.write('    vertical-align:   0.5;\n')
        f.write('    margin:           0px;\n')
        f.write('    padding:          0px;\n')
        f.write('    border:           0;\n')
        f.write('}\n\n')
        f.write('element-icon {\n')
        f.write('    background-color: transparent;\n')
        f.write('    text-color:       inherit;\n')
        f.write('    color:            inherit;\n')
        f.write('    size:             1.5em;\n')
        f.write('    margin:           0px;\n')
        f.write('    padding:          0px;\n')
        f.write('    border:           0;\n')
        f.write('}\n\n')
        f.write('element.normal.normal {\n')
        f.write('    background-color: @background;\n')
        f.write('    text-color:       @normal-foreground;\n')
        f.write('}\n\n')
        f.write('element.normal.urgent {\n')
        f.write('    background-color: @urgent-background;\n')
        f.write('    text-color:       @urgent-foreground;\n')
        f.write('}\n\n')
        f.write('element.normal.active {\n')
        f.write('    background-color: @active-background;\n')
        f.write('    text-color:       @active-foreground;\n')
        f.write('}\n\n')
        f.write('element.selected.normal {\n')
        f.write('    background-color: @selected-normal-background;\n')
        f.write('    text-color:       @selected-normal-foreground;\n')
        f.write('}\n\n')
        f.write('element.selected.urgent {\n')
        f.write('    background-color: @selected-urgent-background;\n')
        f.write('    text-color:       @selected-urgent-foreground;\n')
        f.write('}\n\n')
        f.write('element.selected.active {\n')
        f.write('    background-color: @selected-active-background;\n')
        f.write('    text-color:       @selected-active-foreground;\n')
        f.write('}\n\n')
        f.write('element.alternate.normal {\n')
        f.write('    background-color: @background;\n')
        f.write('    text-color:       @alternate-normal-foreground;\n')
        f.write('}\n\n')
        f.write('element.alternate.urgent {\n')
        f.write('    background-color: @alternate-urgent-background;\n')
        f.write('    text-color:       @alternate-urgent-foreground;\n')
        f.write('}\n\n')
        f.write('element.alternate.active {\n')
        f.write('    background-color: @alternate-active-background;\n')
        f.write('    text-color:       @alternate-active-foreground;\n')
        f.write('}\n\n')
        f.write('scrollbar {\n')
        f.write('    width:        4px;\n')
        f.write('    border:       0;\n')
        f.write('    handle-width: 8px;\n')
        f.write('    padding:      0;\n')
        f.write('}\n\n')
        f.write('mode-switcher {\n')
        f.write('    border:       0;\n')
        f.write('}\n\n')
        f.write('button.selected {\n')
        f.write('    background-color: @selected-normal-background;\n')
        f.write('    text-color:       @selected-normal-foreground;\n')
        f.write('}\n\n')
        f.write('inputbar {\n')
        f.write('    spacing:    0;\n')
        f.write('    text-color: @normal-foreground;\n')
        f.write('    padding:    10px;\n')
        f.write('    border:     0;\n')
        f.write('}\n\n')
        f.write('case-indicator {\n')
        f.write('    spacing:    0;\n')
        f.write('    text-color: @normal-foreground;\n')
        f.write('}\n\n')
        f.write('entry {\n')
        f.write('    spacing:    0;\n')
        f.write('    text-color: @normal-foreground;\n')
        f.write('}\n\n')
        f.write('prompt {\n')
        f.write('    spacing:    0;\n')
        f.write('    text-color: @normal-foreground;\n')
        f.write('}\n\n')
        f.write('inputbar {\n')
        f.write('    children:   [ prompt,textbox-prompt-colon,entry,case-indicator ];\n')
        f.write('}\n\n')
        f.write('textbox-prompt-colon {\n')
        f.write('    expand:     false;\n')
        f.write('    str:        ":";\n')
        f.write('    margin:     0px 0.3em 0em 0em;\n')
        f.write('    text-color: @normal-foreground;\n')
        f.write('}\n')

def generate_wezterm_config(colors, output_file):
    """生成 wezterm 配置文件"""
    if not colors:
        return
    
    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    
    if os.path.islink(output_file):
        os.unlink(output_file)
    
    background = colors.get('wezterm.bg', '#2E3440')
    foreground = colors.get('wezterm.fg', '#D8DEE9')
    cursor_bg = colors.get('wezterm.cursor_bg', foreground)
    
    black = colors.get('wezterm.black', '#4C566A')
    red = colors.get('wezterm.red', '#BF616A')
    green = colors.get('wezterm.green', '#A3BE8C')
    yellow = colors.get('wezterm.yellow', '#EBCB8B')
    blue = colors.get('wezterm.blue', '#81A1C1')
    magenta = colors.get('wezterm.magenta', '#B48EAD')
    cyan = colors.get('wezterm.cyan', '#8FBCBB')
    white = colors.get('wezterm.white', '#ECEFF4')
    
    with open(output_file, 'w') as f:
        f.write('return {\n')
        f.write("  background = '{}',\n".format(background))
        f.write("  foreground = '{}',\n".format(foreground))
        f.write("  cursor_bg = '{}',\n".format(cursor_bg))
        f.write("  cursor_fg = '{}',\n".format(background))
        f.write("  cursor_border = '{}',\n".format(cursor_bg))
        f.write("  ansi = {{ '{}', '{}', '{}', '{}', '{}', '{}', '{}', '{}' }},\n".format(
            black, red, green, yellow, blue, magenta, cyan, white))
        f.write("  brights = {{ '{}', '{}', '{}', '{}', '{}', '{}', '{}', '{}' }},\n".format(
            black, red, green, yellow, blue, magenta, cyan, white))
        f.write('}\n')

def generate_yazi_config(colors, output_file):
    """生成 yazi 配置文件"""
    if not colors:
        return
    
    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    
    if os.path.islink(output_file):
        os.unlink(output_file)
    
    flavor = colors.get('yazi.flavor', 'nord')
    
    with open(output_file, 'w') as f:
        f.write('[flavor]\n')
        f.write('use = "{}"\n\n'.format(flavor))
        f.write('"$schema" = "https://yazi-rs.github.io/schemas/yazi.json"\n\n')

def generate_ps1_config(colors, output_file):
    """生成 PS1 配置文件"""
    if not colors:
        return
    
    dir_color = colors.get('ps1.dir', '#A3BE8C')
    prompt_color = colors.get('ps1.prompt', '#88C0D0')
    branch_color = colors.get('ps1.branch', '#a5aab6')
    
    dir_r, dir_g, dir_b = hex_to_rgb(dir_color)
    prompt_r, prompt_g, prompt_b = hex_to_rgb(prompt_color)
    branch_r, branch_g, branch_b = hex_to_rgb(branch_color)
    
    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    with open(output_file, 'w') as f:
        f.write("PS1='\\[\\033[38;2;{};{};{}m\\]\\w\\[\\033[0m\\]\\[\\033[38;2;{};{};{}m\\]$(__git_branch)\\[\\033[0m\\]\\n\\[\\033[1;38;2;{};{};{}m\\]> \\[\\033[0m\\]'\n".format(
            dir_r, dir_g, dir_b, branch_r, branch_g, branch_b, prompt_r, prompt_g, prompt_b))

def update_gtk2_config(filepath, updates):
    """更新 GTK 2 配置文件，只修改指定的配置项"""
    lines = []
    updated_keys = set()
    
    # 读取现有文件
    if os.path.exists(filepath) and not os.path.islink(filepath):
        with open(filepath, 'r') as f:
            lines = f.readlines()
    
    # 判断值是否应该加引号（数字不加，字符串加）
    def should_quote(v):
        if isinstance(v, (int, bool)):
            return False
        if isinstance(v, str) and v.isdigit():
            return False
        return True
    
    # 更新已有的配置项
    new_lines = []
    for line in lines:
        matched = False
        for key, value in updates.items():
            if line.strip().startswith(key + ' ') or line.strip().startswith(key + '='):
                if should_quote(value):
                    new_lines.append('{} = "{}"\n'.format(key, value))
                else:
                    new_lines.append('{} = {}\n'.format(key, value))
                updated_keys.add(key)
                matched = True
                break
        if not matched:
            new_lines.append(line)
    
    # 添加不存在的配置项
    for key, value in updates.items():
        if key not in updated_keys:
            if should_quote(value):
                new_lines.append('{} = "{}"\n'.format(key, value))
            else:
                new_lines.append('{} = {}\n'.format(key, value))
    
    # 移除可能的多余空行
    while new_lines and new_lines[-1].strip() == '':
        new_lines.pop()
    new_lines.append('\n')
    
    with open(filepath, 'w') as f:
        f.writelines(new_lines)


def update_gtk3_4_config(filepath, updates):
    """更新 GTK 3/4 settings.ini 文件，只修改 [Settings] 中的指定配置项"""
    sections = {}
    current_section = None
    
    # 读取现有文件
    if os.path.exists(filepath) and not os.path.islink(filepath):
        with open(filepath, 'r') as f:
            for line in f:
                line_stripped = line.strip()
                if line_stripped.startswith('[') and line_stripped.endswith(']'):
                    current_section = line_stripped[1:-1]
                    if current_section not in sections:
                        sections[current_section] = []
                    sections[current_section].append(line)
                elif current_section is not None:
                    sections[current_section].append(line)
                else:
                    # 文件开头的注释或空行
                    if '' not in sections:
                        sections[''] = []
                    sections[''].append(line)
    
    # 确保有 Settings 段
    if 'Settings' not in sections:
        sections['Settings'] = ['[Settings]\n']
    
    # 更新 Settings 段中的配置项
    settings_lines = sections['Settings']
    updated_keys = set()
    new_settings = []
    
    for line in settings_lines:
        matched = False
        for key, value in updates.items():
            if '=' in line and line.split('=')[0].strip() == key:
                new_settings.append('{}={}\n'.format(key, value))
                updated_keys.add(key)
                matched = True
                break
        if not matched:
            new_settings.append(line)
    
    # 添加不存在的配置项
    for key, value in updates.items():
        if key not in updated_keys:
            new_settings.append('{}={}\n'.format(key, value))
    
    sections['Settings'] = new_settings
    
    # 写回文件
    with open(filepath, 'w') as f:
        for section_name in sections:
            if section_name != 'Settings':
                f.writelines(sections[section_name])
        f.writelines(sections['Settings'])


def generate_gtk_config(colors, home):
    """生成 GTK 2/3/4 配置文件，只更新需要的配置项"""
    if not colors:
        return
    
    theme = colors.get('gtk.theme', 'Mint-Y-Teal')
    icon_theme = colors.get('gtk.icon_theme', 'Mint-Y-Teal')
    font = colors.get('gtk.font', 'Adwaita Sans 11')
    
    # 确保 prefer_dark_theme 是整数（配置文件中的值可能是字符串）
    prefer_dark_theme_raw = colors.get('gtk.gtk-application-prefer-dark-theme', 0)
    if isinstance(prefer_dark_theme_raw, str):
        prefer_dark_theme = int(prefer_dark_theme_raw) if prefer_dark_theme_raw.strip().isdigit() else 0
    else:
        prefer_dark_theme = int(prefer_dark_theme_raw)
    
    # GTK 2: ~/.gtkrc-2.0
    gtk2_file = os.path.join(home, '.gtkrc-2.0')
    if os.path.islink(gtk2_file):
        os.unlink(gtk2_file)
    
    gtk2_updates = {
        'gtk-theme-name': theme,
        'gtk-icon-theme-name': icon_theme,
        'gtk-font-name': font,
        'gtk-application-prefer-dark-theme': prefer_dark_theme
    }
    update_gtk2_config(gtk2_file, gtk2_updates)
    
    # GTK 3: ~/.config/gtk-3.0/settings.ini
    gtk3_dir = os.path.join(home, '.config/gtk-3.0')
    os.makedirs(gtk3_dir, exist_ok=True)
    
    gtk3_file = os.path.join(gtk3_dir, 'settings.ini')
    if os.path.islink(gtk3_file):
        os.unlink(gtk3_file)
    
    gtk3_updates = {
        'gtk-theme-name': theme,
        'gtk-icon-theme-name': icon_theme,
        'gtk-font-name': font,
        'gtk-application-prefer-dark-theme': prefer_dark_theme
    }
    update_gtk3_4_config(gtk3_file, gtk3_updates)
    
    # GTK 4: ~/.config/gtk-4.0/settings.ini
    gtk4_dir = os.path.join(home, '.config/gtk-4.0')
    os.makedirs(gtk4_dir, exist_ok=True)
    
    gtk4_file = os.path.join(gtk4_dir, 'settings.ini')
    if os.path.islink(gtk4_file):
        os.unlink(gtk4_file)
    
    gtk4_updates = {
        'gtk-theme-name': theme,
        'gtk-icon-theme-name': icon_theme,
        'gtk-font-name': font,
        'gtk-application-prefer-dark-theme': prefer_dark_theme
    }
    update_gtk3_4_config(gtk4_file, gtk4_updates)

def generate_xsettingsd_config(colors, output_file):
    """生成 xsettingsd 配置文件"""
    if not colors:
        return
    
    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    
    if os.path.islink(output_file):
        os.unlink(output_file)
    
    theme = colors.get('gtk.theme', 'Adwaita')
    icon_theme = colors.get('gtk.icon_theme', 'Adwaita')
    font = colors.get('gtk.font', 'Sans 10')
    prefer_dark_theme = colors.get('gtk.gtk-application-prefer-dark-theme', 0)
    with open(output_file, 'w') as f:
        f.write('Net/ThemeName "{}"\n'.format(theme))
        f.write('Net/IconThemeName "{}"\n'.format(icon_theme))
        f.write('Gtk/FontName "{}"\n'.format(font))
        f.write('Gtk/ApplicationPreferDarkTheme {}\n'.format(prefer_dark_theme))

    # Note: gsettings not used here as dwm doesn't run a settings daemon
    # GTK apps will read from ~/.config/gtk-3.0/settings.ini and ~/.config/gtk-4.0/settings.ini
    # For live updates, use xsettingsd (handled by switch-theme.sh)

def main():
    if len(sys.argv) < 2:
        print("Usage: generate-app-themes.py <theme_file>", file=sys.stderr)
        sys.exit(1)
    
    theme_file = sys.argv[1]
    
    if not os.path.isfile(theme_file):
        print("Error: Theme file not found: {}".format(theme_file), file=sys.stderr)
        sys.exit(1)
    
    colors = parse_xresources(theme_file)
    
    home = os.path.expanduser('~')
    
    generate_dunst_config(colors['dunst'], os.path.join(home, '.config/dunst/dunstrc'))
    generate_rofi_config(colors['rofi'], os.path.join(home, '.config/rofi/theme.rasi'))
    generate_wezterm_config(colors['wezterm'], os.path.join(home, '.config/wezterm/theme.lua'))
    generate_yazi_config(colors['yazi'], os.path.join(home, '.config/yazi/theme.toml'))
    generate_ps1_config(colors['ps1'], os.path.join(home, '.bashrc.d/ps1/current'))
    generate_gtk_config(colors['gtk'], home)
    generate_xsettingsd_config(colors['gtk'], os.path.join(home, '.config/xsettingsd/xsettingsd.conf'))
    
    print("Theme configs generated successfully from: {}".format(os.path.basename(theme_file)))

if __name__ == '__main__':
    main()

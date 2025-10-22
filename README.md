# DWM-Mint

这是一个为 Linux Mint 22.2 Cinnamon 定制的 DWM (Dynamic Window Manager) 配置项目。包含了 DWM 主程序、slstatus 状态栏以及相关的配置文件。

## 功能特性

- ✨ 使用 JetBrains Mono Nerd Font 字体
- 🎨 自定义配色方案
- 📊 系统托盘支持 (systray)
- 🔲 窗口间隙 (vanitygaps)
- 🚀 自动启动脚本
- 🎯 状态栏彩色支持
- ⌨️ 优化的快捷键配置
- 🔒 屏幕锁定 (slock)

## 系统要求

- Linux Mint 22.2 Cinnamon (或其他基于 Ubuntu 24.04 的发行版)
- X11 窗口系统

## 依赖软件包

### 1. 编译依赖

这些包是编译 DWM 和 slstatus 所必需的：

```bash
sudo apt install build-essential libxft-dev libxinerama-dev libxrandr-dev
```

**包说明：**
- `build-essential` - 包含 gcc、make 等基本编译工具
- `libxft-dev` - FreeType 字体渲染库（会自动安装 libx11-dev、libfontconfig1-dev 等）
- `libxinerama-dev` - Xinerama 扩展库（多显示器支持，会自动安装相关 X11 依赖）
- `libxrandr-dev` - XRandR 扩展开发库


### 2. 运行时软件

这些是 DWM 运行和使用配置的快捷键所需的软件：

```bash
# 必需软件
sudo apt install rofi alacritty picom feh maim slop xclip xfce4-clipman

# Brave 浏览器（可选，如果不需要可跳过）
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update
sudo apt install brave-browser
```

**软件说明：**
- `rofi` - 应用启动器和电源菜单
- `alacritty` - 高性能 GPU 加速终端模拟器
- `picom` - X11 混成器，提供透明、阴影等效果
- `feh` - 轻量级图片查看器和壁纸设置工具
- `maim` - 截图工具
- `slop` - 区域选择工具（配合 maim 使用）
- `xclip` - 命令行剪贴板工具
- `xfce4-clipman` - 剪贴板管理与同步（修复复制/选择缓冲区不同步问题）
- `brave-browser` - Brave 浏览器（可选）
- `nemo` - 文件管理器（Mint 自带，无需安装）

### 3. 字体安装

DWM 配置使用 JetBrains Mono Nerd Font：

```bash
# 下载并安装 JetBrains Mono Nerd Font
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip
unzip JetBrainsMono.zip
rm JetBrainsMono.zip
fc-cache -fv
```

## 安装步骤

### 1. 克隆仓库

将仓库克隆到家目录：

```bash
cd ~
git clone git@github.com:syaofox/dwm-mint.git
```

或使用 HTTPS：

```bash
cd ~
git clone https://github.com/syaofox/dwm-mint.git
```

### 2. 安装所有依赖

运行上面提到的依赖安装命令，一次性安装所有依赖：

```bash
# 编译依赖
sudo apt install build-essential libxft-dev libxinerama-dev

# 运行时软件
sudo apt install rofi alacritty picom feh maim slop xclip xfce4-clipman
```

### 3. 编译并安装 DWM

```bash
cd ~/dwm-mint/dwm
sudo make clean install
```

### 4. 编译并安装 slstatus

```bash
cd ~/dwm-mint/slstatus
sudo make clean install
```

### 5. 编译并安装 slock

```bash
cd ~/dwm-mint/slock
sudo make clean install
```

### 6. 创建 DWM 会话文件

使用脚本一键创建 `~/.xsession` 与 `/usr/share/xsessions/dwm.desktop`（适配 LightDM，使用 `/etc/X11/Xsession` 自动读取 `~/.xsession`）：

```bash
bash scripts/setup-dwm-session.sh
```

脚本会写入以下内容：

- `~/.xsession`

  ```sh
  #!/bin/sh
  # start GNOME Keyring Daemon and export SSH agent variables
  eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
  export SSH_AUTH_SOCK GNOME_KEYRING_CONTROL GNOME_KEYRING_PID GPG_AGENT_INFO
  exec dwm
  ```

- `/usr/share/xsessions/dwm.desktop`

  ```ini
  [Desktop Entry]
  Name=dwm
  Comment=dynamic window manager
  Exec=/etc/X11/Xsession
  TryExec=/usr/bin/dwm
  Type=XSession
  DesktopNames=dwm
  ```

### 6. 准备壁纸（可选）

如果要使用默认壁纸，确保壁纸文件存在：

```bash
mkdir -p ~/dwm-mint/wallpaper
# 将你的壁纸命名为 eva.jpg 放入 ~/dwm-mint/wallpaper/ 目录
# 或者修改 dotfiles/autostart.sh 中的壁纸路径
```

### 7. 登出并选择 DWM

1. 登出当前会话
2. 在登录界面点击右下角的会话选择器
3. 选择 "DWM"
4. 输入密码登录

## 快捷键说明

> **注意**：MODKEY = Super/Win 键

### 应用启动

| 快捷键 | 功能 |
|--------|------|
| `Super + Space` | 打开 Rofi 应用启动器 |
| `Super + Enter` | 打开终端 (Alacritty) |
| `Super + W` | 打开 Brave 浏览器 |
| `Super + E` | 打开文件管理器 (Nemo) |
| `Super + A` | 区域截图并复制到剪贴板 |
| `Super + Shift + L` | 锁定屏幕 |
| `Super + Shift + E` | 打开电源菜单 (lock/logout/reboot/shutdown) |

### 窗口管理

| 快捷键 | 功能 |
|--------|------|
| `Super + Q` | 关闭当前窗口 |
| `Super + Shift + Q` | 退出 DWM |
| `Super + J` | 焦点移到下一个窗口 |
| `Super + K` | 焦点移到上一个窗口 |
| `Super + H` | 减小主窗口区域 |
| `Super + L` | 增大主窗口区域 |
| `Super + S` | 将当前选中的窗口移到主区域 |
| `Super + P` | 切换当前窗口的浮动状态 |
| `Super + B` | 切换状态栏显示/隐藏 |
| `Super + Tab` | 切换到上一个 tag |

### 布局管理

| 快捷键 | 功能 |
|--------|------|
| `Super + T` | 平铺布局 |
| `Super + F` | 浮动布局 |
| `Super + M` | 单窗口布局 |
| `Super + Shift + Space` | 切换布局 |

### 间隙调整

| 快捷键 | 功能 |
|--------|------|
| `Super + U` | 增加窗口间隙 |
| `Super + Shift + U` | 减少窗口间隙 |
| `Super + 0` | 切换间隙开/关 |
| `Super + Shift + 0` | 重置间隙为默认值 |

### 标签（Tag）操作

| 快捷键 | 功能 |
|--------|------|
| `Super + [1-9]` | 切换到对应标签 |
| `Super + Shift + [1-9]` | 将当前窗口移到对应标签 |
| `Super + Ctrl + [1-9]` | 同时查看多个标签 |

### 多显示器

| 快捷键 | 功能 |
|--------|------|
| `Super + Comma` | 焦点移到上一个显示器 |
| `Super + Period` | 焦点移到下一个显示器 |
| `Super + Shift + Comma` | 将窗口移到上一个显示器 |
| `Super + Shift + Period` | 将窗口移到下一个显示器 |

### 鼠标操作

| 操作 | 功能 |
|------|------|
| `Super + 左键拖动` | 移动窗口 |
| `Super + 右键拖动` | 调整窗口大小 |
| `Super + 中键点击` | 切换窗口浮动状态 |

## 应用规则

以下应用在打开时会自动分配到特定标签或设置为浮动窗口：

- **Brave Browser**: 自动分配到标签 1 (第一个标签)
- **Cursor**: 自动分配到标签 2 (第二个标签)
- **Gimp**: 浮动窗口
- **图片查看器 (Xviewer)**: 浮动窗口
- **计算器**: 浮动窗口
- **Nemo 文件管理器**: 浮动窗口

## 自动启动项

DWM 启动时会自动运行以下程序（见 `dotfiles/autostart.sh`）：

1. **slstatus** - 状态栏
2. **picom** - 混成器（提供窗口特效）
3. **feh** - 设置壁纸
4. **csd-xsettings** - Cinnamon 设置守护进程
5. **csd-cursor** - Cinnamon 光标设置守护进程
6. **xfce4-clipman** - 剪贴板守护进程（自动同步剪贴板）

## 自定义配置

### 修改 DWM 配置

1. 编辑配置文件：
```bash
cd ~/dwm-mint/dwm
nano config.def.h  # 或使用你喜欢的编辑器
```

2. 重新编译安装：
```bash
sudo make clean install
```

3. 重启 DWM：`Super + Shift + Q`（登出后重新登录）

### 修改 slstatus 配置

1. 编辑配置文件：
```bash
cd ~/dwm-mint/slstatus
nano config.h  # 或使用你喜欢的编辑器
```

2. 重新编译安装：
```bash
sudo make clean install
```

3. 重启 slstatus：
```bash
killall slstatus
slstatus &
```

### 修改 slock 配置

1. 编辑配置文件：
```bash
cd ~/dwm-mint/slock
nano config.def.h  # 或使用你喜欢的编辑器
```

2. 重新编译安装：
```bash
sudo make clean install
```

3. 测试锁屏：`Super + Shift + L`

## 故障排除
### 问题：登录界面没有显示 dwm 会话

**解决方案**：
1. 确认 `dwm` 已安装且存在于 `/usr/bin/dwm`
2. 确认 `/usr/share/xsessions/dwm.desktop` 权限为 0644
3. 使用 LightDM 或确保系统走 `/etc/X11/Xsession`

### 问题：`~/.xsession` 没有被执行

**解决方案**：
1. 检查 `~/.xsession` 权限为 0644，内容完整且有换行
2. 查看 `~/.xsession-errors` 获取错误
3. 若非 LightDM，确认显示管理器是否遵循 `/etc/X11/Xsession`

### 问题：编译时提示找不到头文件

**解决方案**：确保安装了所有编译依赖：
```bash
sudo apt install build-essential libxft-dev libxinerama-dev
```

这三个包会自动安装其他所需的开发库（libx11-dev、libfontconfig1-dev 等）。

### 问题：字体显示不正常或显示方框

**解决方案**：
1. 确认已安装 JetBrains Mono Nerd Font
2. 刷新字体缓存：`fc-cache -fv`
3. 验证字体是否可用：`fc-list | grep "JetBrains"`

### 问题：登录后黑屏或无法启动 DWM

**解决方案**：
1. 按 `Ctrl + Alt + F3` 切换到 TTY3`
2. 登录后检查日志：`cat ~/.xsession-errors`
3. 确认 dwm 已正确安装：`which dwm`（应显示 `/usr/local/bin/dwm`）
4. 手动测试启动：`startx /usr/local/bin/dwm`

### 问题：Rofi 无法启动

**解决方案**：
1. 确认已安装 rofi：`which rofi`
2. 检查配置文件是否存在：`ls ~/dwm-mint/dotfiles/rofi.rasi`
3. 手动测试：`rofi -show drun -config ~/dwm-mint/dotfiles/rofi.rasi`

### 问题：截图快捷键不工作

**解决方案**：
确保安装了截图工具链：
```bash
sudo apt install maim slop xclip
```

### 问题：状态栏不显示或 slstatus 无法启动

**解决方案**：
1. 确认 slstatus 已安装：`which slstatus`
2. 手动启动查看错误：`slstatus`
3. 检查是否有多个实例运行：`killall slstatus && slstatus &`

### 问题：系统托盘图标不显示

**解决方案**：
1. 确认配置中 `showsystray` 设置为 1（在 `config.def.h` 中）
2. 某些应用可能不支持系统托盘，这是正常的
3. 重新编译 DWM 并重启

### 问题：壁纸没有显示

**解决方案**：
1. 确认已安装 feh：`sudo apt install feh`
2. 检查壁纸路径是否正确（`~/dwm-mint/wallpaper/eva.jpg`）
3. 手动设置壁纸测试：`feh --bg-scale ~/dwm-mint/wallpaper/eva.jpg`

## 更新

当你修改了配置文件后，需要重新编译：

```bash
# 更新 DWM
cd ~/dwm-mint/dwm
sudo make clean install

# 更新 slstatus
cd ~/dwm-mint/slstatus
sudo make clean install

# 更新 slock
cd ~/dwm-mint/slock
sudo make clean install
```

然后按 `Super + Shift + Q` 登出，重新登录即可应用更改。

## 卸载

如果需要卸载 DWM：

```bash
# 卸载 DWM
cd ~/dwm-mint/dwm
sudo make uninstall

# 卸载 slstatus
cd ~/dwm-mint/slstatus
sudo make uninstall

# 卸载 slock
cd ~/dwm-mint/slock
sudo make uninstall

# 删除会话文件
sudo rm /usr/share/xsessions/dwm.desktop
```

## 参考资源

- [DWM 官方网站](https://dwm.suckless.org/)
- [slstatus 官方网站](https://tools.suckless.org/slstatus/)
- [slock 官方网站](https://tools.suckless.org/slock/)
- [Rofi 文档](https://github.com/davatorium/rofi)
- [Alacritty 文档](https://github.com/alacritty/alacritty)

## 许可证

- DWM: MIT/X Consortium License
- slstatus: ISC License
- slock: MIT/X Consortium License
- 本配置: 遵循上游项目许可证

## 贡献

如有问题或建议，欢迎提交 Issue 或 Pull Request。


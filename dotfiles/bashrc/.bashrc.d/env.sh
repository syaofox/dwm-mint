# Hugging Face 配置
export HF_ENDPOINT=https://hf-mirror.com
export UV_CACHE_DIR="/mnt/github/.caches/uv"

export PATH="$HOME/.local/bin:$PATH"

__git_branch() {
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null || git describe --tags --exact-match 2>/dev/null)
    [[ -n "$branch" ]] && echo " $branch"
}

# PS1 配置动态加载
PS1_LAST_MOD=0

load_ps1() {
    if [ -f "$HOME/.bashrc.d/ps1/current" ]; then
        source "$HOME/.bashrc.d/ps1/current"
    else
        # 默认 PS1（两行: 路径+分支 / 提示符）
        PS1='\033[38;2;163;190;140m\w\033[0m\033[38;2;136;192;208m$(__git_branch)\033[0m\n\033[38;2;235;203;139m> \033[0m'
    fi
}

# 检查并重新加载 PS1 配置（用于 PROMPT_COMMAND）
check_reload_ps1() {
    if [ -f "$HOME/.bashrc.d/ps1/current" ]; then
        local current_mod
        current_mod=$(stat -c %Y "$HOME/.bashrc.d/ps1/current" 2>/dev/null || echo 0)
        if [ "$current_mod" -gt "$PS1_LAST_MOD" ]; then
            load_ps1
            PS1_LAST_MOD=$current_mod
        fi
    fi
}

# 初始加载
load_ps1

# 添加到 PROMPT_COMMAND，每次显示提示符前检查更新
case "$PROMPT_COMMAND" in
    *check_reload_ps1*) ;;
    *) PROMPT_COMMAND="check_reload_ps1${PROMPT_COMMAND:+; $PROMPT_COMMAND}" ;;
esac
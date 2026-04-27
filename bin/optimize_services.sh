#!/bin/bash


# 定义需要处理的服务列表
SERVICES=(
    "cups.service" # 打印服务，通常不需要
    "cups-browsed.service" # 打印机自动发现服务
    "avahi-daemon.service" # 网络服务发现，通常不需要
    "ModemManager.service" # 调制解调器管理服务，通常不需要
    "touchegg.service" # 触控手势服务，如果不使用触控板手势可以禁用
    "thermald.service" # 温度监控服务，如果不需要可以禁用
    "power-profiles-daemon.service" # 电源管理服务，如果不需要可以禁用
    "switcheroo-control.service" # 显卡切换服务，如果不使用双显卡可以禁用
    "openvpn.service" # VPN 服务，如果不使用 VPN 可以禁用
    "anacron.service" # 定时任务服务，如果不需要定时任务可以禁用
    "cron.service" # 另一个定时任务服务，根据需要选择禁用
    "casper.service" # Live CD 相关服务，安装后通常不需要
    "casper-md5check.service" # Live CD 相关服务，安装后通常不需要
)

echo "--- 开始优化系统服务 ---"

for SERVICE in "${SERVICES[@]}"; do
    # 检查服务是否存在
    if sudo systemctl list-unit-files "$SERVICE" >/dev/null 2>&1; then
        echo "[处理中] $SERVICE ..."
        
        # 停止服务
        sudo systemctl stop "$SERVICE" >/dev/null 2>&1
        
        # 屏蔽服务（防止被其他程序唤醒）
        sudo systemctl mask "$SERVICE" >/dev/null 2>&1
        
        echo "[完成] 已停止并屏蔽 $SERVICE"
    else
        echo "[跳过] 系统中未发现 $SERVICE"
    fi
done

echo "--- 优化完成！ ---"
echo "提示：如果需要恢复某个服务，请使用 'sudo systemctl unmask 服务名' 和 'sudo systemctl start 服务名'"
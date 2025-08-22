#!/bin/sh

# 脚本路径：/usr/bin/change_lan_mac.sh
# 功能：准确识别LAN接口并修改其MAC地址

# 方法1：通过UCI配置查找真正的LAN接口
# 查找配置了桥接（bridge）或明确标记为内网的接口
find_lan_interface() {
    # 尝试查找配置了bridge设备的接口
    LAN_IFACE=$(uci show network | grep -E "\.device=.*br-lan" | cut -d '.' -f 2)
    
    if [ -z "$LAN_IFACE" ]; then
        # 尝试查找名为lan的接口
        LAN_IFACE=$(uci show network | grep -E "lan[0-9]*$" | cut -d '.' -f 2 | head -n 1)
    fi
    
    echo "$LAN_IFACE"
}

# 方法2：通过IP地址范围判断（更可靠的方法）
# LAN通常使用私有IP地址段
find_lan_by_ip() {
    # 获取所有启动的接口
    for iface in $(ubus call network.interface dump | jsonfilter -e '@.interface[@.up=true].interface'); do
        # 获取接口的IP地址
        ip_addr=$(uci get network.$iface.ipaddr 2>/dev/null)
        
        # 检查是否是私有IP地址（LAN典型特征）
        if echo "$ip_addr" | grep -qE "^(192\.168|10\.|172\.(1[6-9]|2[0-9]|3[0-1]))"; then
            echo "$iface"
            return 0
        fi
    done
    
    # 如果没有找到，返回空
    echo ""
}

# 优先使用IP地址方法识别LAN接口
LAN_IFACE=$(find_lan_by_ip)

# 如果IP方法失败，则尝试配置方法
if [ -z "$LAN_IFACE" ]; then
    echo "IP方法未找到LAN接口，尝试配置方法..."
    LAN_IFACE=$(find_lan_interface)
fi

# 如果依然未找到，使用一个默认值（通常是lan）并记录警告
if [ -z "$LAN_IFACE" ]; then
    LAN_IFACE="lan"
    echo "警告：无法自动确定LAN接口，将使用默认值 '$LAN_IFACE'"
else
    echo "识别到LAN接口：$LAN_IFACE"
fi

# 生成一个新的合法MAC地址（本地管理地址，以02:开头）
NEW_MAC="02:$(dd bs=1 count=5 if=/dev/random 2>/dev/null | hexdump -v -e '/1 ":%02X"' | cut -c 2-)"
# 或者：在原有MAC基础上修改最后一位
# OLD_MAC=$(uci get network.$LAN_IFACE.macaddr 2>/dev/null)
# NEW_MAC=$(echo $OLD_MAC | awk -F: -v OFS=: '{$NF=sprintf("%02X", (("0x"$NF)+1) % 256); print}')

echo "新MAC地址: $NEW_MAC"

# 使用UCI设置新的MAC地址
if uci get network.$LAN_IFACE >/dev/null 2>&1; then
    uci set network.$LAN_IFACE.macaddr="$NEW_MAC"
    uci commit network
    echo "已成功修改 $LAN_IFACE 的MAC地址。"
else
    echo "错误：UCI配置中未找到接口 '$LAN_IFACE'。"
    exit 1
fi

# 可选：立即重载网络配置，无需等待重启生效
echo "正在重载网络配置..."
/etc/init.d/network reload

# 验证修改
echo "验证新MAC地址:"
ifconfig $BRIDGE_IFACE | grep -i ether

exit 0

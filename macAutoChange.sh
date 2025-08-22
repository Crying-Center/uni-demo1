#!/bin/sh

# 脚本路径：/usr/bin/change_lan_mac.sh
# 功能：自动识别LAN接口并修改其MAC地址

# 方法1：使用Ubus查询网络状态，找到up且protocol为static或dhcp的接口（通常是LAN）
# 更现代且准确的方法
find_lan_interface() {
    ubus call network.interface dump | jsonfilter -e '@.interface[@.up=true && (@.protocol="static" || @.proto="dhcp")].interface'
}

# 方法2（备用）：通过UCI查找配置了'option type bridge'的接口（传统Bridge LAN）
find_bridge_interface() {
    uci show network | grep -E "=interface" | grep -E "lan[0-9]*$" | cut -d '.' -f 2 | head -n 1
    # 如果上述不行，可以尝试查找配置了bridge的接口
    # uci show network | grep -E "\.type=bridge" | cut -d '.' -f 2
}

# 优先使用方法1识别LAN接口
LAN_IFACE=$(find_lan_interface)

# 如果方法1失败，则尝试方法2
if [ -z "$LAN_IFACE" ]; then
    echo "方法1未找到LAN接口，尝试方法2..."
    LAN_IFACE=$(find_bridge_interface)
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

echo "为新MAC地址: $NEW_MAC"

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
# echo "正在重载网络配置..."
# /etc/init.d/network reload

exit 0
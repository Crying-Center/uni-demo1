#!/bin/sh

# 融合脚本 - 提供多个配置选项
# 作者: Eugene
# 日期: 2024-09-04

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 默认配置
DEFAULT_NODE_ID="fJeo25Md"
DEFAULT_NODE_REMARKS="Eugene-UK"
DEFAULT_2G_SSID="Eugene工作室"
DEFAULT_5G_SSID="Eugene工作室-5G"
DEFAULT_PASSWORD="666666666"
TOKEN_1="936052b9-9b2e-4bbf-92da-cc360c8670e1"  # 陈
TOKEN_2="6b22ced7-c723-4dc8-9852-322a707b6f2a"  # zjh
TOKEN_3="4c363078-d90f-43c7-86a8-38bde5221b98"  # 颜

# URL解码函数
url_decode() {
    echo "$1" | sed 's/+/ /g; s/%\([0-9A-F][0-9A-F]\)/\\x\1/g' | xargs -0 printf "%b"
}

# 显示菜单
show_menu() {
    echo -e "${GREEN}=== 配置菜单 ===${NC}"
    echo "1. 陈--快捷设置（wifi+ddnsto+pw）"
    echo "2. 修改wifi"
    echo "3. 设置ddnsto"
    echo "4. 新增节点并应用"
    echo "5. 只导入节点"
    echo -e "${YELLOW}直接回车将选择选项1${NC}"
}

# 配置WiFi函数
setup_wifi() {
    local quick_mode=$1
    
    if [ "$quick_mode" = "true" ]; then
        # 快速模式，使用默认值
        SSID_2G=$DEFAULT_2G_SSID
        SSID_5G=$DEFAULT_5G_SSID
        PASSWORD=$DEFAULT_PASSWORD
        echo -e "${BLUE}使用默认WiFi配置${NC}"
    else
        # 交互模式
        read -p "请输入2.4G WiFi名称（默认: $DEFAULT_2G_SSID）: " input_2g_ssid
        read -p "请输入5G WiFi名称（默认: $DEFAULT_5G_SSID）: " input_5g_ssid
        read -p "请输入WiFi密码（默认: $DEFAULT_PASSWORD）: " input_password

        # 使用用户输入或默认值
        SSID_2G=${input_2g_ssid:-$DEFAULT_2G_SSID}
        SSID_5G=${input_5g_ssid:-$DEFAULT_5G_SSID}
        PASSWORD=${input_password:-$DEFAULT_PASSWORD}
    fi

    # 更新WiFi配置
    uci set wireless.@wifi-iface[0].ssid="$SSID_2G"
    uci set wireless.@wifi-iface[0].key="$PASSWORD"
    uci set wireless.@wifi-iface[1].ssid="$SSID_5G"
    uci set wireless.@wifi-iface[1].key="$PASSWORD"

    # 提交更改并重启无线网络
    uci commit wireless
    wifi reload

    echo -e "${GREEN}WiFi配置已更新：${NC}"
    echo "2.4G: $SSID_2G"
    echo "5G: $SSID_5G"
    echo "密码: $PASSWORD"
}

# 配置DDNSTO函数
setup_ddnsto() {
    local quick_mode=$1
    
    if [ "$quick_mode" = "true" ]; then
        # 快速模式，使用默认token
        SELECTED_TOKEN=$TOKEN_1
        echo -e "${BLUE}使用默认token: 陈${NC}"
    else
        # 交互模式
        echo "请选择token选项："
        echo "1. 陈 (默认)"
        echo "2. zjh"
        echo "3. 颜"
        echo "4. 输入自定义token"
        read -p "请输入选项编号 (1-4) [默认1]: " choice

        # 处理用户选择
        case $choice in
            1|"")
                SELECTED_TOKEN=$TOKEN_1
                echo "已选择: 陈"
                ;;
            2)
                SELECTED_TOKEN=$TOKEN_2
                echo "已选择: zjh"
                ;;
            3)
                SELECTED_TOKEN=$TOKEN_3
                echo "已选择: 颜"
                ;;
            4)
                read -p "请输入自定义token: " custom_token
                SELECTED_TOKEN=$custom_token
                echo "已设置自定义token"
                ;;
            *)
                echo "无效选项，使用默认值(陈)"
                SELECTED_TOKEN=$TOKEN_1
                ;;
        esac
    fi

    # 检查ddnsto配置文件是否存在
    if [ ! -f /etc/config/ddnsto ]; then
        echo -e "${RED}错误: /etc/config/ddnsto 文件不存在!${NC}"
        return 1
    fi

    # 备份原配置文件
    cp /etc/config/ddnsto /etc/config/ddnsto.backup.$(date +%Y%m%d%H%M%S)

    # 更新ddnsto配置
    uci set ddnsto.@ddnsto[0].feat_port='3033'
    uci set ddnsto.@ddnsto[0].feat_enabled='0'
    uci set ddnsto.@ddnsto[0].index='0'
    uci set ddnsto.@ddnsto[0].enabled='1'
    uci set ddnsto.@ddnsto[0].token="$SELECTED_TOKEN"

    # 提交更改
    uci commit ddnsto

    echo -e "${GREEN}ddnsto配置已更新:${NC}"
    echo "token: $SELECTED_TOKEN"

    # 重启ddnsto服务（如果服务存在）
    if [ -f /etc/init.d/ddnsto ]; then
        /etc/init.d/ddnsto restart
        echo "ddnsto服务已重启"
    else
        echo "注意: 未找到ddnsto服务，配置已更新但未重启服务"
    fi
}

# 配置Passwall节点函数
setup_passwall_node() {
    local apply_global=$1
    local quick_mode=$2
    
    if [ "$quick_mode" = "true" ]; then
        # 快速模式，使用默认节点
        echo -e "${BLUE}使用默认节点配置...${NC}"
        
        # 检查默认节点是否已存在，如果存在则删除
        if uci get passwall.$DEFAULT_NODE_ID >/dev/null 2>&1; then
            uci delete passwall.$DEFAULT_NODE_ID
        fi
        
        # 添加默认节点配置
        uci set passwall.$DEFAULT_NODE_ID=nodes
        uci set passwall.$DEFAULT_NODE_ID.remarks="$DEFAULT_NODE_REMARKS"
        uci set passwall.$DEFAULT_NODE_ID.type='sing-box'
        uci set passwall.$DEFAULT_NODE_ID.protocol='vless'
        uci set passwall.$DEFAULT_NODE_ID.address='206.245.238.110'
        uci set passwall.$DEFAULT_NODE_ID.port='45604'
        uci set passwall.$DEFAULT_NODE_ID.uuid='78989a22-52e1-4101-a1cc-e539c004d57c'
        uci set passwall.$DEFAULT_NODE_ID.tls='1'
        uci set passwall.$DEFAULT_NODE_ID.alpn='default'
        uci set passwall.$DEFAULT_NODE_ID.tls_serverName='tesla.com'
        uci set passwall.$DEFAULT_NODE_ID.utls='1'
        uci set passwall.$DEFAULT_NODE_ID.fingerprint='chrome'
        uci set passwall.$DEFAULT_NODE_ID.reality='1'
        uci set passwall.$DEFAULT_NODE_ID.reality_publicKey='Ksvm7_unQR4nijHHOYBKlzzTRTUPPKFaUrMdm80NLBo'
        uci set passwall.$DEFAULT_NODE_ID.reality_shortId='ea44e653'
        uci set passwall.$DEFAULT_NODE_ID.transport='tcp'
        uci set passwall.$DEFAULT_NODE_ID.mux='0'
        
        echo -e "${GREEN}已添加默认节点: $DEFAULT_NODE_ID (备注: $DEFAULT_NODE_REMARKS)${NC}"
        NODE_ID="$DEFAULT_NODE_ID"
    else
        # 交互模式
        read -p "是否输入VLESS节点链接? (直接回车使用默认节点): " vless_link

        if [ -n "$vless_link" ]; then
            # 解析用户输入的VLESS链接
            echo "正在解析VLESS链接..."
            
            # 从链接中提取信息
            uuid=$(echo "$vless_link" | awk -F'@' '{print $1}' | sed 's/vless:\/\///')
            server_info=$(echo "$vless_link" | awk -F'@' '{print $2}' | awk -F'?' '{print $1}')
            address=$(echo "$server_info" | awk -F':' '{print $1}')
            # 提取端口号，移除可能存在的斜杠和路径
            port=$(echo "$server_info" | awk -F':' '{print $2}' | awk -F'/' '{print $1}')
            params=$(echo "$vless_link" | awk -F'?' '{print $2}' | awk -F'#' '{print $1}')
            remarks_encoded=$(echo "$vless_link" | awk -F'#' '{print $2}')
            
            # 解码URL编码的备注
            if [ -n "$remarks_encoded" ]; then
                remarks=$(url_decode "$remarks_encoded")
            else
                remarks=""
            fi
            
            # 如果备注为空，使用随机值
            if [ -z "$remarks" ]; then
                remarks="Node_$(head -c 100 /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 8)"
            fi
            
            # 解析参数
            type=$(echo "$params" | tr '&' '\n' | grep 'type=' | cut -d'=' -f2)
            security=$(echo "$params" | tr '&' '\n' | grep 'security=' | cut -d'=' -f2)
            pbk=$(echo "$params" | tr '&' '\n' | grep 'pbk=' | cut -d'=' -f2)
            fp=$(echo "$params" | tr '&' '\n' | grep 'fp=' | cut -d'=' -f2)
            sni=$(echo "$params" | tr '&' '\n' | grep 'sni=' | cut -d'=' -f2)
            sid=$(echo "$params" | tr '&' '\n' | grep 'sid=' | cut -d'=' -f2)
            
            # 生成随机节点ID
            node_id=$(head -c 100 /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 8)
            
            # 设置节点配置
            uci set passwall.$node_id=nodes
            uci set passwall.$node_id.remarks="$remarks"
            uci set passwall.$node_id.type='sing-box'
            uci set passwall.$node_id.protocol='vless'
            uci set passwall.$node_id.address="$address"
            uci set passwall.$node_id.port="$port"
            uci set passwall.$node_id.uuid="$uuid"
            uci set passwall.$node_id.tls='1'
            uci set passwall.$node_id.alpn='default'
            uci set passwall.$node_id.tls_serverName="$sni"
            uci set passwall.$node_id.utls='1'
            uci set passwall.$node_id.fingerprint="$fp"
            uci set passwall.$node_id.reality='1'
            uci set passwall.$node_id.reality_publicKey="$pbk"
            uci set passwall.$node_id.reality_shortId="$sid"
            uci set passwall.$node_id.transport="$type"
            uci set passwall.$node_id.mux='0'
            
            echo -e "${GREEN}已添加自定义节点: $node_id (备注: $remarks)${NC}"
            NODE_ID="$node_id"
        else
            # 使用默认节点
            echo "使用默认节点配置..."
            
            # 检查默认节点是否已存在，如果存在则删除
            if uci get passwall.$DEFAULT_NODE_ID >/dev/null 2>&1; then
                uci delete passwall.$DEFAULT_NODE_ID
            fi
            
            # 添加默认节点配置
            uci set passwall.$DEFAULT_NODE_ID=nodes
            uci set passwall.$DEFAULT_NODE_ID.remarks="$DEFAULT_NODE_REMARKS"
            uci set passwall.$DEFAULT_NODE_ID.type='sing-box'
            uci set passwall.$DEFAULT_NODE_ID.protocol='vless'
            uci set passwall.$DEFAULT_NODE_ID.address='103.195.190.172'
            uci set passwall.$DEFAULT_NODE_ID.port='58841'
            uci set passwall.$DEFAULT_NODE_ID.uuid='c0a37248-0b0d-4ecb-beeb-76ff9c8f5eac'
            uci set passwall.$DEFAULT_NODE_ID.tls='1'
            uci set passwall.$DEFAULT_NODE_ID.alpn='default'
            uci set passwall.$DEFAULT_NODE_ID.tls_serverName='tesla.com'
            uci set passwall.$DEFAULT_NODE_ID.utls='1'
            uci set passwall.$DEFAULT_NODE_ID.fingerprint='chrome'
            uci set passwall.$DEFAULT_NODE_ID.reality='1'
            uci set passwall.$DEFAULT_NODE_ID.reality_publicKey='zQ0aE1tVll0KIsoDUCbTE6kpqg4coqvp1blzYUlPbCQ'
            uci set passwall.$DEFAULT_NODE_ID.reality_shortId='606beee75848ef0a'
            uci set passwall.$DEFAULT_NODE_ID.transport='tcp'
            uci set passwall.$DEFAULT_NODE_ID.mux='0'
            
            echo -e "${GREEN}已添加默认节点: $DEFAULT_NODE_ID (备注: $DEFAULT_NODE_REMARKS)${NC}"
            NODE_ID="$DEFAULT_NODE_ID"
        fi
    fi

    # 提交更改
    uci commit passwall
    
    # 如果要求应用到全局配置
    if [ "$apply_global" = "true" ]; then
        # 设置全局选项
        uci set passwall.@global[0].enabled='1'
        uci set passwall.@global[0].tcp_node="$NODE_ID"
        uci set passwall.@global[0].udp_node='tcp'
        
        # 提交更改
        uci commit passwall
        
        echo -e "${GREEN}passwall配置已更新:${NC}"
        echo "- 全局设置已启用，TCP节点设置为 $NODE_ID"
        echo "- 已添加节点配置"
        
        # 重启passwall服务（如果服务存在）
        if [ -f /etc/init.d/passwall ]; then
            /etc/init.d/passwall restart
            echo "passwall服务已重启"
        else
            echo "注意: 未找到passwall服务，配置已更新但未重启服务"
        fi
    else
        echo -e "${GREEN}节点已添加但未应用到全局配置${NC}"
    fi
}

# 主菜单处理
show_menu
read -p "请选择操作 [1-5] (默认1): " choice
choice=${choice:-1}

case $choice in
    1)
        echo -e "${BLUE}执行快捷设置（wifi+ddnsto+pw）...${NC}"
        echo -e "${YELLOW}所有配置将使用默认值${NC}"
        setup_wifi "true"
        setup_ddnsto "true"
        
        # 检查passwall配置文件是否存在
        if [ ! -f /etc/config/passwall ]; then
            echo -e "${RED}错误: /etc/config/passwall 文件不存在!${NC}"
            exit 1
        fi
        # 备份原配置文件
        cp /etc/config/passwall /etc/config/passwall.backup.$(date +%Y%m%d%H%M%S)
        
        setup_passwall_node "true" "true"
        echo -e "${GREEN}所有配置已完成！${NC}"
        ;;
    2)
        echo -e "${BLUE}修改WiFi设置...${NC}"
        setup_wifi "false"
        ;;
    3)
        echo -e "${BLUE}设置DDNSTO...${NC}"
        setup_ddnsto "false"
        ;;
    4)
        echo -e "${BLUE}新增节点并应用...${NC}"
        # 检查passwall配置文件是否存在
        if [ ! -f /etc/config/passwall ]; then
            echo -e "${RED}错误: /etc/config/passwall 文件不存在!${NC}"
            exit 1
        fi
        # 备份原配置文件
        cp /etc/config/passwall /etc/config/passwall.backup.$(date +%Y%m%d%H%M%S)
        setup_passwall_node "true" "false"
        ;;
    5)
        echo -e "${BLUE}只导入节点...${NC}"
        # 检查passwall配置文件是否存在
        if [ ! -f /etc/config/passwall ]; then
            echo -e "${RED}错误: /etc/config/passwall 文件不存在!${NC}"
            exit 1
        fi
        # 备份原配置文件
        cp /etc/config/passwall /etc/config/passwall.backup.$(date +%Y%m%d%H%M%S)
        setup_passwall_node "false" "false"
        ;;
    *)
        echo -e "${RED}无效选择，请重新运行脚本并选择1-5之间的选项${NC}"
        exit 1
        ;;
esac

echo -e "${GREEN}操作完成！${NC}"

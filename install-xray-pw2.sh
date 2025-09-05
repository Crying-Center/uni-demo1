#!/bin/sh

# ========================================
# OpenWrt 一键安装脚本
# 作者：clearlove
# ========================================

# 显示菜单函数
show_menu() {
    clear
    echo "========================================"
    echo "           OpenWrt 一键安装脚本"
    echo "               作者：clearlove"
    echo "========================================"
    echo "请选择安装选项："
    echo "1. 安装 Xray"
    echo "2. 安装 Passwall2"
    echo "3. 同时安装 Xray 和 Passwall2"
    echo "4. 退出"
    echo "========================================"
    printf "请输入选择 [1-4]: "
}

# 安装Xray函数
install_xray() {
    echo "[作者：clearlove] 开始安装 Xray..."
    echo "[作者：clearlove] 下载 Xray 安装包..."
    wget -O xray-core.ipk "https://ghfast.top/https://github.com/Crying-Center/uni-demo1/blob/master/xray-core_25.1.30-r1_mipsel_24kc.ipk"
    
    if [ $? -eq 0 ]; then
        echo "[作者：clearlove] 下载完成，开始安装..."
        opkg install xray-core.ipk
        if [ $? -eq 0 ]; then
            echo "[作者：clearlove] Xray 安装成功！"
            rm -f xray-core.ipk
        else
            echo "[作者：clearlove] Xray 安装失败！"
            return 1
        fi
    else
        echo "[作者：clearlove] 下载失败，请检查网络连接！"
        return 1
    fi
    return 0
}

# 安装Passwall2函数
install_pw2() {
    echo "[作者：clearlove] 开始安装 Passwall2..."
    echo "[作者：clearlove] 下载 Passwall2 安装包..."
    wget -O pw2-install.tar.gz "https://ghfast.top/https://github.com/Crying-Center/uni-demo1/raw/refs/heads/master/pw2-install-mipsel_24kc.tar.gz"
    
    if [ $? -eq 0 ]; then
        echo "[作者：clearlove] 下载完成，开始解压..."
        tar -xzf pw2-install.tar.gz
        if [ $? -eq 0 ]; then
            echo "[作者：clearlove] 解压完成，开始安装组件..."
            cd pw2-install-mipsel_24kc
            
            # 安装所有ipk文件
            for pkg in geoview_0.1.10-r1_mipsel_24kc.ipk v2ray-geoip_202506050146.1_all.ipk v2ray-geosite_20250608120644.1_all.ipk luci-24.10_luci-app-passwall2_25.6.21-r1_all.ipk luci-24.10_luci-i18n-passwall2-zh-cn_25.171.82706.aa5e94a_all.ipk; do
                echo "[作者：clearlove] 正在安装 ${pkg}..."
                opkg install $pkg
                if [ $? -ne 0 ]; then
                    echo "[作者：clearlove] ${pkg} 安装失败！"
                    cd ..
                    return 1
                fi
            done
            
            cd ..
            rm -rf pw2-install.tar.gz pw2-install-mipsel_24kc
            echo "[作者：clearlove] Passwall2 安装成功！"
        else
            echo "[作者：clearlove] 解压失败！"
            return 1
        fi
    else
        echo "[作者：clearlove] 下载失败，请检查网络连接！"
        return 1
    fi
    return 0
}

# 主循环
while true; do
    show_menu
    read choice
    case $choice in
        1)
            install_xray
            ;;
        2)
            install_pw2
            ;;
        3)
            install_xray
            if [ $? -eq 0 ]; then
                install_pw2
            else
                echo "[作者：clearlove] Xray 安装失败，跳过 Passwall2 安装"
            fi
            ;;
        4)
            echo "[作者：clearlove] 退出安装脚本"
            exit 0
            ;;
        *)
            echo "[作者：clearlove] 无效选择，请重新输入！"
            sleep 2
            ;;
    esac
    
    echo ""
    echo "[作者：clearlove] 按回车键返回主菜单..."
    read dummy
done
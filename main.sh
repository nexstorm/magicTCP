#!/bin/bash

echo """\
                         __                     
   ____  ___  _  _______/ /_____  _________ ___ 
  / __ \/ _ \| |/_/ ___/ __/ __ \/ ___/ __ \__ \\
 / / / /  __/>  <(__  ) /_/ /_/ / /  / / / / / /
/_/ /_/\___/_/|_/____/\__/\____/_/  /_/ /_/ /_/ 
_________________________________________________
        magicTCP v0.1 | 25/09/2023 edition

"""

install_magictcp_kernel(){
magictcp_kernel_version="6.1.55-magictcp001"
    apt install -y wget
    wget "https://raw.githubusercontent.com/nexstorm/magicTCP/main/kernel/linux-headers-${magictcp_kernel_version}_${magictcp_kernel_version}-4_amd64.deb" -O "linux-headers-${magictcp_kernel_version}.deb"
    wget "https://raw.githubusercontent.com/nexstorm/magicTCP/main/kernel/linux-image-${magictcp_kernel_version}_${magictcp_kernel_version}-4_amd64.deb" -O "linux-image-${magictcp_kernel_version}.deb"
    dpkg -i "linux-headers-${magictcp_kernel_version}.deb"
    dpkg -i "linux-image-${magictcp_kernel_version}.deb"
    rm -rf "linux-headers-${magictcp_kernel_version}.deb"
    rm -rf "linux-image-${magictcp_kernel_version}.deb"

    update-initramfs -c -k ${magictcp_kernel_version}
    update-grub
    reboot
}

apply_tcp_optimization(){
    declare -A params=(
        ["net.ipv4.tcp_rmem"]="8192 262144 536870912"
        ["net.ipv4.tcp_wmem"]="8192 262144 536870912"
        ["net.ipv4.tcp_collapse_max_bytes"]="6291456"
        ["net.ipv4.tcp_notsent_lowat"]="131072"
        ["net.ipv4.tcp_adv_win_scale"]="1"
        ["net.core.default_qdisc"]="fq"
        ["net.ipv4.tcp_congestion_control"]="bbr"
        ["net.ipv4.tcp_window_scaling"]="1"
        ["net.ipv4.conf.all.route_localnet"]="1"
        ["net.ipv4.ip_forward"]="1"
        ["net.ipv4.conf.all.forwarding"]="1"
        ["net.ipv4.conf.default.forwarding"]="1"
        # experimental UDP optimisation
        ["net.ipv4.udp_rmem_min"]="16384"
        ["net.ipv4.udp_wmem_min"]="16384"
        ["net.core.rmem_default"]="26214400"
        ["net.core.rmem_max"]="26214400"
        ["net.core.optmem_max"]="65535"
        ["net.ipv4.udp_mem"]="8192 262144 536870912"
        ["net.core.netdev_max_backlog"]="30000"

    )

    cp /etc/sysctl.conf /etc/sysctl.conf.bak
    for param in "${!params[@]}"; do
        if grep -q "^$param" /etc/sysctl.conf; then
            sed -i "s|^$param.*|$param = ${params[$param]}|" /etc/sysctl.conf
        else
            # If the parameter doesn't exist, add it
            echo "$param = ${params[$param]}" >> /etc/sysctl.conf
        fi
    done

    sysctl -p
}

echo "1. Install magicTCP kernel"
echo "2. Apply TCP optimization"

read -p "Please select :" num
  case "$num" in
  1)
    install_magictcp_kernel
    ;;
  2)
    apply_tcp_optimization
    ;;
  *)
  clear
    echo -e "${Error}:Please select a valid option [1, 2]"
    exit 1
    ;;
  esac
                                                

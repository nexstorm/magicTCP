# magicTCP

This script aims to optimise TCP performance between two hosts.

## Usage
```shell
bash <(curl -sSL https://raw.githubusercontent.com/nexstorm/magicTCP/main/main.sh)
```

## Minimum requirements

- Debian 11
- 500MB of free disk space
- 1GB of RAM

## What this script does

### magicTCP kernel

This is a kernel that is optimised for TCP throughput. It is based on (usually) the latest LTS kernel with patches that optimise parts of the kernel and enable some of the tweaks used.

### Tuning TCP via sysctl.conf

We apply the following changes to your sysctl file when you run the script

```sysctl.conf
net.ipv4.tcp_rmem = 8192 262144 536870912
net.ipv4.tcp_wmem = 8192 262144 536870912
net.ipv4.tcp_adv_win_scale = -2
net.ipv4.tcp_collapse_max_bytes = 6291456
net.ipv4.tcp_notsent_lowat = 131072
net.ipv4.tcp_window_scaling = 1
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
```

1. **net.ipv4.tcp_rmem = 8192 262144 536870912**

   This line specifies the minimum, default, and maximum receive socket buffer sizes for TCP connections. Increasing buffer sizes can help improve performance for high-throughput applications.

2. **net.ipv4.tcp_wmem = 8192 262144 536870912**

   Similar to the previous line, this one sets the minimum, default, and maximum send socket buffer sizes for TCP connections. Increasing these values can allow for larger send buffers, improving the performance of applications that send data over TCP.

3. **net.ipv4.tcp_adv_win_scale = -2**

   Set to 0.25x of memory in the receive buffer to account for the overhead when processing packets. -2 is used to reduce the frequency of TCP collapse

4. **net.ipv4.tcp_collapse_max_bytes = 6291456**

   From [Cloudflare's blog](https://blog.cloudflare.com/optimizing-tcp-for-high-throughput-and-low-latency/)

5. **net.ipv4.tcp_notsent_lowat = 131072**

   This sets the low-water mark for the amount of unsent data in TCP sockets. Raising this threshold can reduce the number of small packets sent.

6. **net.ipv4.tcp_window_scaling = 1**

   Enables TCP window scaling

7. **net.core.default_qdisc = fq**

   Uses fair-queue as the queuing discipline

8. **net.ipv4.tcp_congestion_control = bbr**

   Uses BBR as the CCA. BBR is a Google algorithm that generally has the best throughput. We use it basically because it is unfairly aggressive.

This script also does some tuning to UDP and also enables forwarding.

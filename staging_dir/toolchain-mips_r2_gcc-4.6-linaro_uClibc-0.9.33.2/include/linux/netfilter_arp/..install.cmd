cmd_/home/zhong/openwrt/adjustment/build_dir/toolchain-mips_r2_gcc-4.6-linaro_uClibc-0.9.33.2/linux-dev//include/linux/netfilter_arp/.install := perl scripts/headers_install.pl /home/zhong/openwrt/adjustment/build_dir/toolchain-mips_r2_gcc-4.6-linaro_uClibc-0.9.33.2/linux-3.3.8/include/linux/netfilter_arp /home/zhong/openwrt/adjustment/build_dir/toolchain-mips_r2_gcc-4.6-linaro_uClibc-0.9.33.2/linux-dev//include/linux/netfilter_arp mips arp_tables.h arpt_mangle.h; perl scripts/headers_install.pl /home/zhong/openwrt/adjustment/build_dir/toolchain-mips_r2_gcc-4.6-linaro_uClibc-0.9.33.2/linux-3.3.8/include/linux/netfilter_arp /home/zhong/openwrt/adjustment/build_dir/toolchain-mips_r2_gcc-4.6-linaro_uClibc-0.9.33.2/linux-dev//include/linux/netfilter_arp mips ; perl scripts/headers_install.pl /home/zhong/openwrt/adjustment/build_dir/toolchain-mips_r2_gcc-4.6-linaro_uClibc-0.9.33.2/linux-3.3.8/include/generated/linux/netfilter_arp /home/zhong/openwrt/adjustment/build_dir/toolchain-mips_r2_gcc-4.6-linaro_uClibc-0.9.33.2/linux-dev//include/linux/netfilter_arp mips ; for F in ; do echo "\#include <asm-generic/$$F>" > /home/zhong/openwrt/adjustment/build_dir/toolchain-mips_r2_gcc-4.6-linaro_uClibc-0.9.33.2/linux-dev//include/linux/netfilter_arp/$$F; done; touch /home/zhong/openwrt/adjustment/build_dir/toolchain-mips_r2_gcc-4.6-linaro_uClibc-0.9.33.2/linux-dev//include/linux/netfilter_arp/.install

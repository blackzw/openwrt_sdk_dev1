cmd_/home/zhong/openwrt/adjustment/build_dir/toolchain-mips_r2_gcc-4.6-linaro_uClibc-0.9.33.2/linux-dev//include/linux/netfilter_ipv6/.install := perl scripts/headers_install.pl /home/zhong/openwrt/adjustment/build_dir/toolchain-mips_r2_gcc-4.6-linaro_uClibc-0.9.33.2/linux-3.3.8/include/linux/netfilter_ipv6 /home/zhong/openwrt/adjustment/build_dir/toolchain-mips_r2_gcc-4.6-linaro_uClibc-0.9.33.2/linux-dev//include/linux/netfilter_ipv6 mips ip6_tables.h ip6t_HL.h ip6t_LOG.h ip6t_REJECT.h ip6t_ah.h ip6t_frag.h ip6t_hl.h ip6t_ipv6header.h ip6t_mh.h ip6t_opts.h ip6t_rt.h; perl scripts/headers_install.pl /home/zhong/openwrt/adjustment/build_dir/toolchain-mips_r2_gcc-4.6-linaro_uClibc-0.9.33.2/linux-3.3.8/include/linux/netfilter_ipv6 /home/zhong/openwrt/adjustment/build_dir/toolchain-mips_r2_gcc-4.6-linaro_uClibc-0.9.33.2/linux-dev//include/linux/netfilter_ipv6 mips ; perl scripts/headers_install.pl /home/zhong/openwrt/adjustment/build_dir/toolchain-mips_r2_gcc-4.6-linaro_uClibc-0.9.33.2/linux-3.3.8/include/generated/linux/netfilter_ipv6 /home/zhong/openwrt/adjustment/build_dir/toolchain-mips_r2_gcc-4.6-linaro_uClibc-0.9.33.2/linux-dev//include/linux/netfilter_ipv6 mips ; for F in ; do echo "\#include <asm-generic/$$F>" > /home/zhong/openwrt/adjustment/build_dir/toolchain-mips_r2_gcc-4.6-linaro_uClibc-0.9.33.2/linux-dev//include/linux/netfilter_ipv6/$$F; done; touch /home/zhong/openwrt/adjustment/build_dir/toolchain-mips_r2_gcc-4.6-linaro_uClibc-0.9.33.2/linux-dev//include/linux/netfilter_ipv6/.install

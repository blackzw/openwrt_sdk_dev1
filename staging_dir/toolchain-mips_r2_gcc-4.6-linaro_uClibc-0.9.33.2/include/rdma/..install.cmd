cmd_/home/zhong/openwrt/adjustment/build_dir/toolchain-mips_r2_gcc-4.6-linaro_uClibc-0.9.33.2/linux-dev//include/rdma/.install := perl scripts/headers_install.pl /home/zhong/openwrt/adjustment/build_dir/toolchain-mips_r2_gcc-4.6-linaro_uClibc-0.9.33.2/linux-3.3.8/include/rdma /home/zhong/openwrt/adjustment/build_dir/toolchain-mips_r2_gcc-4.6-linaro_uClibc-0.9.33.2/linux-dev//include/rdma mips ib_user_cm.h ib_user_mad.h ib_user_sa.h ib_user_verbs.h rdma_netlink.h rdma_user_cm.h; perl scripts/headers_install.pl /home/zhong/openwrt/adjustment/build_dir/toolchain-mips_r2_gcc-4.6-linaro_uClibc-0.9.33.2/linux-3.3.8/include/rdma /home/zhong/openwrt/adjustment/build_dir/toolchain-mips_r2_gcc-4.6-linaro_uClibc-0.9.33.2/linux-dev//include/rdma mips ; perl scripts/headers_install.pl /home/zhong/openwrt/adjustment/build_dir/toolchain-mips_r2_gcc-4.6-linaro_uClibc-0.9.33.2/linux-3.3.8/include/generated/rdma /home/zhong/openwrt/adjustment/build_dir/toolchain-mips_r2_gcc-4.6-linaro_uClibc-0.9.33.2/linux-dev//include/rdma mips ; for F in ; do echo "\#include <asm-generic/$$F>" > /home/zhong/openwrt/adjustment/build_dir/toolchain-mips_r2_gcc-4.6-linaro_uClibc-0.9.33.2/linux-dev//include/rdma/$$F; done; touch /home/zhong/openwrt/adjustment/build_dir/toolchain-mips_r2_gcc-4.6-linaro_uClibc-0.9.33.2/linux-dev//include/rdma/.install
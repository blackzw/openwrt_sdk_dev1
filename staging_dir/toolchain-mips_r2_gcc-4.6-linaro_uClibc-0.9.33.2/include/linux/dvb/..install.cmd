cmd_/home/zhong/openwrt/adjustment/build_dir/toolchain-mips_r2_gcc-4.6-linaro_uClibc-0.9.33.2/linux-dev//include/linux/dvb/.install := perl scripts/headers_install.pl /home/zhong/openwrt/adjustment/build_dir/toolchain-mips_r2_gcc-4.6-linaro_uClibc-0.9.33.2/linux-3.3.8/include/linux/dvb /home/zhong/openwrt/adjustment/build_dir/toolchain-mips_r2_gcc-4.6-linaro_uClibc-0.9.33.2/linux-dev//include/linux/dvb mips audio.h ca.h dmx.h frontend.h net.h osd.h version.h video.h; perl scripts/headers_install.pl /home/zhong/openwrt/adjustment/build_dir/toolchain-mips_r2_gcc-4.6-linaro_uClibc-0.9.33.2/linux-3.3.8/include/linux/dvb /home/zhong/openwrt/adjustment/build_dir/toolchain-mips_r2_gcc-4.6-linaro_uClibc-0.9.33.2/linux-dev//include/linux/dvb mips ; perl scripts/headers_install.pl /home/zhong/openwrt/adjustment/build_dir/toolchain-mips_r2_gcc-4.6-linaro_uClibc-0.9.33.2/linux-3.3.8/include/generated/linux/dvb /home/zhong/openwrt/adjustment/build_dir/toolchain-mips_r2_gcc-4.6-linaro_uClibc-0.9.33.2/linux-dev//include/linux/dvb mips ; for F in ; do echo "\#include <asm-generic/$$F>" > /home/zhong/openwrt/adjustment/build_dir/toolchain-mips_r2_gcc-4.6-linaro_uClibc-0.9.33.2/linux-dev//include/linux/dvb/$$F; done; touch /home/zhong/openwrt/adjustment/build_dir/toolchain-mips_r2_gcc-4.6-linaro_uClibc-0.9.33.2/linux-dev//include/linux/dvb/.install

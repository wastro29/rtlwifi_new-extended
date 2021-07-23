# SPDX-License-Identifier: GPL-2.0
SHELL := /bin/sh
CC = gcc
KVER  := $(shell uname -r)
#KVER  :=
KSRC := /lib/modules/$(KVER)/build
#KSRC := /work/linux-src/linux-stable
FIRMWAREDIR := /lib/firmware/
LIB := /lib/
RTL_BT := ./lib/firmware/rtl_bt/
RTLWIFI := ./lib/firmware/rtlwifi/
PWD := $(shell pwd)
CLR_MODULE_FILES := *.mod.c *.mod *.o .*.cmd *.ko *~ .tmp_versions* modules.order Module.symvers
SYMBOL_FILE := Module.symvers
# Handle the move of the entire rtlwifi tree
ifneq ("","$(wildcard /lib/modules/$(KVER)/kernel/drivers/net/wireless/realtek)")
MODDESTDIR := /lib/modules/$(KVER)/kernel/drivers/net/wireless/realtek/rtlwifi
else
MODDESTDIR := /lib/modules/$(KVER)/kernel/drivers/net/wireless/rtlwifi
endif

# Handle the compression option for modules in 3.18+
ifneq ("","$(wildcard $(MODDESTDIR)/*.ko.gz)")
COMPRESS_GZIP := y
endif
ifneq ("","$(wildcard $(MODDESTDIR)/*.ko.xz)")
COMPRESS_XZ := y
endif

ccflags-y += -O2

obj-m		+= rtlwifi.o
rtlwifi-objs	:=		\
		base.o		\
		cam.o		\
		core.o		\
		debug.o		\
		efuse.o		\
		ps.o		\
		rc.o		\
		regd.o		\
		stats.o

rtl8192c_common-objs +=		\

obj-m				+= rtl_pci.o
rtl_pci-objs	:=		pci.o

obj-m				+= rtl_usb.o
rtl_usb-objs	:=		usb.o

obj-m				+= rtl8192c/
obj-m				+= rtl8192ce/
obj-m				+= rtl8192cu/
obj-m				+= rtl8192se/
obj-m				+= rtl8192de/
obj-m				+= rtl8723ae/
obj-m				+= rtl8723be/
obj-m				+= rtl8723de/
obj-m				+= rtl8188ee/
obj-m				+= btcoexist/
obj-m				+= halmac/
obj-m				+= phydm/
obj-m				+= rtl8723com/
obj-m				+= rtl8821ae/
obj-m				+= rtl8822be/
obj-m				+= rtl8192ee/

ccflags-y += -D__CHECK_ENDIAN__
subdir-ccflags-y += -Werror
ccflags-y += -DCONFIG_RTLWIFI_DEBUG
subdir-ccflags-y += -DCONFIG_RTLWIFI_DEBUG

ifeq ("$(KVER)", $(filter "$(KVER)", "3.14.35-031435-generic" "3.14.35-031435-lowlatency"))
ccflags-y += -D_ieee80211_is_robust_mgmt_frame=ieee80211_is_robust_mgmt_frame
subdir-ccflags-y += -D_ieee80211_is_robust_mgmt_frame=ieee80211_is_robust_mgmt_frame
endif

# for uncooked code
uncooked_ccflags-y += -DBT_SUPPORT=1
uncooked_ccflags-y += -DCOEX_SUPPORT=1
uncooked_ccflags-y += -DRTL8822B_SUPPORT=1
uncooked_ccflags-y += -DRTL8723D_SUPPORT=1
ccflags-y += $(uncooked_ccflags-y)
subdir-ccflags-y += $(uncooked_ccflags-y)

CHECKFLAGS += -D__CHECK_ENDIAN__

all:
	$(MAKE) -C $(KSRC) M=$(PWD) modules
install: all

ifeq (,$(wildcard ./backup_drivers.tar))
	@echo Making backups
	@tar cPf backup_drivers.tar $(MODDESTDIR)
	@tar cPf backup_rtlwifi.tar $(FIRMWAREDIR)rtlwifi
	@tar cPf backup_rtl_bt.tar $(FIRMWAREDIR)rtl_bt
	@tar cPf backup_modprobe.tar $(LIB)modprobe.d
endif

	@mkdir -p $(MODDESTDIR)/btcoexist
	@mkdir -p $(MODDESTDIR)/halmac
	@mkdir -p $(MODDESTDIR)/phydm
	@mkdir -p $(MODDESTDIR)/rtl8188ee
	@mkdir -p $(MODDESTDIR)/rtl8192c
	@mkdir -p $(MODDESTDIR)/rtl8192ce
	@mkdir -p $(MODDESTDIR)/rtl8192cu
	@mkdir -p $(MODDESTDIR)/rtl8192de
	@mkdir -p $(MODDESTDIR)/rtl8192ee
	@mkdir -p $(MODDESTDIR)/rtl8192se
	@mkdir -p $(MODDESTDIR)/rtl8723ae
	@mkdir -p $(MODDESTDIR)/rtl8723be
	@mkdir -p $(MODDESTDIR)/rtl8723de
	@mkdir -p $(MODDESTDIR)/rtl8723com
	@mkdir -p $(MODDESTDIR)/rtl8821ae
	@mkdir -p $(MODDESTDIR)/rtl8822be
	@install -p -D -m 644 rtl_pci.ko $(MODDESTDIR)
	@install -p -D -m 644 rtl_usb.ko $(MODDESTDIR)
	@install -p -D -m 644 rtlwifi.ko $(MODDESTDIR)
	@install -p -D -m 644 ./btcoexist/btcoexist.ko $(MODDESTDIR)/btcoexist
	@install -p -D -m 644 ./halmac/halmac.ko $(MODDESTDIR)/halmac
	@install -p -D -m 644 ./phydm/phydm_mod.ko $(MODDESTDIR)/phydm
	@install -p -D -m 644 ./rtl8188ee/rtl8188ee.ko $(MODDESTDIR)/rtl8188ee
	@install -p -D -m 644 ./rtl8192c/rtl8192c-common.ko $(MODDESTDIR)/rtl8192c
	@install -p -D -m 644 ./rtl8192ce/rtl8192ce.ko $(MODDESTDIR)/rtl8192ce
	@install -p -D -m 644 ./rtl8192cu/rtl8192cu.ko $(MODDESTDIR)/rtl8192cu
	@install -p -D -m 644 ./rtl8192de/rtl8192de.ko $(MODDESTDIR)/rtl8192de
	@install -p -D -m 644 ./rtl8192ee/rtl8192ee.ko $(MODDESTDIR)/rtl8192ee
	@install -p -D -m 644 ./rtl8192se/rtl8192se.ko $(MODDESTDIR)/rtl8192se
	@install -p -D -m 644 ./rtl8723ae/rtl8723ae.ko $(MODDESTDIR)/rtl8723ae
	@install -p -D -m 644 ./rtl8723be/rtl8723be.ko $(MODDESTDIR)/rtl8723be
	@install -p -D -m 644 ./rtl8723de/rtl8723de.ko $(MODDESTDIR)/rtl8723de
	@install -p -D -m 644 ./rtl8821ae/rtl8821ae.ko $(MODDESTDIR)/rtl8821ae
	@install -p -D -m 644 ./rtl8822be/rtl8822be.ko $(MODDESTDIR)/rtl8822be
	@install -p -D -m 644 ./rtl8723com/rtl8723-common.ko $(MODDESTDIR)/rtl8723com

ifeq ($(COMPRESS_GZIP), y)
	@gzip -f $(MODDESTDIR)/*.ko
	@gzip -f $(MODDESTDIR)/btcoexist/*.ko
	@gzip -f $(MODDESTDIR)/rtl8*/*.ko
	@gzip -f $(MODDESTDIR)/halmac/*.ko
	@gzip -f $(MODDESTDIR)/phydm/*.ko
endif
ifeq ($(COMPRESS_XZ), y)
	@xz -f $(MODDESTDIR)/*.ko
	@xz -f $(MODDESTDIR)/btcoexist/*.ko
	@xz -f $(MODDESTDIR)/rtl8*/*.ko
	@xz -f $(MODDESTDIR)/halmac/*.ko
	@xz -f $(MODDESTDIR)/phydm/*.ko
endif

	@depmod -a
	
ifeq ("", "$(wildcard $(RTL_BT))")
	@echo Get a file Wait...
	@echo '|'
	@echo '||'
	@mkdir -p $(RTL_BT)
	@mkdir -p $(RTLWIFI)
	@wget -O $(RTL_BT)rtl8723d_config.bin https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/plain/rtl_bt/rtl8723d_config.bin?id=6d5131107f2ba67a13f469ac770a55f101ba654d -q
	@wget -O $(RTL_BT)rtl8723d_fw.bin https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/plain/rtl_bt/rtl8723d_fw.bin?id=6d5131107f2ba67a13f469ac770a55f101ba654d -q
	@wget -O $(RTLWIFI)rtl8723defw.bin https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/plain/rtlwifi/rtl8723defw.bin?id=6d5131107f2ba67a13f469ac770a55f101ba654d -q
	@echo Get a file **FINISH**
else
	@echo File is ready for use.
endif

	@#copy firmware images to target folder
	@cp -fr ./lib/firmware/rtlwifi/ $(FIRMWAREDIR)/
	@cp -fr ./lib/firmware/rtl_bt/ $(FIRMWAREDIR)/
	@cp -fr ./lib/modprobe.d/ $(LIB)/
	@cp -fr ./Realtek-Firmware-License.txt $(FIRMWAREDIR)rtlwifi/
	@echo "Install rtlwifi SUCCESS"

uninstall:

	@rm $(MODDESTDIR)/*.ko*
	@rm $(MODDESTDIR)/btcoexist/*.ko*
	@rm $(MODDESTDIR)/halmac/*.ko*
	@rm $(MODDESTDIR)/phydm/*.ko*
	@rm $(MODDESTDIR)/rtl8188ee/*.ko*
	@rm $(MODDESTDIR)/rtl8192c/*.ko*
	@rm $(MODDESTDIR)/rtl8192ce/*.ko*
	@rm $(MODDESTDIR)/rtl8192cu/*.ko*
	@rm $(MODDESTDIR)/rtl8192de/*.ko*
	@rm $(MODDESTDIR)/rtl8192ee/*.ko*
	@rm $(MODDESTDIR)/rtl8192se/*.ko*
	@rm $(MODDESTDIR)/rtl8723ae/*.ko*
	@rm $(MODDESTDIR)/rtl8723be/*.ko*
	@rm $(MODDESTDIR)/rtl8723de/*.ko*
	@rm $(MODDESTDIR)/rtl8821ae/*.ko*
	@rm $(MODDESTDIR)/rtl8822be/*.ko*
	@rm $(MODDESTDIR)/rtl8723com/*.ko*
	@rm -rf ./lib/firmware/rtl_btn
	@rm -rf ./lib/firmware/rtlwifi

ifneq (,$(wildcard ./backup_drivers.tar))
	@echo Restoring backups
	@tar xvPf backup_drivers.tar
	@tar xvPf backup_rtlwifi.tar
	@tar xvPf backup_rtl_bt.tar
	@tar xvPf backup_modprobe.tar
endif

	@depmod -a

	@echo "Uninstall rtlwifi SUCCESS"

clean:
	@find halmac/ \( -name "*.mod.c" -o -name "*.mod" -o -name "*.o" -o -name ".*.cmd" -o -name "*.ko" -o -name "*~" -o -name "modules.order" -o -name ".*.o.d" \) -exec rm {} \;
	@find phydm/ \( -name "*.mod.c" -o -name "*.mod" -o -name "*.o" -o -name ".*.cmd" -o -name "*.ko" -o -name "*~" -o -name "modules.order" -o -name ".*.o.d" \) -exec rm {} \;
	@rm -fr *.mod.c *.mod *.o .*.cmd *.ko *~ .cache.mk .*.o.d
	@rm -fr rtl8*/*.mod.c rtl8*/*.mod rtl8*/*.o rtl8*/.*.cmd rtl8*/*.ko rtl8*/*~ rtl8*/.*.o.d rtl8*/modules.order
	@rm -fr bt*/*.mod.c bt*/*.mod bt*/*.o bt*/.*.cmd bt*/*.ko bt*/*~ bt*/.*.o.d bt*/modules.order
	@rm -fr tools/*.mod.c tools/*.mod tools/*.o tools/.*.cmd tools/*.ko tools/*~ tools/.*.o.d tools/modules.order
	@rm -fr .tmp_versions
	@rm -fr Modules.symvers
	@rm -fr Module.symvers
	@rm -fr Module.markers
	@rm -fr modules.order

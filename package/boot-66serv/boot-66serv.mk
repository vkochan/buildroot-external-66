################################################################################
#
# boot-66serv
#
################################################################################

BOOT_66SERV_VERSION = v0.1.2.1
BOOT_66SERV_SITE = https://framagit.org/Obarun/boot-66serv.git
BOOT_66SERV_SITE_METHOD = git
BOOT_66SERV_LICENSE = ISC
BOOT_66SERV_LICENSE_FILES = LICENSE
BOOT_66SERV_DEPENDENCIES = host-66

BOOT_66SERV_SVC_DIR = /etc/66/service

BOOT_66SERV_CONF_OPTS = \
	--prefix=/usr \
	--bindir=/bin \
	--with-system-service=$(BOOT_66SERV_SVC_DIR)

define BOOT_66SERV_CONFIGURE_CMDS
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) ./configure $(BOOT_66SERV_CONF_OPTS) \
	)
endef

BOOT_66SERV_SERVICES_DIR = $(TARGET_DIR)/$(BOOT_66SERV_SVC_DIR)/boot

ifeq ($(BR2_PACKAGE_IPTABLES),)

define BOOT_66SERV_FIXUP_IPTABLES
	$(SED) 's/local-iptables//' $(BOOT_66SERV_SERVICES_DIR)/local/local-loop
	$(SED) 's/local-ip6tables//' $(BOOT_66SERV_SERVICES_DIR)/local/local-loop
	$(SED) '/local-iptables/d' $(BOOT_66SERV_SERVICES_DIR)/local/local-rc
	$(SED) '/local-ip6tables/d' $(BOOT_66SERV_SERVICES_DIR)/local/local-rc
	$(SED) '/local-iptables/d' $(BOOT_66SERV_SERVICES_DIR)/all-Local
	$(SED) '/local-ip6tables/d' $(BOOT_66SERV_SERVICES_DIR)/all-Local
	rm $(BOOT_66SERV_SERVICES_DIR)/local/local-iptables
	rm $(BOOT_66SERV_SERVICES_DIR)/local/local-ip6tables
endef

endif #!BR2_PACKAGE_IPTABLES

ifeq ($(BR2_PACKAGE_HAS_UDEV),)

define BOOT_66SERV_FIXUP_UDEV
	$(SED) '/udevd/d' $(BOOT_66SERV_SERVICES_DIR)/all-System
	$(SED) '/udevadm/d' $(BOOT_66SERV_SERVICES_DIR)/all-System
	rm -r $(BOOT_66SERV_SERVICES_DIR)/system/udev
endef

BOOT_66SERV_FIXUP_DEVICES_LIST = \
	devices-btrfs \
	devices-crypttab \
	devices-dmraid \
	devices-lvm

# has dependency on udev
define BOOT_66SERV_FIXUP_DEVICES
	$(foreach d,$(BOOT_66SERV_FIXUP_DEVICES_LIST), \
		$(SED) '/$(d)/d' $(BOOT_66SERV_SERVICES_DIR)/system/system-Devices
		rm $(BOOT_66SERV_SERVICES_DIR)/system/devices/$(d)
	)
endef

endif # !BR2_PACKAGE_HAS_UDEV

define BOOT_66SERV_FIXUP_DMESG
	$(SED) '/--console-off/d' $(BOOT_66SERV_SERVICES_DIR)/local/local-dmesg
endef

define BOOT_66SERV_FIXUP_HWCLOCK
	$(SED) '/system-hwclock/d' $(BOOT_66SERV_SERVICES_DIR)/all-System
	rm $(BOOT_66SERV_SERVICES_DIR)/system/system-hwclock
endef

define BOOT_66SERV_FIXUP_FONTNKEY
	$(SED) '/system-fontnkey/d' $(BOOT_66SERV_SERVICES_DIR)/system/system-fsck
	$(SED) '/system-fontnkey/d' $(BOOT_66SERV_SERVICES_DIR)/all-System
	rm $(BOOT_66SERV_SERVICES_DIR)/system/system-fontnkey
endef

define BOOT_66SERV_FIXUP_SWAP
	$(SED) '/mount-swap/d' $(BOOT_66SERV_SERVICES_DIR)/local/local-rc
	$(SED) '/mount-swap/d' $(BOOT_66SERV_SERVICES_DIR)/all-Local
	rm $(BOOT_66SERV_SERVICES_DIR)/mount/mount-swap
endef

define BOOT_66SERV_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR=$(TARGET_DIR) install

	$(BOOT_66SERV_FIXUP_IPTABLES)
	$(BOOT_66SERV_FIXUP_DEVICES)
	$(BOOT_66SERV_FIXUP_FONTNKEY)
	$(BOOT_66SERV_FIXUP_HWCLOCK)
	$(BOOT_66SERV_FIXUP_DMESG)
	$(BOOT_66SERV_FIXUP_UDEV)
	$(BOOT_66SERV_FIXUP_SWAP)

	rm -f $(BOOT_66SERV_SERVICES_DIR)/earlier-service/tty12
	cp $(BOOT_66SERV_PKGDIR)/66tty \
		$(BOOT_66SERV_SERVICES_DIR)/tty
endef

ifeq ($(BR2_TARGET_GENERIC_GETTY),y)
define BOOT_66SERV_SET_GETTY
	echo '( getty -L $(SYSTEM_GETTY_OPTIONS) $(SYSTEM_GETTY_PORT) $(SYSTEM_GETTY_BAUDRATE) $(SYSTEM_GETTY_TERM) )' >> $(BOOT_66SERV_SERVICES_DIR)/tty
endef
else
define BOOT_66SERV_SET_GETTY
	echo '( getty -L ttyS0 115200 vt100 )' >> $(BOOT_66SERV_SERVICES_DIR)/tty
endef
endif # BR2_TARGET_GENERIC_GETTY
BOOT_66SERV_TARGET_FINALIZE_HOOKS += BOOT_66SERV_SET_GETTY

# it will be re-installed in BOOT_66SERV_PRE_ROOTFS hook,
# but will fail if it already exists
define BOOT_66SERV_DROP_DB
	rm -rf $(TARGET_DIR)/etc/66/conf
	rm -rf $(TARGET_DIR)/var/lib/66
endef
BOOT_66SERV_TARGET_FINALIZE_HOOKS += BOOT_66SERV_DROP_DB

# we need to resolve $(TARGET_PATH) immediately to use it in ROOTFS_PRE_CMD hook
# where $(TARGET_DIR) point to other path
66_ORIG_TARGET_DIR := $(TARGET_DIR)

define BOOT_66SERV_PRE_ROOTFS
	$(HOST_DIR)/bin/66-tree -n boot
	$(HOST_DIR)/bin/66-enable -v 1 -t boot boot
	
	rm $(66_ORIG_TARGET_DIR)/var/lib/66/system/boot/servicedirs/bdb
	rm $(66_ORIG_TARGET_DIR)/var/lib/66/system/boot/servicedirs/bsvc

	ln -sf /var/lib/66/system/backup/boot/db \
		$(66_ORIG_TARGET_DIR)/var/lib/66/system/boot/servicedirs/bdb
	ln -sf /var/lib/66/system/backup/boot/svc \
		$(66_ORIG_TARGET_DIR)/var/lib/66/system/boot/servicedirs/bsvc

	cp -r $(66_ORIG_TARGET_DIR)/var/lib/66 $(TARGET_DIR)/var/lib
	cp -r $(66_ORIG_TARGET_DIR)/var/log/66 $(TARGET_DIR)/var/log
	cp -r $(66_ORIG_TARGET_DIR)/etc/66/conf $(TARGET_DIR)/etc/66
endef
BOOT_66SERV_ROOTFS_PRE_CMD_HOOKS += BOOT_66SERV_PRE_ROOTFS

$(eval $(generic-package))

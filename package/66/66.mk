################################################################################
#
# 66
#
################################################################################

66_VERSION = v0.2.5.2
66_SITE = https://framagit.org/Obarun/66.git
66_SITE_METHOD = git
66_LICENSE = ISC
66_LICENSE_FILES = COPYING
66_DEPENDENCIES = oblibs s6-rc $(if $(BR2_PACKAGE_BUSYBOX),busybox)

66_CONF_OPTS = \
	--prefix=/usr \
	--with-sysdeps=$(STAGING_DIR)/usr/lib/skalibs/sysdeps \
	$(if $(BR2_STATIC_LIBS),,--disable-allstatic) \
	$(SHARED_STATIC_LIBS_OPTS)

define 66_CONFIGURE_CMDS
	(cd $(@D); \
		./tools/gen-deps.sh > package/deps.mak; \
		$(TARGET_CONFIGURE_OPTS) ./configure $(66_CONF_OPTS) \
	)
endef

define 66_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)
endef

define 66_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR=$(TARGET_DIR) install

	$(SED) 's|# redirfd -w 1 /dev/console|redirfd -w 1 /dev/console|g' \
		$(TARGET_DIR)/etc/66/rc.init

	mv $(TARGET_DIR)/etc/66/{init,reboot,poweroff,shutdown,halt} $(TARGET_DIR)/sbin
endef

HOST_66_DEPENDENCIES = host-execline host-oblibs host-s6-rc

# Here is some explanation why some of the host parameters
# points to $(TARGET_DIR):
#     at the final target rootfs preparation (ROOTFS_PRE_CMD hook in
#     boot-66serv/boot-66serv.mk) host-66 is called with host-66-enable to
#     install initial boot tree and services, since it has no arguments to
#     specify these pathes at runtime so we can only specify them at
#     "configure" build stage.
HOST_66_CONF_OPTS = \
	--prefix=$(HOST_DIR) \
	--includedir=$(HOST_DIR)/usr/include \
	--with-sysdeps=$(HOST_DIR)/usr/lib/skalibs/sysdeps \
	--sysconfdir=$(TARGET_DIR)/etc \
	--datarootdir=$(TARGET_DIR)/usr/share \
	--with-skeleton=$(HOST_DIR)/etc/66 \
	--with-system-log=$(TARGET_DIR)/var/log/66 \
	--with-system-dir=$(TARGET_DIR)/var/lib/66 \
	--with-system-service=$(TARGET_DIR)/usr/share/66/service \
	--with-sysadmin-service-conf=$(TARGET_DIR)/etc/66/conf \
	--with-sysadmin-runtime-conf=/etc/66/conf \
	--with-sysadmin-service=$(TARGET_DIR)/etc/66/service \
	$(if $(BR2_STATIC_LIBS),,--disable-allstatic) \
	$(SHARED_STATIC_LIBS_OPTS)

define HOST_66_CONFIGURE_CMDS
	(cd $(@D); \
		./tools/gen-deps.sh > package/deps.mak; \
		$(HOST_CONFIGURE_OPTS) ./configure $(HOST_66_CONF_OPTS) \
	)
endef

define HOST_66_BUILD_CMDS
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D)
endef

define HOST_66_INSTALL_CMDS
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D) install
endef

$(eval $(generic-package))
$(eval $(host-generic-package))

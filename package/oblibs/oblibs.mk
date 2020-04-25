################################################################################
#
# oblibs
#
################################################################################

OBLIBS_VERSION = v0.0.6.0
OBLIBS_SITE = https://framagit.org/Obarun/oblibs.git
OBLIBS_SITE_METHOD = git
OBLIBS_LICENSE = ISC
OBLIBS_LICENSE_FILES = COPYING
OBLIBS_INSTALL_STAGING = YES
OBLIBS_DEPENDENCIES = execline

OBLIBS_CONF_OPTS = \
	--prefix=/usr \
	--with-sysdeps=$(STAGING_DIR)/usr/lib/skalibs/sysdeps \
	$(if $(BR2_STATIC_LIBS),,--disable-allstatic) \
	$(SHARED_STATIC_LIBS_OPTS)

define OBLIBS_CONFIGURE_CMDS
	(cd $(@D); $(TARGET_CONFIGURE_OPTS) ./configure $(OBLIBS_CONF_OPTS))
endef

define OBLIBS_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)
endef

define OBLIBS_INSTALL_STAGING_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
endef

define OBLIBS_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR=$(TARGET_DIR) install
endef

HOST_OBLIBS_DEPENDENCIES = host-execline

HOST_OBLIBS_CONF_OPTS = \
	--prefix=$(HOST_DIR) \
	--with-sysdeps=$(HOST_DIR)/usr/lib/skalibs/sysdeps \
	--disable-static \
	--enable-shared \
	--disable-allstatic

define HOST_OBLIBS_CONFIGURE_CMDS
	(cd $(@D); $(HOST_CONFIGURE_OPTS) ./configure $(HOST_OBLIBS_CONF_OPTS))
endef

define HOST_OBLIBS_BUILD_CMDS
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D)
endef

define HOST_OBLIBS_INSTALL_CMDS
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D) install
endef

$(eval $(generic-package))
$(eval $(host-generic-package))

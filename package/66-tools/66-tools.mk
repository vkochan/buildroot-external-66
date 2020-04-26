################################################################################
#
# 66-tools
#
################################################################################

66_TOOLS_VERSION = v0.0.3.1
66_TOOLS_SITE = https://framagit.org/Obarun/66-tools.git
66_TOOLS_SITE_METHOD = git
66_TOOLS_LICENSE = ISC
66_TOOLS_LICENSE_FILES = COPYING
66_TOOLS_DEPENDENCIES = oblibs

66_TOOLS_CONF_OPTS = \
	--prefix=/usr \
	--with-sysdeps=$(STAGING_DIR)/usr/lib/skalibs/sysdeps \
	$(if $(BR2_STATIC_LIBS),,--disable-allstatic) \
	$(SHARED_STATIC_LIBS_OPTS)

define 66_TOOLS_CONFIGURE_CMDS
	(cd $(@D); \
		./tools/gen-deps.sh > package/deps.mak; \
		$(TARGET_CONFIGURE_OPTS) ./configure $(66_TOOLS_CONF_OPTS) \
	)
endef

define 66_TOOLS_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)
endef

define 66_TOOLS_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR=$(TARGET_DIR) install
endef

$(eval $(generic-package))

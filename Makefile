-include $(CURDIR)/.local.mk

$(if $(BR2_PATH),, $(error Please specify the main Buildroot path via BR2_PATH var))

MAKEARGS := -C $(BR2_PATH)
MAKEARGS += BR2_EXTERNAL=$(CURDIR)

special_target := %_defconfig

.PHONY: $(special_target) $(all)

all := $(filter-out $(special_target),$(MAKECMDGOALS))

%_defconfig:
	$(MAKE) $(MAKEARGS) BR2_DEFCONFIG=$(CURDIR)/configs/$@ \
		O=$(CURDIR)/output/$* defconfig

_all:
	$(MAKE) -C $(O) $(all)

$(all): _all
	@:

PATCH_DIR ?= Patches
do-patch:
	@printf "$$(tput setaf 1)>$$(tput sgr0) \e[1m\e[3mApplying patches…\e[0m\n"
	$(eval ROOTDIR :=$(shell pwd))
	@pushd $(PATCH_DIR) >/dev/null; \
	for dir in *; do \
		for PATCHFILE in $$dir/*.diff; do \
			if [ ! -f "$$PATCHFILE.done" ]; then \
				printf "$$(tput setaf 2)==>$$(tput sgr0) \e[1mApplying patch %s…\e[0m\n" $$PATCHFILE; \
				patch -sN -tp1 -d $(ROOTDIR)/Tweaks/$$dir < $$PATCHFILE; \
				touch $$PATCHFILE.done; \
			fi; \
		done; \
	done; \
	popd >/dev/null

undo-patch:
	@printf "$$(tput setaf 1)>$$(tput sgr0) \e[1m\e[3mUndoing patches…\e[0m\n"
	$(eval ROOTDIR := $(shell pwd))
	@pushd $(PATCH_DIR) >/dev/null; \
	for dir in *; do \
		set -- $$dir/*.diff; \
		eval "set -- $$(awk 'BEGIN {for (i = ARGV[1]; i; i--) printf " \"$${"i"}\""}' "$$#")"; \
		for PATCHFILE in $$@; do \
			if [ -f $$PATCHFILE.done ]; then \
				printf "$$(tput setaf 2)==>$$(tput sgr0) \e[1mUndoing patch %s…\e[0m\n" $$PATCHFILE; \
				patch -R -sN -tp1 -d $(ROOTDIR)/Tweaks/$$dir  < $$PATCHFILE; \
				rm $$PATCHFILE.done; \
			fi; \
		done; \
	done; \
	popd >/dev/null

download-youtube-reborn:
	@printf "$$(tput setaf 1)>$$(tput sgr0) \e[1m\e[3mDownloading YouTube Reborn…\e[0m\n"
	$(eval ROOTDIR := $(shell pwd))
	$(eval TEMPDIR := $(shell mktemp -d))
	
	@printf "$$(tput setaf 6)==>$$(tput sgr0) \e[1mCleaning old YouTube Reborn…\e[0m\n"; \
	find $(ROOTDIR)/Tweaks/Youtube-Reborn/ -mindepth 1 -not -name '.keep' -delete
	
	@printf "$$(tput setaf 2)==>$$(tput sgr0) \e[1mDownloading YouTube Reborn tarball…\e[0m\n"; \
	wget -q -nc -O$(TEMPDIR)/iOS-Tweaks.tar.gz https://github.com/LillieWeeb001/iOS-Tweaks/archive/main.tar.gz

	@printf "$$(tput setaf 4)==>$$(tput sgr0) \e[1mExtracting YouTube Reborn…\e[0m\n"; \
	tar -xzf $(TEMPDIR)/iOS-Tweaks.tar.gz -C $(TEMPDIR); \
	cp -a $(TEMPDIR)/iOS-Tweaks-main/YouTube\ Reborn/. $(ROOTDIR)/Tweaks/Youtube-Reborn; \
	rm -rf $(TEMPDIR) $(ROOTDIR)/$(PATCHDIR)/Youtube-Reborn/*.done


MODULES = jailed
export TARGET := iphone:clang:14.5:14.0
export ARCHS = arm64 arm64e
export GO_EASY_ON_ME = 1
export SIDELOADED = 1

TWEAK_NAME = YoutubeRebornPlus
DISPLAY_NAME ?= YouTube Reborn
BUNDLE_ID ?= com.google.ios.youtube
CODESIGN_IPA ?= 0

include $(THEOS)/makefiles/common.mk
_GIT_IS_INSIDE_WORK_TREE := $(shell git rev-parse --is-inside-work-tree)
_GIT_TAG_NAME := $(shell git name-rev --name-only --tags HEAD)
before-all::
# Git-based versioning
# If not a git repo (downloaded tarball etc.), use version from control file
# If git repo:
# - If on tag, use version from control file
# - If not on tag, use version from control file with added git manfest
#	- Release version is $(PACKAGE_VERSION)+git$(GIT_DATE).$(GIT_COMMIT_HASH)
#	- Debug version is $(PACKAGE_VERSION)-debug.$(_DEBUG_NUMBER)+git$(GIT_DATE).$(GIT_COMMIT_HASH)
# $(_DEBUG_NUMBER) is incremental.
ifeq ($(_GIT_IS_INSIDE_WORK_TREE),true)
ifeq ($(_GIT_TAG_NAME),undefined)
	$(eval _PACKAGE_NAME := YoutubeRebornPlus)
	$(eval _PACKAGE_VERSION := 1.0.0)
	$(eval _GIT_DATE := $(shell git show -s --format=%cs | tr -d "-"))
	$(eval _GIT_COMMIT_HASH := $(shell git rev-parse --short HEAD))
	$(eval THEOS_PACKAGE_BASE_VERSION := $(_PACKAGE_VERSION)+git$(_GIT_DATE).$(_GIT_COMMIT_HASH))
ifeq ($(call __theos_bool,$(or $(debug),$(DEBUG))),$(_THEOS_TRUE))
	$(eval _DEBUG_NUMBER := $(shell THEOS_PROJECT_DIR=$(THEOS_PROJECT_DIR) $(THEOS_BIN_PATH)/package_version.sh -N "" -V ""))
	$(eval _THEOS_INTERNAL_PACKAGE_VERSION := $(_PACKAGE_VERSION)-debug.$(_DEBUG_NUMBER)+git$(_GIT_DATE).$(_GIT_COMMIT_HASH))
else
	$(eval _THEOS_INTERNAL_PACKAGE_VERSION := $(THEOS_PACKAGE_BASE_VERSION))
endif
	$(eval OUTPUT_NAME := $(TWEAK_NAME)$(_THEOS_INTERNAL_PACKAGE_VERSION).ipa)
endif
endif

$(TWEAK_NAME)_USE_FLEX = 0
$(TWEAK_NAME)_FILES = Tweak.xm
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
$(TWEAK_NAME)_FRAMEWORKS = UIKit Foundation
$(TWEAK_NAME)_IPA ?= /path/to/ipa  # Change the path to your decrypted YouTube IPA file here, or specify it with an env variable
$(TWEAK_NAME)_INJECT_DYLIBS = $(THEOS_OBJ_DIR)/libcolorpicker.dylib \
	$(THEOS_OBJ_DIR)/iSponsorBlock.dylib \
	$(THEOS_OBJ_DIR)/YouPiP.dylib \
	$(THEOS_OBJ_DIR)/YouTubeReborn.dylib \
	$(THEOS_OBJ_DIR)/YouTubeDislikesReturn.dylib \
	$(THEOS_OBJ_DIR)/YoutubeSpeed.dylib

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += Tweaks/Alderis Tweaks/iSponsorBlock Tweaks/YouPiP Tweaks/Return-Youtube-Dislikes Tweaks/YTSpeed Tweaks/Youtube-Reborn 
include $(THEOS_MAKE_PATH)/aggregate.mk

before-package::
	@printf "$$(tput setaf 2)==>$$(tput sgr0) \e[1mCopying resources bundles…\e[0m\n"
	@mkdir -p Resources/Frameworks/Alderis.framework && find $(THEOS_OBJ_DIR)/install/Library/Frameworks/Alderis.framework -maxdepth 1 -type f -exec cp {} Resources/Frameworks/Alderis.framework/ \;
	@cp -R Tweaks/iSponsorBlock/layout/var/mobile/Library/Application\ Support/iSponsorBlock Resources/iSponsorBlock.bundle
	@cp -R Tweaks/YouPiP/layout/Library/Application\ Support/YouPiP.bundle Resources/

	@printf "$$(tput setaf 2)==>$$(tput sgr0) \e[1mChanging install name of dylibs…\e[0m\n"
	@install_name_tool -change /usr/lib/libcolorpicker.dylib @rpath/libcolorpicker.dylib $(THEOS_OBJ_DIR)/iSponsorBlock.dylib
	@install_name_tool -change /Library/Frameworks/Alderis.framework/Alderis @rpath/Alderis.framework/Alderis $(THEOS_OBJ_DIR)/libcolorpicker.dylib

before-clean::
	@printf "$$(tput setaf 6)==>$$(tput sgr0) \e[1mDeleting copied resources…\e[0m\n"
	@find Resources -not -name '.keep' -delete

.PHONY: do-patch undo-patch download-youtube-reborn

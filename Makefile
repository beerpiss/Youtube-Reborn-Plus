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
CODESIGN_IPA ?= 

ifeq ($(DEBUG),1)
THEOS_DYLIB_PATH := .theos/obj/debug
else
THEOS_DYLIB_PATH := .theos/obj
endif

$(TWEAK_NAME)_USE_FLEX = 0
$(TWEAK_NAME)_FILES = Tweak.xm
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
$(TWEAK_NAME)_FRAMEWORKS = UIKit Foundation
$(TWEAK_NAME)_IPA ?= /path/to/ipa  # Change the path to your decrypted YouTube IPA file here, or specify it with an env variable
$(TWEAK_NAME)_INJECT_DYLIBS = $(THEOS_DYLIB_PATH)/libcolorpicker.dylib \
	$(THEOS_DYLIB_PATH)/iSponsorBlock.dylib \
	$(THEOS_DYLIB_PATH)/YouPiP.dylib \
	$(THEOS_DYLIB_PATH)/YouTubeReborn.dylib \
	$(THEOS_DYLIB_PATH)/YouTubeDislikesReturn.dylib \
	$(THEOS_DYLIB_PATH)/YoutubeSpeed.dylib

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += Tweaks/Alderis Tweaks/iSponsorBlock Tweaks/YouPiP Tweaks/Return-Youtube-Dislikes Tweaks/YTSpeed Tweaks/Youtube-Reborn 
include $(THEOS_MAKE_PATH)/aggregate.mk

before-package::
	@printf "$$(tput setaf 2)==>$$(tput sgr0) \e[1mCopying resources bundles…\e[0m\n"
	@mkdir -p Resources/Frameworks/Alderis.framework && find $(THEOS_DYLIB_PATH)/install/Library/Frameworks/Alderis.framework -maxdepth 1 -type f -exec cp {} Resources/Frameworks/Alderis.framework/ \;
	@cp -R Tweaks/iSponsorBlock/layout/var/mobile/Library/Application\ Support/iSponsorBlock Resources/iSponsorBlock.bundle
	@cp -R Tweaks/YouPiP/layout/Library/Application\ Support/YouPiP.bundle Resources/

	@printf "$$(tput setaf 2)==>$$(tput sgr0) \e[1mChanging install name of dylibs…\e[0m\n"
	@install_name_tool -change /usr/lib/libcolorpicker.dylib @rpath/libcolorpicker.dylib $(THEOS_DYLIB_PATH)/iSponsorBlock.dylib
	@install_name_tool -change /Library/Frameworks/Alderis.framework/Alderis @rpath/Alderis.framework/Alderis $(THEOS_DYLIB_PATH)/libcolorpicker.dylib

before-clean::
	@printf "$$(tput setaf 6)==>$$(tput sgr0) \e[1mDeleting copied resources…\e[0m\n"
	@find Resources -not -name '.keep' -delete

.PHONY: do-patch undo-patch download-youtube-reborn

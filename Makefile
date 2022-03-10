MODULES = jailed
export TARGET := iphone:clang:14.5:14.0
export ARCHS = arm64
export GO_EASY_ON_ME = 1
export SIDELOADED = 1
export FINALPACKAGE = 1

TWEAK_NAME = YoutubeRebornPlus
DISPLAY_NAME = YouTube Reborn
BUNDLE_ID = com.google.ios.youtube
CODESIGN_IPA = 0

$(TWEAK_NAME)_USE_FLEX = 0
$(TWEAK_NAME)_FILES = Tweak.xm
$(TWEAK_NAME)_IPA = /path/to/ipa  # Change the path to your decrypted YouTube IPA file here.
$(TWEAK_NAME)_INJECT_DYLIBS = .theos/obj/libcolorpicker.dylib .theos/obj/iSponsorBlock.dylib .theos/obj/YouPiP.dylib .theos/obj/YouTubeReborn.dylib .theos/obj/YouTubeDislikesReturn.dylib

do-patch:
	ROOTDIR=$(shell pwd); \
	pushd Patches; \
	for dir in *; do \
		for PATCHFILE in $$dir/*; do \
			if [ ! -f $$PATCHFILE.done ]; then \
				patch -sN -tp1 -d $$ROOTDIR/Tweaks/$$dir  < $$PATCHFILE; \
				touch $$PATCHFILE.done; \
			fi; \
		done; \
	done; \
	popd

download-youtube-reborn:
	ROOTDIR=$(shell pwd); \
	TEMPDIR=$(shell mktemp -d); \
	find $$ROOTDIR/Tweaks/Youtube-Reborn -not -name '.keep' -delete; \
	cd $$TEMPDIR; \
	wget -q -nc -OiOS-Tweaks.tar.gz https://github.com/LillieWeeb001/iOS-Tweaks/archive/main.tar.gz; \
	tar -xzf iOS-Tweaks.tar.gz; \
	cp -a iOS-Tweaks-main/YouTube\ Reborn/. $$ROOTDIR/Tweaks/Youtube-Reborn; \
	cd $$ROOTDIR; \
	rm -rf $$TEMPDIR

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += Tweaks/Alderis Tweaks/iSponsorBlock Tweaks/YouPiP Tweaks/Youtube-Reborn Tweaks/Return-Youtube-Dislikes
include $(THEOS_MAKE_PATH)/aggregate.mk

before-package::
	@mkdir -p Resources/Frameworks/Alderis.framework && find .theos/obj/install/Library/Frameworks/Alderis.framework -maxdepth 1 -type f -exec cp {} Resources/Frameworks/Alderis.framework/ \;
	@cp -R Tweaks/iSponsorBlock/layout/var/mobile/Library/Application\ Support/iSponsorBlock Resources/iSponsorBlock.bundle
	@cp -R Tweaks/YouPiP/layout/Library/Application\ Support/YouPiP.bundle Resources/

	@install_name_tool -change /usr/lib/libcolorpicker.dylib @rpath/libcolorpicker.dylib .theos/obj/iSponsorBlock.dylib
	@install_name_tool -change /Library/Frameworks/Alderis.framework/Alderis @rpath/Alderis.framework/Alderis .theos/obj/libcolorpicker.dylib

before-clean::
	@find Resources -not -name '.keep' -delete
	

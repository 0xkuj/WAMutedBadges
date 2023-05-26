ARCHS = arm64 arm64e
export TARGET = iphone:clang:14.5:14.5
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WAMutedBadges
WAMutedBadges_FILES = Tweak.xm
WAMutedBadges_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

#after-install::
#	install.exec "killall -9 SpringBoard"
SUBPROJECTS += wamutedbadgesprefs
include $(THEOS_MAKE_PATH)/aggregate.mk

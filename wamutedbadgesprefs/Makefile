ARCHS = arm64 arm64e
export TARGET = iphone:clang:14.5:14.5
include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = WAMutedBadgesPrefs

WAMutedBadgesPrefs_FILES = WAMRootListController.m
WAMutedBadgesPrefs_FRAMEWORKS = UIKit
WAMutedBadgesPrefs_PRIVATE_FRAMEWORKS = Preferences
WAMutedBadgesPrefs_INSTALL_PATH = /Library/PreferenceBundles
WAMutedBadgesPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

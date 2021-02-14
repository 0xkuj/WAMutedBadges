ARCHS = arm64 arm64e
TARGET := iphone:clang:latest:7.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = WAMutedBadgesPrefs

WAMutedBadgesPrefs_FILES = WAMRootListController.m
WAMutedBadgesPrefs_FRAMEWORKS = UIKit
WAMutedBadgesPrefs_PRIVATE_FRAMEWORKS = Preferences
WAMutedBadgesPrefs_INSTALL_PATH = /Library/PreferenceBundles
WAMutedBadgesPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

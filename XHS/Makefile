ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = XHSAutoReply

XHSAutoReply_FILES = Tweak.xm XHSAutoReplyConfig.m
XHSAutoReply_CFLAGS = -fobjc-arc
XHSAutoReply_FRAMEWORKS = UIKit Foundation
XHSAutoReply_FILTER_PLIST = XHSAutoReply.plist

include $(THEOS_MAKE_PATH)/tweak.mk

BUNDLE_NAME = XHSAutoReplyPrefs

XHSAutoReplyPrefs_FILES = XHSAutoReplyPrefs.mm XHSAutoReplyConfig.m
XHSAutoReplyPrefs_INSTALL_PATH = /Library/PreferenceBundles
XHSAutoReplyPrefs_FRAMEWORKS = UIKit
XHSAutoReplyPrefs_PRIVATE_FRAMEWORKS = Preferences
XHSAutoReplyPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk 
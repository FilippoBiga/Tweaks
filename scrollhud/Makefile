include theos/makefiles/common.mk

export THEOS_DEVICE_IP=localhost
export THEOS_DEVICE_PORT=2223

export ARCHS=armv7
#export TARGET=iphone:5.0
export TARGET_CC = xcrun -sdk iphoneos clang
export TARGET_CXX = xcrun -sdk iphoneos clang++
export TARGET_LD = xcrun -sdk iphoneos clang++

TWEAK_NAME = ScrollHUD
ScrollHUD_FILES = Tweak.xm MBProgressHUD.m
ScrollHUD_FRAMEWORKS = UIKit CoreGraphics QuartzCore
ScrollHUD_CFLAGS = -fno-objc-arc


include $(THEOS_MAKE_PATH)/tweak.mk

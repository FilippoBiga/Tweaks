export TARGET = iphone:latest:6.0
export ARCHS = armv7 armv7s arm64

export THEOS_DEVICE_IP=localhost
export THEOS_DEVICE_PORT=2225

include theos/makefiles/common.mk

TWEAK_NAME = LastPic
LastPic_FILES = Tweak.xm
LastPic_FRAMEWORKS = UIKit AssetsLibrary

after-install::
	install.exec "killall -9 MobileSMS;"

include $(THEOS_MAKE_PATH)/tweak.mk

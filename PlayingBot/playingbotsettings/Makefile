include theos/makefiles/common.mk

BUNDLE_NAME = PlayingBotSettings
PlayingBotSettings_FILES = PlayingBotSettings.mm
PlayingBotSettings_INSTALL_PATH = /Library/PreferenceBundles
PlayingBotSettings_FRAMEWORKS = UIKit
PlayingBotSettings_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/PlayingBotSettings.plist$(ECHO_END)

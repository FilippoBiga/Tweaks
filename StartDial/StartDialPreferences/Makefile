include theos/makefiles/common.mk

BUNDLE_NAME = StartDialPreferences
StartDialPreferences_FILES = StartDialPreferences.mm
StartDialPreferences_INSTALL_PATH = /Library/PreferenceBundles
StartDialPreferences_FRAMEWORKS = UIKit
StartDialPreferences_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/StartDialPreferences.plist$(ECHO_END)

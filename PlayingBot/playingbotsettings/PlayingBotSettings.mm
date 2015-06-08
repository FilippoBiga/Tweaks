#import <Preferences/Preferences.h>

@interface PlayingBotSettingsListController: PSListController {
}
@end

@implementation PlayingBotSettingsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"PlayingBotSettings" target:self] retain];
	}
	return _specifiers;
}
@end

// vim:ft=objc

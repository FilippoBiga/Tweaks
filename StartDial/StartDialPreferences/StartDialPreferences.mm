#import <Preferences/Preferences.h>

@interface StartDialPreferencesListController: PSListController {
}
@end

@implementation StartDialPreferencesListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"StartDialPreferences" target:self] retain];
	}
	return _specifiers;
}
@end

// vim:ft=objc

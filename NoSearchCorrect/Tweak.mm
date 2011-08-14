#import <UIKit/UIKit.h>

// Only for iOS 4.x. It's already disabled in iOS 5.

@interface ExtendedSearchField : UITextField  @end

%hook ExtendedSearchField

- (BOOL)becomeFirstResponder
{
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    return %orig;
}

%end
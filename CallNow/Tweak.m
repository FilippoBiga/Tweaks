#import <UIKit/UIKit.h>
#import <libactivator/libactivator.h>

@interface UIApplication (CallNow)
-(void)applicationOpenURL:(id)url;
@end

@interface CallNow : NSObject<LAListener, UIAlertViewDelegate, UITextFieldDelegate> {
@private
	UIAlertView *_alert;
    UIAlertView *_falert;
    UITextField *textField;
}
@end

static NSString *typedNumber;

@implementation CallNow

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event
{    
    NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.filippobiga.callnow.plist"];
    NSString *number_ = (id)[dict objectForKey:@"numberString"] ?: @"";
    NSString *name = (id)[dict objectForKey:@"nameString"] ?: @"";
    if ([name isEqualToString:@""]) { name = [NSString stringWithString:number_];}
    
    _alert = [[UIAlertView alloc] initWithTitle:@"CallNow" message:@"What do you want to do?" delegate:self cancelButtonTitle:@"Cancel" 
                                                                                                            otherButtonTitles:[NSString stringWithFormat:@"Call %@", name], 
                                                                                                                              [NSString stringWithFormat:@"Text %@", name], 
                                                                                                                              @"Type another number", 
                                                                                                                              nil];
    [_alert setTag:1];
    [_alert show];
    [_alert release];
    [event setHandled:YES];
}

- (void)alertView:(UIAlertView *)alert didDismissWithButtonIndex:(NSInteger)buttonIndex 
{
    if ([alert tag] == 1)
    {
        NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.filippobiga.callnow.plist"];
        NSString *number_ = (id)[dict objectForKey:@"numberString"] ?: @"";
        
        if ([number_ isEqualToString:@""] && buttonIndex != 0 && buttonIndex != 3)
        {
            _falert = [[UIAlertView alloc] initWithTitle:@"CallNow" message:@"No Number set" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            [_falert show];
            [_falert release];
            return;
        }
        switch(buttonIndex)
        {
            case(1):
                [[UIApplication sharedApplication] applicationOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", number_]]];
                break;
            case(2):
                [[UIApplication sharedApplication] applicationOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms:%@", number_]]];
                break;
            case(3):
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CallNow" message:@"\n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Call", nil];
                textField = [[UITextField alloc] initWithFrame:CGRectMake(12, 45, 260, 25)];
                CGAffineTransform myTransform = CGAffineTransformMakeTranslation(0, -30);
                [alert setTransform:myTransform];
                [textField setBackgroundColor:[UIColor whiteColor]];
                textField.placeholder = @"Enter Number";
                textField.autocorrectionType = UITextAutocorrectionTypeNo;
                textField.clearButtonMode = UITextFieldViewModeWhileEditing;
                
                [textField setDelegate:self];
                [alert addSubview:textField];
                [alert setTag:2];
                [alert show];
                [alert release];
                break;
        }    

    } else if ([alert tag] == 2 && buttonIndex != 0) {
        typedNumber = [NSString stringWithFormat:@"%@", textField.text];
        [[UIApplication sharedApplication] applicationOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", typedNumber]]];
    }
}

+ (void)load
{
    if (![[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"]) { return; }
	NSAutoreleasePool *_p = [[NSAutoreleasePool alloc] init];
	[[LAActivator sharedInstance] registerListener:[self new] forName:@"com.filippobiga.callnow"];
	[_p release];
}

@end

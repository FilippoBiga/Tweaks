#import <UIKit/UIKit.h>
#import <SpringBoard/SpringBoard.h>
#import <objc/runtime.h>
#import <libactivator/libactivator.h>

@interface SBUIController (VolumeTasking)
-(void)programmaticSwitchAppGestureMoveToRight;
-(void)programmaticSwitchAppGestureMoveToLeft;
@end

static BOOL shouldSwitch=NO;

%hook VolumeControl
-(void)increaseVolume
{
    if (shouldSwitch)
    {
        [[objc_getClass("SBUIController") sharedInstance] programmaticSwitchAppGestureMoveToRight];
        return;
    }
    %orig;
}
-(void)decreaseVolume
{
    if (shouldSwitch)
    {
        [[objc_getClass("SBUIController") sharedInstance] programmaticSwitchAppGestureMoveToLeft];
        return;
    }
    %orig;
}
%end

@interface VolumeTasking : NSObject <LAListener> {
@private
	UIAlertView *_alert;
    NSString *message;
}
@end

@implementation VolumeTasking

-(void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event
{
    shouldSwitch=!shouldSwitch;
    
    message = (shouldSwitch) ? @"Enabled" : @"Disabled";
 
    _alert = [[[UIAlertView alloc] initWithTitle:@"VolumeTasking" message:message delegate:nil cancelButtonTitle:nil  otherButtonTitles:nil] autorelease];
    [_alert show];
    [_alert setFrame:CGRectMake(_alert.frame.origin.x,_alert.frame.origin.y,_alert.frame.size.width,(_alert.frame.size.height - 50))]; 
    [_alert performSelector:@selector(dismiss) withObject:nil afterDelay:1.0f];
}

+ (void)load
{
    if (![[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"]) { return; } 
	
    NSAutoreleasePool *_p = [[NSAutoreleasePool alloc] init];
	[[LAActivator sharedInstance] registerListener:[self new] forName:@"com.filippobiga.VolumeTasking"];
	[_p release];
}

@end
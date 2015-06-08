#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface IUMusicViewController : UIViewController

@property (strong, nonatomic,
           getter=__SH_letterHUD,
           setter = __SH_setLetterHUD:) MBProgressHUD *letterHUD;

@property (strong, nonatomic,
           getter=__SH_hudTimer,
           setter = __SH_setHUDTimer:) NSTimer *hudTimer;

@end


static char letterHUDKey;
static char hudTimerKey;

%hook IUMusicViewController

// dynamic letterHUD property
%new(v@:@)
-(void)__SH_setLetterHUD:(MBProgressHUD *)hud
{
    objc_setAssociatedObject(self, &letterHUDKey, hud, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new(@@:)
- (id)__SH_letterHUD {
    return objc_getAssociatedObject(self, &letterHUDKey);
}


// dynamic hudTimer property
%new(v@:@)
-(void)__SH_setHUDTimer:(NSTimer *)timer
{
    objc_setAssociatedObject(self, &hudTimerKey, timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new(@@:)
- (id)__SH_hudTimer {
    return objc_getAssociatedObject(self, &hudTimerKey);
}


- (void)loadView
{
    %orig;
    
    // build our HUD and add it as a subview
    self.letterHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.letterHUD setUserInteractionEnabled:NO];
    [self.letterHUD setMode:MBProgressHUDModeText];
    self.letterHUD.opacity = 0.4f;
    self.letterHUD.minSize = CGSizeMake(100,100);
    self.letterHUD.labelFont = [UIFont boldSystemFontOfSize:48.0f];
    [self.view addSubview:self.letterHUD];
}

- (int)tableView:(id)tableView sectionForSectionIndexTitle:(id)title atIndex:(int)index
{
    // display the HUD just for letters, not for "{search}"
    if ([title length] == 1)
    {
        [self.hudTimer invalidate];
        [self.letterHUD setLabelText:title];
        [self.letterHUD show:YES];
        // automatically hide after 1.0s
        self.hudTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                         target:self
                                                       selector:@selector(hideHUD)
                                                       userInfo:nil
                                                        repeats:NO];
    }
    
    return %orig;
}

// hide the HUD once the timer fires
%new
-(void)hideHUD
{    
    [self.letterHUD hide:YES];
}

// remove the header for every section
- (float)tableView:(id)arg1 heightForHeaderInSection:(int)arg2
{
    return 0.0f;
}

%end
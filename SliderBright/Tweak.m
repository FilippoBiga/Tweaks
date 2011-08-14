#import <UIKit/UIKit.h>
#import <SpringBoard/SpringBoard.h>
#import <libactivator/libactivator.h>

static UISlider *slider=nil;
static BOOL isToggled=NO;

@interface UIApplication (SliderBright)
-(void)setBacklightLevel:(float)level permanently:(BOOL)permanently;
-(float)currentBacklightLevel;
@end

@interface SBIconController (SliderBright)
-(BOOL)hasOpenFolder;
@end

%hook SBUIController
%new(:)
-(void)adjustBrightness
{
    [[UIApplication sharedApplication] setBacklightLevel:slider.value permanently:YES];
}

-(void)finishLaunching
{
    %orig;
    if (slider == nil)
    {
        slider = [[UISlider alloc] initWithFrame: CGRectMake(15.0f, 375.0f, 280.0f, 20.0f)];
        [slider addTarget:self action:@selector(adjustBrightness) forControlEvents:UIControlEventValueChanged];
        [slider setThumbImage:[UIImage imageNamed:@"SwitcherSliderThumb"] forState:UIControlStateNormal];
        [slider setMinimumTrackImage:[UIImage imageNamed:@"SwitcherSliderTrackMin"] forState:UIControlStateNormal];
        [slider setMaximumTrackImage:[UIImage imageNamed:@"SwitcherSliderTrackMax"] forState:UIControlStateNormal];
        [slider setShowValue:NO];
        slider.minimumValue=0.0f;
        slider.maximumValue=1.0f;
        slider.continuous=YES;
        slider.hidden=NO;
        slider.value = [[UIApplication sharedApplication] currentBacklightLevel];
        [[self window] addSubview:slider];
    }
}
-(void)finishedUnscattering
{
    slider.value = [[UIApplication sharedApplication] currentBacklightLevel];
    %orig;
}
%end

%hook SBSearchView
-(void)setShowsKeyboard:(BOOL)keyboard animated:(BOOL)animated
{
    if (!isToggled) { slider.hidden=keyboard; }
    %orig;
}
%end

%hook SBAppSwitcherBarView
-(void)viewWillAppear
{
    slider.hidden=YES;
    %orig;
}
-(void)viewWillDisappear
{
     if (!isToggled) { slider.hidden=NO; }
    %orig;
}
%end

%hook SBFolderIcon
-(void)_delegateOpenFolder:(id)folder animated:(BOOL)animated
{
    slider.hidden=YES;
    %orig;
}
%end
//

%hook SBIconController
-(void)openFolder:(id)folder animated:(BOOL)animated fromSwitcher:(BOOL)switcher
{
    %log;
    %orig;
    slider.hidden=YES;
}
-(void)closeFolderAnimated:(BOOL)animated
{
    %log;
    if (!isToggled) { slider.hidden=NO; }
    %orig;
}
-(void)closeFolderAnimated:(BOOL)animated toSwitcher:(BOOL)switcher
{
    %log;
    if (!slider.hidden && switcher)
    {
        slider.hidden=YES;
    }
    %orig;
}
%end


@interface SliderToggler : NSObject<LAListener> {
}	
@end

@implementation SliderToggler

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event
{
    slider.hidden = !slider.hidden;
    isToggled = !isToggled;
}

+ (void)load
{
    if (![[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"]) {return;}
    // register listener
    NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
	[[LAActivator sharedInstance] registerListener:[self new] forName:@"com.filippobiga.SliderBright"];
	[p release];
}

@end
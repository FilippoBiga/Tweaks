#import <SpringBoard/SpringBoard.h>
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <objc/runtime.h>
#import "Images.h"

#define plistPath @"/var/mobile/Library/Preferences/com.filippobiga.playingbot.plist"


static UIButton *btn;
static UIImage *normalImg, *pressedImg;

@interface PTHSoundEffect : NSObject 
-(BOOL)play;
-(id)initWithCAFFile:(id)caffile;
@end


%hook PTHTweetbotPostToolbarView

-(void)_updateView
{
    %orig;  
    %log;

    NSArray *visibleItems = MSHookIvar<NSArray *>(self,"_visibleSearchItems");

    [btn setAlpha:((!visibleItems || [visibleItems count]==0) ? 1.0f : 0.0f)];
}


-(id)initWithFrame:(CGRect)frame
{
    %log;
    
    btn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
     
    [btn setImage:normalImg forState:UIControlStateNormal]; 
    [btn setImage:pressedImg forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(nowPlayingSong) forControlEvents:UIControlEventTouchUpInside];
    
    btn.frame = CGRectMake(151,((frame.size.width==320.0f)?8:1),32,35);

    [self addSubview:btn];
    return %orig;

}

-(void)setFrame:(CGRect)frame
{
    %log;
    
    if (btn)
    {
        btn.hidden=YES;
        [btn removeFromSuperview];
    }
    
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [btn setImage:normalImg forState:UIControlStateNormal]; 
    [btn setImage:pressedImg forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(nowPlayingSong) forControlEvents:UIControlEventTouchUpInside];
    
    btn.frame = CGRectMake(151,((frame.size.width==320.0f)?8:1),32,35);
    
    [self addSubview:btn];
    
    %orig;
    
}


%new(v@:)
-(void)nowPlayingSong
{
    Class PTHSoundEffect = objc_getClass("PTHSoundEffect");

    PTHSoundEffect *soundEffect = [[PTHSoundEffect alloc] initWithCAFFile:@"button_click"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    MPMediaItem *item = [[MPMusicPlayerController iPodMusicPlayer] nowPlayingItem];
    
    
    [soundEffect play];
    [soundEffect release];

    
    if (item != nil)
    {
        NSString *title,*artist,*firstPart,*secondPart,*playingStr;
        
        id temp;
        
        title = [item valueForProperty:@"title"];
        artist = [item valueForProperty:@"artist"];
        
        temp = [dict objectForKey:@"NPFTFirstPartString"];        
        firstPart = (temp==nil||[temp isEqualToString:@""]) ? @"#nowplaying" : (NSString *)temp;

        temp = [dict objectForKey:@"NPFTSecondPartString"];
        secondPart = (temp==nil||[temp isEqualToString:@""]) ? @"via Tweetbot for iPhone" : (NSString *)temp;
        
        playingStr = (artist!=nil&&![artist isEqualToString:@""]) ? [NSString stringWithFormat:@"%@ %@ by %@ %@",firstPart,title,artist,secondPart] :  [NSString stringWithFormat:@"%@ %@ %@",firstPart,title,secondPart];
        
        UITextView *textVw = MSHookIvar<UITextView *>([self superview], "_textView");
        
        textVw.text = (textVw.text!=nil) ? [NSString stringWithFormat:@"%@ %@", textVw.text, playingStr] : playingStr;
        
    }
    
    [dict release];
    
}


-(CGPoint)_originForIndex:(int)index
{
    %log;
    if (index >= 2)
    { 
        CGPoint orig = %orig;
        orig.x = orig.x + 41;
        return orig;
    }
    return %orig;
}


%end

%ctor 
{
    if (![[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.tapbots.Tweetbot"]){return;}
    normalImg = [[UIImage imageWithData:[NSData dataWithBytes:normalBntImg length:sizeof(normalBntImg)]] retain];
    pressedImg = [[UIImage imageWithData:[NSData dataWithBytes:pressedBtnImg length:sizeof(pressedBtnImg)]] retain];
}
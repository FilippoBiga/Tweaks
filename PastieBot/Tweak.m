#import <SpringBoard/SpringBoard.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <MediaPlayer/MediaPlayer.h>
#import "Images.h"
#import <Foundation/Foundation.h>

#define kHeaderBoundary @"_filippobiga_paste"

@interface PTHSoundEffect : NSObject 
-(BOOL)play;
-(id)initWithCAFFile:(id)caffile;
@end


static NSString *newTweetText,*responseString;
static UIImage *normalImg, *pressedImg;

static UIButton *btn;

UIAlertView *waitAlert;


@interface  PTHTweetbotPostToolbarView : UIView
-(void)submitToPastie:(NSString *)text;
@end



%hook PTHTweetbotPostToolbarView

-(void)_updateView
{
    %log;
    %orig;
    
    NSArray *visibleItems = MSHookIvar<NSArray *>(self,"_visibleSearchItems");
    
    [btn setAlpha:((!visibleItems || [visibleItems count]==0) ? 1.0f : 0.0f)];
}

-(id)initWithFrame:(CGRect)frame
{
    %log;
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];

    [btn setImage:normalImg forState:UIControlStateNormal]; 
    [btn setImage:pressedImg forState:UIControlStateHighlighted];
    
    btn.frame = CGRectMake((([self respondsToSelector:@selector(nowPlayingSong)])?191.0f:151.0f),((frame.size.width==320.0f)?8.0f:1.0f),32,35);

    [btn addTarget:self action:@selector(pastiePost) forControlEvents:UIControlEventTouchUpInside];
    
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
    [btn addTarget:self action:@selector(pastiePost) forControlEvents:UIControlEventTouchUpInside];
    
    btn.frame = CGRectMake((([self respondsToSelector:@selector(nowPlayingSong)])?191.0f:151.0f),((frame.size.width==320.0f)?8.0f:1.0f),32,35);

    [self addSubview:btn];
    
    %orig;
    
}

%new(v@:)
- (void)submitToPastie:(NSString *)text {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:text forKey:@"paste[body]"];
	[dict setObject:@"burger" forKey:@"paste[authorization]"];
	[dict setObject:@"1" forKey:@"paste[restricted]"];
	[dict setObject:@"6" forKey:@"paste[parser_id]"];

     
	NSMutableData *data = [NSMutableData data];
	
    for (NSString *key in [dict allKeys]) {
		[data appendData:[[NSString stringWithFormat:@"--%@\r\n", kHeaderBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[data appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
		[data appendData:[[dict valueForKey:key] dataUsingEncoding:NSUTF8StringEncoding]];
		[data appendData:[[NSString stringWithString:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	}
    
	[data appendData:[[NSString stringWithFormat:@"--%@--\r\n", kHeaderBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://pastie.org/pastes"]];
	NSString *content_type = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", kHeaderBoundary];
	[request addValue:content_type forHTTPHeaderField:@"Content-Type"];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:data];
	[NSURLConnection connectionWithRequest:request delegate:self];



}

%new(v@:)
-(void)pastiePost
{
    Class PTHSoundEffect(objc_getClass("PTHSoundEffect"));
    PTHSoundEffect *soundEffect = [[PTHSoundEffect alloc] initWithCAFFile:@"button_click"];
    [soundEffect play];
    [soundEffect release];
    
    
    UITextView *textVw = (MSHookIvar<UITextView *>([self superview], "_textView"));
    NSString *tweetText = [textVw text];
    
    if (tweetText.length > 140)
    {
        NSLog(@"Got tweetText: %@ (length: %d)",tweetText,tweetText.length);
        
        waitAlert = [[[UIAlertView alloc] initWithTitle:@"Pastie for Tweetbot" message:@"Posting to Pastie.org.." delegate:nil cancelButtonTitle:nil  otherButtonTitles:nil] autorelease];
        [waitAlert show];
        CGRect f= [waitAlert frame];
        f.size.height-=50;
        [waitAlert setFrame:f];
        
        [self submitToPastie:tweetText];
    }
}

%new(v@:)
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Failed");
}

%new(v@:)
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	
    NSLog(@"%@", [response URL]);
    
    UITextView *textVw = (MSHookIvar<UITextView *>([self superview], "_textView"));
    NSString *tweetText = [textVw text];
    if (tweetText.length > 140)
    {
        newTweetText = [NSMutableString stringWithCapacity:118]; 
        int i=0;
        while (i < 85)
        {
            if ([NSString stringWithFormat:@"%C", [tweetText characterAtIndex:i]] != nil)
            {
                if (i==84 && [[NSString stringWithFormat:@"%C", [tweetText characterAtIndex:i]] isEqualToString:@" "])
                {
                    NSLog(@"Ignoring last space");
                } else {
                    newTweetText = [[NSString stringWithFormat:@"%@%C",newTweetText,[tweetText characterAtIndex:i]] retain];             
                }
            }
            i++;
        }
        newTweetText = [[NSString stringWithFormat:@"%@%@",newTweetText,@" (cont)"] retain];
        NSLog(@"newTweetText: %@", newTweetText);
    }
    
    responseString = [[NSString stringWithFormat:@"%@", [[response URL] absoluteString]] retain];
    
   
    newTweetText = [NSString stringWithFormat:@"%@ %@", newTweetText, responseString];
    
    NSLog(@"newTweetText+URL: %@", newTweetText);
    
    if (waitAlert != nil && [waitAlert respondsToSelector:@selector(dismiss)])
    {
        [waitAlert performSelector:@selector(dismiss) withObject:nil afterDelay:0.1f];	
    }
    
    textVw.text = newTweetText;    
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
    if (![[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.tapbots.Tweetbot"]) {return;}
    
    NSAutoreleasePool *p = [NSAutoreleasePool new];
    
    normalImg = [[UIImage imageWithData:[NSData dataWithBytes:normalBntImg length:sizeof(normalBntImg)]] retain];
    pressedImg = [[UIImage imageWithData:[NSData dataWithBytes:pressedBtnImg length:sizeof(pressedBtnImg)]] retain];
    
    [p drain]; 
}


/*
 
 optBtn.frame.origin.x: 110.000000
 optBtn.frame.origin.y: 8.000000
 optBtn.frame.size.width: 32.000000
 optBtn.frame.size.height: 35.000000
 
 */

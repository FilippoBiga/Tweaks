#import <UIKit/UIKit.h>
#import <SpringBoard/SpringBoard.h>
#import <objc/runtime.h>

@interface SBFolderIcon : SBIcon 
-(void)setShowsCloseBox:(BOOL)show;
-(id)folder;
@end

@interface SBFolder : NSObject
-(void)removeEmptyList:(id)list;
-(void)purgeLists;
-(id)lists;
@end

%hook SBFolderIcon
-(void)setIsJittering:(BOOL)jittering
{
    %orig;
    if (jittering)
    {
        [self setShowsCloseBox:YES];
    } else { 
        [self setShowsCloseBox:NO];
    }
}
%end

%hook SBIconController
-(void)uninstallIcon:(id)icon
{
    %orig;
    if ([icon respondsToSelector:@selector(folder)])
    {
        id folder = [icon folder];
        [folder removeEmptyList:[folder lists]];
        [folder purgeLists];
        
        id model = [objc_getClass("SBIconModel") sharedInstance];
        [model saveIconState];
        [model relayout];
    }
}
%end
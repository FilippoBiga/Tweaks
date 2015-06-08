#import <UIKit/UIKit.h>
#import <ChatKit/ChatKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface CKTranscriptController (iOS6)
- (id)_entryView;
@end

@interface CKTranscriptController (iOS7)
@property(retain, nonatomic) CKMessageEntryView *entryView; // @synthesize entryView=_entryView;
@end

@interface CKMessageEntryContentView : UIScrollView
@end

static const int kUseLastPhotoActionSheetTag = 15494;
static CKTranscriptController *transcriptController = nil;
static BOOL isShowingMediaSourceSelectionSheet = NO;

%hook UIActionSheet

-(void)presentSheetInView:(UIView *)view
{
    if (isShowingMediaSourceSelectionSheet)
    {
        [self addButtonWithTitle:@"Use Last Photo Taken"];
        
        id useLastBtn= [[self buttons] lastObject];
        
        [[self buttons] removeObject:useLastBtn];
        [[self buttons] insertObject:useLastBtn atIndex:0];
        
        self.cancelButtonIndex = self.numberOfButtons-1;
        self.tag = kUseLastPhotoActionSheetTag;
    }
    
    %orig;
}

static UITextView *getTextView(CKTranscriptController *self)
{
    CKMessageEntryView *entryView = nil;
    UITextView *textView = nil;
    
    if ([transcriptController respondsToSelector:@selector(_entryView)])
    {
        entryView = [transcriptController _entryView];
        CKContentEntryView *contentEntry = MSHookIvar<CKContentEntryView *>(entryView,"_contentField");
        textView = MSHookIvar<UITextView *>(contentEntry,"_textView");
        
    } else {
        entryView = transcriptController.entryView;
        CKMessageEntryContentView *contentView = MSHookIvar<CKMessageEntryContentView *>(entryView,"_contentView");
        textView = MSHookIvar<UITextView *>(contentView,"_textView");
        
    }
    
    return textView;
}

- (void)dismissWithClickedButtonIndex:(int)index animated:(BOOL)animated
{
    %orig;
    
    if (animated && index == 3 && [self tag] == kUseLastPhotoActionSheetTag)
    {
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
        
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *_stop) {
            
            if ([group numberOfAssets] > 0)
            {
                [group enumerateAssetsWithOptions:NSEnumerationReverse
                                       usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop){
                                           
                                           NSString *type = [result valueForProperty:ALAssetPropertyType];
                                           if ([type isEqualToString:ALAssetTypePhoto])
                                           {
                                               UIImage *lastImg = [UIImage imageWithCGImage:[[result defaultRepresentation] fullScreenImage]];
                                               NSData *pbData = UIImagePNGRepresentation(lastImg);
                                               
                                               if (pbData != nil)
                                               {
                                                   UITextView *textView = getTextView(transcriptController);
                                                   
                                                   if (%c(CKContentEntryView)) // iOS 6
                                                   {
                                                       UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                                                       
                                                       id pasteboardType = [UIPasteboardTypeListImage objectAtIndex:0];
                                                       id currentPb = [pasteboard items];
                                                       
                                                       [pasteboard setData:pbData forPasteboardType:pasteboardType];
                                                       
                                                       [textView paste:nil];

                                                       if (currentPb != nil)
                                                       {
                                                           [pasteboard setItems:currentPb];
                                                       }

                                                   } else { // iOS 7
                                                       
                                                       [transcriptController imagePickerController:nil
                                                                     didFinishPickingMediaWithInfo:@{
                                                                                                     @"UIImagePickerControllerMediaType" : @"public.image",
                                                                                                     @"_UIImagePickerControllerOriginalImageData" : pbData
                                                                                                     }];
                                                   }
                                                   
                                                   [textView becomeFirstResponder];

                                                   *stop = YES;
                                                   *_stop = YES;
                                               }
                                           }
                                       }];
                
            }
            
        } failureBlock:^(NSError *error) {
            
            NSLog(@"error: %@", error);
            
        }];
    }
}

%end


%hook CKTranscriptController

- (void)_showMediaSourceSelectionSheet
{
    transcriptController = self;
    
    isShowingMediaSourceSelectionSheet = YES;
    %orig;
    isShowingMediaSourceSelectionSheet = NO;
}


%end
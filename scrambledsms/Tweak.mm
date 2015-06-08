#import <UIKit/UIKit.h>

// This is the little brother of good old PrivateSMS


static UIBarButtonItem *cachedButton=nil;
static UIBarButtonItem *origButton=nil;
static BOOL scrambled=YES;


static NSString *randomStringOfLength(int length)
{
    static const char *charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    
    NSMutableString *str = [NSMutableString string];
    for (int i = 0; i < length; i++)
    {
        [str appendFormat:@"%c", charset[rand() % (62 - 1)]];
    }
    return str;
}


%hook CKConversationListController

%new
-(void)__scrambleSMS_toggle
{
    scrambled=!scrambled;
    [self setEditing:NO animated:YES];
    [self loadView];
}


-(void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    %orig;
    
    if(editing)
    {
        if (!cachedButton)
        {
            origButton = [[[self navigationItem] rightBarButtonItem] retain];
            cachedButton = [[UIBarButtonItem alloc] initWithTitle:@"Unscramble"
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(__scrambleSMS_toggle)];
        } else {
            
            cachedButton.title = scrambled ? @"Unscramble" : @"Scramble";
        }
        
        [[self navigationItem] setRightBarButtonItem:cachedButton animated:YES];
        
    } else {
        
        [[self navigationItem] setRightBarButtonItem:origButton animated:YES];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *orig = %orig;
    
    if (scrambled)
    {
        UILabel *label = nil;
        
        label = (MSHookIvar<UILabel *>(orig,"_fromLabel"));
        label.text = randomStringOfLength([[label text] length]);
        
        label = (MSHookIvar<UILabel *>(orig,"_summaryLabel"));
        label.text = randomStringOfLength([[label text] length]);
    }
    
    return orig;
}

%end
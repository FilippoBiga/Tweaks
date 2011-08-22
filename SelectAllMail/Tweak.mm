#import <UIKit/UIKit.h>

UIBarButtonItem *selectAllButton;
static BOOL selectedAll=NO;

@interface MailboxContentViewController : UIViewController
- (id)currentTableView;
- (void)tableView:(id)arg1 didSelectRowAtIndexPath:(id)arg2;
- (void)tableView:(id)arg1 didDeselectRowAtIndexPath:(id)arg2;
@end

%hook MailboxContentViewController

%new(v@:)
-(void)toggleSelectAll
{
    selectedAll=!selectedAll;
    [selectAllButton setTitle:(selectedAll?@"Deselect All":@"Select All")];
    [[self currentTableView] reloadData];
}

-(void)_setInEditMode:(BOOL)edit animated:(BOOL)animated
{
    if (edit)
    {
        selectAllButton = [[UIBarButtonItem alloc] initWithTitle:@"Select All" style:UIBarButtonItemStylePlain target:self action:@selector(toggleSelectAll)];
        [[self navigationItem] setLeftBarButtonItem:selectAllButton animated:NO];
    } else {
        [[self navigationItem] setLeftBarButtonItem:nil animated:NO];
        [selectAllButton release];
    }
    
    %orig(edit,animated);
} 


-(id)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (selectedAll)
    {
        [self tableView:tableView didSelectRowAtIndexPath:indexPath];
    } else {
        [self tableView:tableView didDeselectRowAtIndexPath:indexPath];
    }
    
    return %orig;
}

%end
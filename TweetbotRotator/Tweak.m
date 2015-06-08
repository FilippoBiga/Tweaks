#import <UIKit/UIKit.h>

%hook PTHTweetbotMainController
-(BOOL)shouldAutorotateToInterfaceOrientation:(int)interfaceOrientation { return YES; }
%end

%hook PTHTweetbotProfileController
-(BOOL)shouldAutorotateToInterfaceOrientation:(int)interfaceOrientation { return YES; }
%end


%hook PTHTweetbotAccountController
-(BOOL)shouldAutorotateToInterfaceOrientation:(int)interfaceOrientation { return YES; }
%end


%hook PTHTweetbotWebViewController
-(BOOL)shouldAutorotateToInterfaceOrientation:(int)interfaceOrientation { return YES; }
%end


%hook PTHTweetbotUserController
-(BOOL)shouldAutorotateToInterfaceOrientation:(int)interfaceOrientation { return YES; }
%end


%hook PTHTweetbotPostController
-(BOOL)shouldAutorotateToInterfaceOrientation:(int)interfaceOrientation { return YES; }
%end


%hook PTHTweetbotMapViewController
-(BOOL)shouldAutorotateToInterfaceOrientation:(int)interfaceOrientation { return YES; }
%end


%hook PTHTweetbotStatusDetailController
-(BOOL)shouldAutorotateToInterfaceOrientation:(int)interfaceOrientation { return YES; }
%end


%hook PTHTweetbotTableViewController
-(BOOL)shouldAutorotateToInterfaceOrientation:(int)interfaceOrientation { return YES; }
%end


%hook PTHTweetbotEditAccountController
-(BOOL)shouldAutorotateToInterfaceOrientation:(int)interfaceOrientation { return YES; }
%end


%hook PTHTweetbotEditDescriptionController
-(BOOL)shouldAutorotateToInterfaceOrientation:(int)interfaceOrientation { return YES; }
%end


%hook PTHTweetbotCurrentUserSearchController
-(BOOL)shouldAutorotateToInterfaceOrientation:(int)interfaceOrientation { return YES; }
%end


%hook PTHTweetbotPeopleSearchController
-(BOOL)shouldAutorotateToInterfaceOrientation:(int)interfaceOrientation { return YES; }
%end


%hook PTHTweetbotUserListsController
-(BOOL)shouldAutorotateToInterfaceOrientation:(int)interfaceOrientation { return YES; }
%end


%hook PTHTweetbotAddToListController
-(BOOL)shouldAutorotateToInterfaceOrientation:(int)interfaceOrientation { return YES; }
%end


%hook PTHTweetbotMediaViewController
-(BOOL)shouldAutorotateToInterfaceOrientation:(int)interfaceOrientation { return YES; }
%end


%hook PTHTweetbotHashtagsController
-(BOOL)shouldAutorotateToInterfaceOrientation:(int)interfaceOrientation { return YES; }
%end


%hook PTHTweetbotPostDraftsController
-(BOOL)shouldAutorotateToInterfaceOrientation:(int)interfaceOrientation { return YES; }
%end


%hook PTHRootController
-(BOOL)shouldAutorotateToInterfaceOrientation:(int)interfaceOrientation { return YES; }
%end
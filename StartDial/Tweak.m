// 1/24/11 
#import <notify.h>
#import <unistd.h>
#include <sys/param.h>
#include <sys/sysctl.h>
#include <stdio.h>
#include <stdlib.h>

#define register_notify(x, y) CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &y, (CFStringRef)x, NULL, 0)
#define notify_handler(x) static void x(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
static NSString *settingsFile = @"/var/mobile/Library/Preferences/com.filippobiga.startdialpref.plist";

pid_t getProcessId(const char * csProcessName){
	
	struct kinfo_proc *sProcesses = NULL, *sNewProcesses;
	pid_t  iCurrentPid;
	int    aiNames[4];
	size_t iNamesLength;
	int    i, iRetCode, iNumProcs;
	size_t iSize;
	
	iSize = 0;
	aiNames[0] = CTL_KERN;
	aiNames[1] = KERN_PROC;
	aiNames[2] = KERN_PROC_ALL;
	aiNames[3] = 0;
	iNamesLength = 3;
	
	iRetCode = sysctl(aiNames, iNamesLength, NULL, &iSize, NULL, 0);

	do {
		iSize += iSize / 10;
		sNewProcesses =(kinfo_proc*)realloc(sProcesses, iSize);
		
		if (sNewProcesses == 0) {
			if (sProcesses)
				free(sProcesses);
		}
		sProcesses = sNewProcesses;
		iRetCode = sysctl(aiNames, iNamesLength, sProcesses, &iSize, NULL, 0);
	} while (iRetCode == -1 && errno == ENOMEM);
	
	iNumProcs = iSize / sizeof(struct kinfo_proc);
	
	for (i = 0; i < iNumProcs; i++) {
		iCurrentPid = sProcesses[i].kp_proc.p_pid;
		if( strncmp(csProcessName, sProcesses[i].kp_proc.p_comm, MAXCOMLEN) == 0 ) {
			free(sProcesses);
			return iCurrentPid;
		}
	}

	free(sProcesses);
	return (-1);
} 



%hook PhoneApplication

-(int)_initialViewType 
{ 
	
    NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:settingsFile];
    BOOL Enabled = [dict objectForKey:@"Enabled"] ? [[dict objectForKey:@"Enabled"] boolValue] : YES;
	
    return (Enabled ? ([[dict objectForKey:@"intStartView"] intValue] ?: 1) : %orig);
} 
%end

static void kPhone(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	int pid = 0;
	pid = getProcessId("MobilePhone");
	if( ! pid < 0 ){
		kill(pid, SIGKILL);
	}
}

%ctor
{
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    NULL, 
                                    &kPhone, 
                                    (CFStringRef)@"com.filippobiga.startdial.prefChange", 
                                    NULL, 
                                    0);
    %init();
}
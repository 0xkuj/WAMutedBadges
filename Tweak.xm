#import <SpringBoard/SBIcon.h>

#define WA_MUTED_BADGES_PREF @"/var/mobile/Library/Preferences/com.0xkuj.wamutedbadges.plist"

@interface WAChatSession : NSObject
@property(nonatomic) short sessionType;
@end

@interface WAMessage : NSObject
@property(readonly, nonatomic) WAChatSession *chatSession;
@property (nonatomic,retain) NSString* fromJID;
@end

@interface UIApplication (wamutedbadges)
@property (nonatomic,readonly) long long applicationState; 
@end

static SBIcon *icon;

/* writing the badges into file so we can always know what is the current badge count */
static void writeBadges(NSString *value) {
	NSMutableDictionary *pref = [NSMutableDictionary dictionaryWithContentsOfFile:WA_MUTED_BADGES_PREF];
	[pref setValue:value forKey:@"badgeValue"];
    [pref writeToFile:WA_MUTED_BADGES_PREF atomically:YES];
}

static long long getBadges() {
	NSMutableDictionary *pref = [NSMutableDictionary dictionaryWithContentsOfFile:WA_MUTED_BADGES_PREF];
	return [[pref objectForKey:@"badgeValue"] longLongValue];
}

/* hook the icon to get its badge value later */
%hook SBIcon
-(id)init{
	return icon = %orig;
}
%end

/* every message outside and inside WA reaches here */
%hook WAChatSessionTransaction
- (void)trackReceivedMessage:(id)arg1{
	%orig;

	/* messages dont count when app is active, skip */
	if ([[UIApplication sharedApplication] applicationState] == 0) {
		return;
	}
	
	dispatch_async(dispatch_get_main_queue(), ^{
		if(((WAMessage*)arg1).chatSession.sessionType != 3){
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
			long long crntBadges = getBadges() + [icon badgeValue] + 1;
			writeBadges([NSString stringWithFormat:@"%lld", crntBadges]);
			[[UIApplication sharedApplication] setApplicationIconBadgeNumber:crntBadges];
			});
		}
	});
}
%end

/* when the application is active again, erase all badges */
%hook WhatsAppAppDelegate
- (_Bool)application:(id)arg1 didFinishLaunchingWithOptions:(id)arg2{
	writeBadges(@"0");
	return %orig;
}
- (void)applicationDidBecomeActive:(id)arg1{
	%orig;
	writeBadges(@"0");
}
%end
#import <Foundation/Foundation.h>
#define WA_MUTED_BADGES_PREF @"/var/mobile/Library/Preferences/com.0xkuj.wamutedbadges.plist"

@interface WAChatSession : NSObject
@property(nonatomic) short sessionType;
@end

@interface WAMessage : NSObject
@property(readonly, nonatomic) WAChatSession *chatSession;
@property (nonatomic,retain) NSString* fromJID;
@end

@interface UIApplication
@property (nonatomic,readonly) long long applicationState; 
+(id)sharedApplication;
-(void)setApplicationIconBadgeNumber:(long long)arg1 ;
@end

@interface SBIcon
-(long long)badgeValue;
@end

@interface NSString ()
-(bool)containsSubstring:(id)arg1 ;
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

/* you can ignore this function and remove prefs from makefile if you want - this is for private use */
static BOOL shouldIgnoreGroup(NSString* groupJID) {
	NSMutableArray* ignoredGroups = [NSMutableArray arrayWithArray:[[[NSMutableDictionary alloc] initWithContentsOfFile:WA_MUTED_BADGES_PREF] objectForKey:@"items"]];
	for (id dict in ignoredGroups) {
		if ([groupJID containsSubstring:[dict objectForKey:@"selected"]]) {
			return YES;
		}
	}
	return NO;
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
	/* messages dont count when app is active, skip or if contained in prefs (remove prefs from makefile if you want - this is for private usage) */
	if ([[NSClassFromString(@"UIApplication") sharedApplication] applicationState] == 0  || shouldIgnoreGroup(((WAMessage*)arg1).fromJID) == YES) {
		return;
	}

	dispatch_async(dispatch_get_main_queue(), ^{
		if(((WAMessage*)arg1).chatSession.sessionType != 3){
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
			long long crntBadges = getBadges() + [icon badgeValue] + 1;
			writeBadges([NSString stringWithFormat:@"%lld", crntBadges]);
			[[NSClassFromString(@"UIApplication") sharedApplication] setApplicationIconBadgeNumber:crntBadges];
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
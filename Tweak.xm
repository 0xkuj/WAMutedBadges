#import <Foundation/Foundation.h>
#define WA_MUTED_BADGES_PREF @"/var/mobile/Library/Preferences/com.0xkuj.wamutedbadges.plist"

@interface WAChatSession : NSObject
@property(nonatomic) short sessionType;
@end

@interface WAMessage : NSObject {
	WAMessage* _message;
}
@property(readonly, nonatomic) WAChatSession *chatSession;
@property (nonatomic,retain) NSString* fromJID;
@end

@interface SBIcon
-(long long)badgeValue;
@end

@interface NSString ()
-(bool)containsSubstring:(id)arg1 ;
@end

@interface UIApplication
-(id)sharedApplication;
-(NSInteger)applicationState;
-(void)setApplicationIconBadgeNumber:(NSInteger)arg1;
@end


static int messageCount;
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

%hook WAChatSessionTransaction
- (BOOL)shouldMuteMessage:(id)arg1 {
	NSLog(@"0xkuj here2");
	/* messages dont count when app is active, skip or if contained in prefs (remove prefs from makefile if you want - this is for private usage) */
	if ([[NSClassFromString(@"UIApplication") sharedApplication] applicationState] == 0  || shouldIgnoreGroup(((WAMessage*)arg1).fromJID) == YES) {
		return %orig;
	}
	dispatch_async(dispatch_get_main_queue(), ^{
		if(((WAMessage*)arg1).chatSession.sessionType != 3){
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
			long long crntBadges = getBadges() + (++messageCount);
			writeBadges([NSString stringWithFormat:@"%lld", crntBadges]);
			[[NSClassFromString(@"UIApplication") sharedApplication] setApplicationIconBadgeNumber:crntBadges];
			});
		}
	});

	return %orig;
}
-(void)addMessage:(id)arg1 {
	NSLog(@"0xkuj old good trans");
	%orig;
}
-(void)processMessage:(id)arg1 {
	NSLog(@"0xkuj process message");
	%orig;
}
-(BOOL)setUnreadCount:(int)arg1 {
	NSLog(@"0xkuj setunreadcount");
	return %orig;
}
-(void)trackAddedMessage:(id)arg1 {
	NSLog(@"0xkuj trackadded message");
	%orig;
}
-(void)trackReceivedMessage:(id)arg1 {
	NSLog(@"0xkuj track receive message");
	%orig;
}
-(void)trackUpdatedMessage:(id)arg1 {
	NSLog(@"0xkuj track updated message");
	%orig;
}
-(void)updateChatSessionWithMessage:(id)arg1 {
	NSLog(@"0xkuj");
	%orig;
}
%end

%hook WAChatSessionGroupTransaction
- (BOOL)shouldMuteMessage:(id)arg1 {
	NSLog(@"0xkuj here");
	/* messages dont count when app is active, skip or if contained in prefs (remove prefs from makefile if you want - this is for private usage) */
	if ([[NSClassFromString(@"UIApplication") sharedApplication] applicationState] == 0  || shouldIgnoreGroup(((WAMessage*)arg1).fromJID) == YES) {
		return %orig;
	}
	dispatch_async(dispatch_get_main_queue(), ^{
		if(((WAMessage*)arg1).chatSession.sessionType != 3){
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
			long long crntBadges = getBadges() + (++messageCount);
			writeBadges([NSString stringWithFormat:@"%lld", crntBadges]);
			[[NSClassFromString(@"UIApplication") sharedApplication] setApplicationIconBadgeNumber:crntBadges];
			});
		}
	});

	return %orig;
}
-(BOOL)shouldAlwaysPostNotificationForMessage:(id)arg1 {
	NSLog(@"0xkuj always post");
	return %orig;
}
-(void)trackReceivedMessage:(id)arg1 {
	NSLog(@"0xkuj track again");
	%orig;
}
%end

%hook WABadgeController
-(void)didReceiveDecrementUnreadCounterMessage:(id)arg1 {
	NSLog(@"0xkuj here4");
	%orig;
}
-(void)didReceiveVisibleMessage:(id)arg1 {
	NSLog(@"0xkuj here5");
	%orig;
}
%end

%hook WAMessageHandler
-(void)updateMessagesWithPostprocessor:(id)arg1 {
	NSLog(@"0xkuj here 6");
	%orig;
}
-(void)didCommitMessages:(id)arg1 newOrUpdatedMessages:(id)arg2 postprocessor:(id)arg3 {
	NSLog(@"0xkuj here 7");
	%orig;
}
-(void)postMessageUpdatedNotificationsForMessage:(id)arg1 {
	NSLog(@"0xkuj .. %@",arg1);
	%orig;
}
-(void)setBatchesMessages:(BOOL)arg1 {
	NSLog(@"0xkuj ..");
	%orig;
}
%end

%hook WANotification
+ (id)notificationForMessage:(id)arg1 {
	NSLog(@"0xkuj hhh.. %@",arg1);
	return %orig;
}
+ (id)notificationForMessage:(id)arg1 incomingReaction:(id)arg2 {
	NSLog(@"0xkuj hhh.. %@",arg1);
	return %orig;
}
-(id)processTitleForMessage:(id)arg1 {
	NSLog(@"0xkuj hhh.. %@",arg1);
	return %orig;
}
-(id)notificationTextWithMessageIcon:(id)arg1 notificationText:(id)arg2 {
	NSLog(@"0xkuj");
	return %orig;
}
%end

%hook WANotificationScheduler
-(BOOL)shouldPlaySoundForMessage:(id)arg1 {
	NSLog(@"0xkuj hhh.. %@",arg1);
	return %orig;
}
%end

%hook WAMessageSnippet 
-(id)notificationBodyForMessage:(id)arg1 hasMessageIcon:(BOOL)arg2 {
	NSLog(@"0xkuj hhh.. %@",arg1);
	return %orig;
}
%end


%hook WANotificationHandler
- (void)notifyWithInfoJID:(id)arg1 toMessageWithID:(id)arg2 contactName:(id)arg3 messageText:(id)arg4 alertText:(id)arg5 {
	NSLog(@"0xkuj yes");
	%orig;
}
%end

%hook WAChatSessionNormalTransaction
-(BOOL)setUnreadCount:(int)arg1 {
	NSLog(@"0xkuj ok");
	return %orig;
}
-(BOOL)shouldMuteMessage:(id)arg1 {
	NSLog(@"0xkuj should mute message");
	return %orig;
}
-(void)trackReceivedMessage:(id)arg1 {
	NSLog(@"0xkuj track message");
	%orig;
}
%end

%hook WAMessageNotificationCenter
-(void)notifyBadgeControllerOfProcessedMessage:(id)arg1 {
	NSLog(@"0xkuj notif.. %@",arg1);
	%orig;
}
-(void)playIncomingSoundEffectForWAMessage:(id)arg1 {
	NSLog(@"0xkuj trying to play.. %@",arg1);
	%orig;
}
-(void)transactionDidReceiveMessage:(id)arg1 {
	NSLog(@"0xkuj latest");
	%orig;
}

%end

%hook WAStellaMessageReceivedNotifier
-(BOOL)isChatSessionMuted:(id)arg1 {
	NSLog(@"0xkuj fuck yes! %@", arg1);
	return %orig;
}
-(void)handleReceiveNewMessageNotification:(id)arg1 {
	NSLog(@"0xkuj fuck yes1! %@", arg1);
	%orig;
}
-(BOOL)handleTextMessage:(id)arg1 withSession:(id)arg2 {
    NSLog(@"0xkuj fuck yes2! %@", arg1);
	return %orig;
}
%end

%hook XMPPConnectionMain
-(id)incomingMessageHandler {
	NSLog(@"0xkuj xmp..");
	return %orig;
}
-(void)processIncomingMessageStanza:(id)arg1 {
	NSLog(@"0xkuj xmp 2");
	%orig;
}
%end

%hook WAChatSessionStatusTransaction
-(void)updateChatSessionWithMessage:(id)arg1 {
	NSLog(@"0xkuj update");
	%orig;
}
%end

%hook WAChatSessionIndividualTransaction 
-(void)updateChatSessionWithMessage:(id)arg1 {
	NSLog(@"0xkuj update");
	%orig;
}
%end

%hook WAChatSessionIncomingStatusTransaction
-(void)updateChatSessionWithMessage:(id)arg1 {
	NSLog(@"0xkuj update");
	%orig;
}
%end

%hook WAMessageNotificationInfo
-(id)initWithMessage:(id)arg1 {
	NSLog(@"0xkuj");
	return %orig;
}
%end

%hook WANotification
-(id)initWithMessage:(id)arg1 {
	NSLog(@"0xkuj");
	return %orig;
}
%end

// %hook WAPushController 

// %end
%hook WAMessaginService
-(void)asyncLoadPendingMessages:(id)arg1 {
	NSLog(@"0xkuj async!!!!!!!");
	%orig;
}
-(void)sendMessage:(id)arg1 {
	NSLog(@"0xkuj sending message.. %@", arg1);
	%orig;
}
%end

// %hook WAMessagePostoprocessor

// %end

%hook XMPPClient 
-(id)jid {
	NSLog(@"0xkuj");
	return %orig;
}
%end

%hook WAStreamingMediaLoaderMessageInfo
-(id)initWithMessage:(id)arg1 {
	NSLog(@"0xkuj");
	return %orig;
}
%end

%hook WADecryptedMessagePayloadMessageProcessorRevoke
-(void)initializeWithMessage:(id)arg1 payload:(id)arg2 {
	NSLog(@"0xkuj");
	%orig;
}
%end

%hook WAInvisibileMessageHandleRequest
-(id)initWithMessageID:(id)arg1 protobufMessage:(id)arg2 deviceJID:(id)arg3 {
	NSLog(@"0xkuj");
	return %orig;
}
%end


/* when the application is active again, erase all badges */
%hook WhatsAppAppDelegate
- (_Bool)application:(id)arg1 didFinishLaunchingWithOptions:(id)arg2{
	writeBadges(@"0");
	messageCount=0;
	return %orig;
}
- (void)applicationDidBecomeActive:(id)arg1{
	%orig;
	writeBadges(@"0");
	messageCount=0;
}
%end
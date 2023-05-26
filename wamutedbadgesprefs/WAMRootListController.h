#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <rootless.h>
#define GENERAL_PREFS ROOT_PATH_NS(@"/var/mobile/Library/Preferences/com.0xkuj.wamutedbadges.plist")
#define GENERAL_PREFS_NO_PLIST ROOT_PATH_NS(@"/var/mobile/Library/Preferences/com.0xkuj.wamutedbadges")
@interface PSEditableListController : PSListController
@end

@interface WAMRootListController : PSEditableListController
@end

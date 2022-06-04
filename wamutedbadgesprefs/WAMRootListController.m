#include "WAMRootListController.h"
#pragma GCC diagnostic ignored "-Wunguarded-availability-new"

NSMutableDictionary *preferences;
NSMutableArray *rememberedAlerts;
UITextField *groupJID;

@implementation WAMRootListController

- (id)readPreferenceValue:(PSSpecifier*)specifier {
    NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    [settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
    return (settings[specifier.properties[@"key"]]) ?: specifier.properties[@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
    NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/com.0xkuj.wamutedbadges.plist"];
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    [settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
    [settings setObject:value forKey:specifier.properties[@"key"]];
    [settings writeToFile:path atomically:YES];
    CFStringRef notificationName = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
    if (notificationName) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
    }
}


- (NSArray *)specifiers {
    _specifiers = [self loadSpecifiersFromPlistName:@"../../../var/mobile/Library/Preferences/com.0xkuj.wamutedbadges" target:self] ?: [[NSMutableArray alloc] init];
    self.navigationItem.title = @"WAM";

    for (PSSpecifier *specifier in _specifiers)
    {
        [specifier setProperty:NSStringFromSelector(@selector(removedSpecifier:)) forKey:PSDeletionActionKey];
    }
	PSSpecifier *button = [PSSpecifier preferenceSpecifierNamed:@"Add" target:self set:NULL get:NULL detail:nil cell:PSButtonCell edit:nil];
    [button setButtonAction:@selector(add)];
	[_specifiers insertObject:button atIndex:0];

	return _specifiers;
}

-(void)add{
    preferences = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.0xkuj.wamutedbadges.plist"] ?: [[NSMutableDictionary alloc] init];
    rememberedAlerts = [preferences objectForKey:@"items"] ?: [[NSMutableArray alloc] init];

    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Add group"
                                                                                 message:nil
                                                                             preferredStyle:UIAlertControllerStyleAlert];

   [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
       textField.placeholder = @"Group Title";
       textField.clearButtonMode = UITextFieldViewModeWhileEditing;
       textField.borderStyle = UITextBorderStyleRoundedRect;
   }];

	[alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
       textField.placeholder = @"Group JID - e.g 1516464331@g.us";
       textField.clearButtonMode = UITextFieldViewModeWhileEditing;
       textField.borderStyle = UITextBorderStyleRoundedRect;
   }];

   [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
       NSArray * textfields = alertController.textFields;
       UITextField * textField11 = textfields[0];
	   UITextField * textField22 = textfields[1];

       NSString *pt1 = textField11.text;
	   NSString *pt2 = textField22.text;

       NSDictionary *currentAlert = @{ @"cell" : @"PSStaticTextCell", @"title" : @"0xkuj", @"label" : [NSString stringWithFormat: @"Group: %@ JID: %@", pt1,pt2], @"selected" : [NSString stringWithFormat: @"%@", pt2] };

       if (![rememberedAlerts containsObject:currentAlert])
       {
           [rememberedAlerts addObject:currentAlert];
           [preferences setValue:rememberedAlerts forKey:@"items"];

           NSError *error;
           if (![preferences writeToURL:[NSURL fileURLWithPath:@"/var/mobile/Library/Preferences/com.0xkuj.wamutedbadges.plist"] error:&error])
           {
               //[[[UIAlertView alloc] initWithTitle:@"Error" message:[@"Failed to save settings. Error:\n" stringByAppendingString:error.localizedDescription] delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil] show];
           }
       }
       [self reloadSpecifiers];
           CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)@"com.0xkuj.wamutedbadges", NULL, NULL, NO);


   }]];
   [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                       style:UIAlertActionStyleCancel
                                                     handler:nil]];
   [self presentViewController:alertController animated:YES completion:nil];

}

-(void)apply{

    [self.view endEditing:YES];
    [self reloadSpecifiers];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)@"com.0xkuj.wamutedbadges", NULL, NULL, NO);
}

- (void)_returnKeyPressed:(id )notification {
    [self.view endEditing:YES];
    [self reloadSpecifiers];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)@"com.0xkuj.wamutedbadges", NULL, NULL, NO);

}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if(indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2 ){
     //   return UITableViewCellEditingStyleNone;
   // }
    return UITableViewCellEditingStyleDelete;
}

-(void)removedSpecifier:(PSSpecifier *)specifier
{
    NSMutableDictionary *preferences = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.0xkuj.wamutedbadges.plist"];
    NSMutableArray *items = [preferences objectForKey:@"items"];
    for (NSDictionary *item in items)
    {
        if ([item[@"selected"] isEqual:[specifier propertyForKey:@"selected"]])
        {
            [items removeObject:item];
            break;
        }
    }

    [preferences setValue:items forKey:@"items"];
    NSError *error;
    if (![preferences writeToURL:[NSURL fileURLWithPath:@"/var/mobile/Library/Preferences/com.0xkuj.wamutedbadges.plist"] error:&error])
    {
        //[[[UIAlertView alloc] initWithTitle:@"Error" message:[@"Failed to save settings. Error:\n" stringByAppendingString:error.localizedDescription] delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil] show];
    }
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)@"com.0xkuj.wamutedbadges", NULL, NULL, NO);
}



@end

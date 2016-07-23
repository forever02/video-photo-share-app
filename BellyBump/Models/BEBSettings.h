@interface BEBSettings : NSObject

@property (nonatomic, getter = isReminderDaily) BOOL reminderDaily;
@property (nonatomic, getter = isReminderWeekly) BOOL reminderWeekly;
@property (nonatomic, getter = isReminderBiWeekly) BOOL reminderBiWeekly;
@property (nonatomic, getter = isAutoSave) BOOL autoSave;
@property (nonatomic, copy) NSString *usernameFacebook;
@property (nonatomic, copy) NSString *usernameTwitter;

- (void)getSocialUsernameFacebook;
- (void)getSocialUsernameTwitter;

@end

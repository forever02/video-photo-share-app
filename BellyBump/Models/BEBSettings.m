#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "BEBSettings.h"

@interface BEBSettings()

@property (nonatomic, retain) ACAccountStore *accountStore;
@property (nonatomic, retain) ACAccount *facebookAccount;

@end

@implementation BEBSettings

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        // Set default values
        _reminderDaily = YES;
        _reminderWeekly = YES;
        _reminderBiWeekly = YES;
        _autoSave = YES;
        
        self.usernameTwitter = @"";
        self.usernameFacebook = @"";
        
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        if ([ud objectForKey:kReminderDailySettings]) {
            _reminderDaily = [[ud objectForKey:kReminderDailySettings] boolValue];
        }
        
        if ([ud objectForKey:kReminderWeeklySettings]) {
            _reminderWeekly = [[ud objectForKey:kReminderWeeklySettings] boolValue];
        }
        
        if ([ud objectForKey:kReminderBiWeeklySettings]) {
            _reminderBiWeekly = [[ud objectForKey:kReminderBiWeeklySettings] boolValue];
        }
        
        if ([ud objectForKey:kPhotosAutoSaveSettings]) {
            _autoSave = [[ud objectForKey:kPhotosAutoSaveSettings] boolValue];
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder;
{
    [coder encodeBool:self.reminderDaily forKey:@"reminderDaily"];
    [coder encodeBool:self.reminderWeekly forKey:@"reminderWeekly"];
    [coder encodeBool:self.reminderBiWeekly forKey:@"reminderBiWeekly"];
    [coder encodeBool:self.autoSave forKey:@"autoSave"];
}

- (id)initWithCoder:(NSCoder *)coder;
{
    self = [self init];
    
    self.reminderDaily = [coder decodeBoolForKey:@"reminderDaily"];
    self.reminderWeekly = [coder decodeBoolForKey:@"reminderWeekly"];
    self.reminderBiWeekly = [coder decodeBoolForKey:@"reminderBiWeekly"];
    self.autoSave = [coder decodeBoolForKey:@"autoSave"];
    
    return self;
}

- (void)setReminderDaily:(BOOL)reminderDaily
{
    _reminderDaily = reminderDaily;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:@(reminderDaily) forKey:kReminderDailySettings];
    [ud synchronize];
}

- (void)setReminderWeekly:(BOOL)reminderWeekly
{
    _reminderWeekly = reminderWeekly;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:@(reminderWeekly) forKey:kReminderWeeklySettings];
    [ud synchronize];
}

- (void)setReminderBiWeekly:(BOOL)reminderBiWeekly
{
    _reminderBiWeekly = reminderBiWeekly;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:@(reminderBiWeekly) forKey:kReminderBiWeeklySettings];
    [ud synchronize];
}

- (void)setAutoSave:(BOOL)autoSave
{
    _autoSave = autoSave;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:@(autoSave) forKey:kPhotosAutoSaveSettings];
    [ud synchronize];
}

- (void)getSocialUsernameFacebook
{
    __weak typeof(self) weakSelf = self;
    if(!_accountStore)
        _accountStore = [[ACAccountStore alloc] init];
    
    ACAccountType *facebookTypeAccount = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    [_accountStore requestAccessToAccountsWithType:facebookTypeAccount
                                           options:@{ACFacebookAppIdKey: kFacebookAppID, ACFacebookPermissionsKey: @[@"email"]}
                                        completion:^(BOOL granted, NSError *error) {
                                            if(granted){
                                                NSArray *accounts = [_accountStore accountsWithAccountType:facebookTypeAccount];                                                _facebookAccount = [accounts lastObject];
                                                NSString *fullName = [[_facebookAccount valueForKey:@"properties"] valueForKey:@"ACPropertyFullName"];
                                                weakSelf.usernameFacebook = fullName;
                                                
                                                [[NSNotificationCenter defaultCenter] postNotificationName:kGetUserNameFacebookNotification
                                                                                                    object:nil
                                                                                                  userInfo:nil];

                                                NSLog(@"Success");
                                                
                                            }else{
                                                // ouch
                                                NSLog(@"Fail");
                                                NSLog(@"Error: %@", error);
                                            }
                                        }];
}

- (void)getSocialUsernameTwitter
{
    __weak typeof(self) weakSelf = self;
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        
        if (granted) {
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
            if ([accountsArray count] > 0) {
                ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
                weakSelf.usernameTwitter = twitterAccount.username;
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kGetUserNameTwitterNotification
                                                                    object:nil
                                                                  userInfo:nil];
            }
        }
        else {
            DEBUG_LOG(@"Permission denied");
            DEBUG_LOG(@"%@", error);
        }
    }];
}

@end

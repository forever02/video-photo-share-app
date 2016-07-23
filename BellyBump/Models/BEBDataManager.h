#import "AFHTTPSessionManager.h"

@class BEBStory;
@class BEBSettings;

typedef void (^BEBHTTPResponseSuccessBlock)(id response);
typedef void (^BEBHTTPResponseFailureBlock)(NSError *error);

@interface BEBDataManager : AFHTTPSessionManager

#pragma mark - Properties
/**
 *  List stories of user
 */
@property (nonatomic, strong) NSMutableArray *stories;

@property (nonatomic, strong) NSMutableArray *fonts;

@property (nonatomic, copy) NSArray *filterImages;

@property (nonatomic, copy) NSArray *filterNames;

@property (nonatomic, getter = isExistedData) BOOL existedData;

@property (nonatomic, getter = isNetworkReachable) BOOL networkReachable;

@property (nonatomic, strong) NSMutableArray *deletedImages;

@property (nonatomic, copy) NSString *deviceID;

@property (nonatomic, strong) NSMutableDictionary *notificationsDict;

@property (nonatomic, strong) BEBSettings *settings;

#pragma mark - Lifecycle method

+ (BEBDataManager *)sharedManager;

#pragma mark - Helper methods

- (void)saveStoryDataToFile;

- (void)saveDeletedImagesToFile;

- (void)syncDeletedImagesToS3;

- (void)updateLocalNotificationForStory:(BEBStory *)story;

- (void)cancelLocalNotificationForStory:(BEBStory *)story;

- (void)getDataFromS3:(void (^)(BOOL result))completedBlock;

- (void)saveDataToS3:(void (^)(BOOL result))completedBlock;

- (void)updateReminderDailySettingsOn:(BOOL)on;

- (void)updateReminderWeeklySettingsOn:(BOOL)on;

- (void)updateReminderBiWeeklySettingsOn:(BOOL)on;

- (void)updateAutoSaveSettingsOn:(BOOL)on;

@end

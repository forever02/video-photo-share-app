#import "BEBDataManager.h"
#import "BEBStory.h"
#import "BEBImage.h"
#import "BEBUtilities.h"
#import <AWSS3/AWSS3.h>
#import "BEBConstant.h"
#import "BEBSettings.h"
#import "AFNetworkReachabilityManager.h"
#import "KeychainItemWrapper.h"

@implementation BEBDataManager

//*****************************************************************************
#pragma mark -
#pragma mark ** Singleton object **

+ (BEBDataManager *)sharedManager;
{
    static BEBDataManager *__sharedManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedManager = [[self alloc] initWithBaseURL:[NSURL URLWithString:BellyBumpURLString]];
    });
    
    return __sharedManager;
}

//*****************************************************************************
#pragma mark -
#pragma mark - ** Initializer & Lifecycle methods **

- (instancetype)initWithBaseURL:(NSURL *)url;
{
    self = [super initWithBaseURL:url];
    
    if (self) {
        
        // Init request and response serializer
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        
        // Set value for header content type
        [self.requestSerializer setValue:kHTTPHeaderApplication
                      forHTTPHeaderField:kHTTPHeaderContentType];
        
        // Cancel all local notifications
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        
        // Get device ID
        UIDevice *currentDevice = [UIDevice currentDevice];
        NSString *bundleId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
        KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:bundleId accessGroup:nil];
        NSString *deviceID = [keychainItem objectForKey:(__bridge id)(kSecValueData)];
        
        if (!deviceID || [deviceID isEqualToString:@""]) {
            self.deviceID = [currentDevice.identifierForVendor UUIDString];
            [keychainItem setObject:self.deviceID forKey:(__bridge id)(kSecValueData)];
        }
        else {
            self.deviceID = deviceID;
        }
        
        // Start network reachable
        [self startNetworkReachable];
        
        // Init data model
        self.deletedImages = [NSMutableArray array];
        self.stories = [NSMutableArray array];
        self.settings = [[BEBSettings alloc] init];
        
        // Load local data
        [self loadDeletedImages];
        [self loadData];
        
        // TODO: Set mock fonts
        [self setupFonts];
    }
    
    return self;
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                            completionHandler:(void (^)(NSURLResponse *, id, NSError *))originalCompletionHandler;
{
    return [super dataTaskWithRequest:request
                    completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                        
                        // If there's an error, store the response in it if we've got one.
                        if (error && responseObject) {
                            
                            if (error.userInfo) { // Already has a dictionary, so we need to add to it.
                                
                                NSMutableDictionary *userInfo = [error.userInfo mutableCopy];
                                userInfo[kBEBErrorResponseObjectKey] = responseObject;
                                error = [NSError errorWithDomain:error.domain
                                                            code:error.code
                                                        userInfo:[userInfo copy]];
                            }
                            else { // No dictionary, make a new one.
                                error = [NSError errorWithDomain:error.domain
                                                            code:error.code
                                                        userInfo:@{kBEBErrorResponseObjectKey: responseObject}];
                            }
                        }
                        
                        // Call the original handler.
                        if (originalCompletionHandler) {
                            originalCompletionHandler(response, responseObject, error);
                        }
                    }];
}

//*****************************************************************************
#pragma mark -
#pragma mark - ** Reachability methods **
- (void)startNetworkReachable;
{
    __weak typeof(self) weakSelf = self;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

    [self.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        switch (status) {
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
            {
                DEBUG_LOG(@"WIFI");
                weakSelf.networkReachable = YES;
                if (weakSelf.deletedImages.count > 0) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        [weakSelf syncDeletedImagesToS3];
                    });
                }
                
                // Check get data from S3 and merge with local data
                if ([[ud objectForKey:kBEBMergeLocalData] boolValue]) {
                    [weakSelf getDataFromS3:^(BOOL result) {
                        if (result) {
                            [weakSelf syncDataToS3];
                        }
                    }];
                }
                else if ([weakSelf isExistedData]) {
                    [weakSelf syncDataToS3];
                }
            }
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
            {
                DEBUG_LOG(@"3G");
                weakSelf.networkReachable = YES;
                if (weakSelf.deletedImages.count > 0) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        [weakSelf syncDeletedImagesToS3];
                    });
                }
                
                // Check get data from S3 and merge with local data
                if ([[ud objectForKey:kBEBMergeLocalData] boolValue]) {
                    [weakSelf getDataFromS3:^(BOOL result) {
                        if (result) {
                            [weakSelf syncDataToS3];
                        }
                    }];
                }
                else if ([weakSelf isExistedData]) {
                    [weakSelf syncDataToS3];
                }
            }
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
                DEBUG_LOG(@"No Internet Connection");
                weakSelf.networkReachable = NO;
                break;
                
            default:
                DEBUG_LOG(@"Unknown network status");
                weakSelf.networkReachable = NO;
                break;
        }
    }];
    
    [self.reachabilityManager startMonitoring];
}

//*****************************************************************************
#pragma mark -
#pragma mark - ** Helper Methods **
- (NSString *)filePathOfStory;
{
    // General the name of file
    NSString *fileName = @"BellyBumpData";
    return [[BEBUtilities userCacheDirectory] stringByAppendingPathComponent:fileName];
}

- (NSString *)filePathOfDeletedImages;
{
    // General the name of file
    NSString *fileName = @"BellyBumpDeletedImages";
    return [[BEBUtilities userCacheDirectory] stringByAppendingPathComponent:fileName];
}

- (void)loadData;
{
    // Get the data from saving file
    NSMutableData *pData = [[NSMutableData alloc] initWithContentsOfFile:[self filePathOfStory]];
    
    if (pData) {
        // Using unArchiver to decode the data
        NSKeyedUnarchiver *unArchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:pData];
        
        self.stories = [[NSMutableArray alloc] initWithCoder:unArchiver];
        [unArchiver finishDecoding];
        
        // Update local notification for all stories
        [self updateLocalNotificationAllStories];
        
        self.existedData = YES;
    }
    else {
        self.existedData = NO;
    }
}

- (void)loadDeletedImages;
{
    // Get the data from saving file
    NSMutableData *pData = [[NSMutableData alloc] initWithContentsOfFile:[self filePathOfDeletedImages]];
    
    if (pData) {
        // Using unArchiver to decode the data
        NSKeyedUnarchiver *unArchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:pData];
        
        self.deletedImages = [[NSMutableArray alloc] initWithCoder:unArchiver];
        [unArchiver finishDecoding];
    }
}

// Saving Belly bump data using archiver
- (void)saveStoryDataToFile;
{
    // Init mutable data
    NSMutableData *pData = [[NSMutableData alloc] init];
    
    // Init NSKeyedArchiver object
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:pData];
    
    // Encoder data story
    [self.stories encodeWithCoder:archiver];
    [archiver finishEncoding];
    
    // Write Archiver data to file
    [pData writeToFile:[self filePathOfStory] atomically:YES];
    
//    {
//        NSMutableData *pData1 = [[NSMutableData alloc] initWithContentsOfFile:[self filePathOfStory]];
//        
//            NSKeyedUnarchiver *unArchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:pData1];
//            
//            self.stories = [[NSMutableArray alloc] initWithCoder:unArchiver];
//            [unArchiver finishDecoding];
//        int i = 0;
//    }
    
    // Mark need to merge local data with remote data from S3
    if (![self isExistedData]) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:@(YES) forKey:kBEBMergeLocalData];
        [ud synchronize];
    }
    // Mark existed data
    self.existedData = YES;
    //[self loadData];
}

- (void)saveDeletedImagesToFile;
{
    // Init mutable data
    NSMutableData *pData = [[NSMutableData alloc] init];
    
    // Init NSKeyedArchiver object
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:pData];
    
    // Encoder data story
    [self.deletedImages encodeWithCoder:archiver];
    [archiver finishEncoding];
    
    // Write Archiver data to file
    [pData writeToFile:[self filePathOfDeletedImages] atomically:YES];
}

- (void)syncDataToS3;
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        __weak typeof(self) weakSelf = self;
        __block NSInteger totalImages = 0;
        BOOL waitingUploadImage = NO;
        
        // Save image to S3
        for (BEBStory *story in self.stories) {
            for (BEBImage *bebImage in story.photos) {
                if (![bebImage isSavedS3]) {
                    totalImages++;
                    waitingUploadImage = YES;
                    [bebImage saveImageToS3:^(BOOL result) {
                        totalImages--;
                        if (totalImages == 0) {
                            
                            // Save story data to file to cache local
                            [weakSelf saveStoryDataToFile];
                            
                            // Save story data to S3
                            [weakSelf saveDataToS3:nil];
                        }
                    }];
                }
            }
        }
        
        if (!waitingUploadImage &&
            [ud objectForKey:kBEBSavedDataToS3] &&
            ![[ud objectForKey:kBEBSavedDataToS3] boolValue]) {
            
            // Save story data to S3
            [self saveDataToS3:nil];
        }
    });
}

- (void)syncDeletedImagesToS3;
{
    AWSS3 *s3 = [AWSS3 defaultS3];
    
    NSMutableArray *deletedImages = [NSMutableArray array];
    NSMutableArray *objectsArray = [NSMutableArray array];
    for (BEBImage *bebImage in self.deletedImages) {
        AWSS3ObjectIdentifier *obj = [[AWSS3ObjectIdentifier alloc] init];
        obj.key = [bebImage fileName];
        [objectsArray addObject:obj];
        [deletedImages addObject:bebImage];
    }
    
    AWSS3Remove *s3Remove = [[AWSS3Remove alloc] init];
    s3Remove.objects = objectsArray;
    
    AWSS3DeleteObjectsRequest *multipleObjectsDeleteReq = [[AWSS3DeleteObjectsRequest alloc] init];
    multipleObjectsDeleteReq.bucket = S3BucketName;
    multipleObjectsDeleteReq.remove = s3Remove;
    
    __weak typeof(self) weakSelf = self;
    [[[s3 deleteObjects:multipleObjectsDeleteReq] continueWithBlock:^id(AWSTask *task) {
        
        if (task.error) {
            DEBUG_LOG(@"Delete failed: [%@]", task.error);
        }
        else if (task.result) {
            DEBUG_LOG(@"Result delete: [%@]", task.result);
            
            // Clean deleted images
            [weakSelf.deletedImages removeObjectsInArray:deletedImages];
            [weakSelf saveDeletedImagesToFile];
        }
        return nil;
        
    }] waitUntilFinished];
}

- (void)getDataFromS3:(void (^)(BOOL result))completedBlock;
{
    // Construct the download request.
    AWSS3TransferManagerDownloadRequest *downloadRequest = [[AWSS3TransferManagerDownloadRequest alloc] init];
    downloadRequest.downloadingFileURL = [NSURL fileURLWithPath:[self filePathOfStory]];
    downloadRequest.bucket = S3BucketName;
    downloadRequest.key = self.deviceID;
    
    // Download the file.
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    [[transferManager download:downloadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task) {
        
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        
        // File download error.
        if (task.error) {
            
            if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                switch (task.error.code) {
                    case AWSS3TransferManagerErrorCancelled:
                    case AWSS3TransferManagerErrorPaused:
                        break;
                        
                    default:
                        DEBUG_LOG(@"Error: %@", task.error);
                        break;
                }
            }
            else {
                // Unknown error.
                DEBUG_LOG(@"Error: %@", task.error);
            }
            
            // This is the first time user using app
            if ([task.error.userInfo[@"Message"] isEqualToString:@"The specified key does not exist."]) {
                
                if ([[ud objectForKey:kBEBMergeLocalData] boolValue]) {
                    // Mark finished merge local data
                    [ud setObject:@(NO) forKey:kBEBMergeLocalData];
                    [ud synchronize];
                    completedBlock(TRUE);
                }
                else {
                    // TODO: Add mock data for testing
//                    [self mockingData];
//                    [self loadData];
//                    completedBlock(TRUE);
                    
                    // Uncomment this when remove code mock data
                    completedBlock(FALSE);
                }
            }
            else {
                completedBlock(FALSE);
            }
        }
        
        // File downloaded successfully.
        if (task.result) {
            
            // Process merge remote data from S3 with local data
            if ([[ud objectForKey:kBEBMergeLocalData] boolValue]) {
                
                NSMutableData *pData = [[NSMutableData alloc] initWithContentsOfFile:[self filePathOfStory]];
                NSKeyedUnarchiver *unArchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:pData];
                NSMutableArray *oldStories = [[NSMutableArray alloc] initWithCoder:unArchiver];
                [unArchiver finishDecoding];
                
                // Merge remote stories to local stories
                [self.stories addObjectsFromArray:oldStories];
                
                // Update local notification for all stories
                [self updateLocalNotificationAllStories];
                
                // Mark finished merge local data
                [ud setObject:@(NO) forKey:kBEBMergeLocalData];
                [ud synchronize];
                
                // Post notification merge data finished
                [[NSNotificationCenter defaultCenter] postNotificationName:kFinishedMergeDataNotification
                                                                    object:self
                                                                  userInfo:nil];
                
                // Save story data to file to cache local
                [self saveStoryDataToFile];
                
                // Save story data to S3
                [self saveDataToS3:nil];
            }
            else {
                // Load data
                [self loadData];
            }
            
            // Perform complete block
            completedBlock(TRUE);
        }
        
        return nil;
    }];
}

- (void)saveDataToS3:(void (^)(BOOL result))completedBlock;
{
    // Mark not saved data to S3 to retry
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:@(NO) forKey:kBEBSavedDataToS3];
    [ud synchronize];
    
    // Make request upload to S3
    AWSS3TransferManagerUploadRequest *uploadRequest = [[AWSS3TransferManagerUploadRequest alloc] init];
    uploadRequest.body = [NSURL fileURLWithPath:[self filePathOfStory]];
    uploadRequest.bucket = S3BucketName;
    uploadRequest.key = self.deviceID;
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    [[transferManager upload:uploadRequest] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                switch (task.error.code) {
                    case AWSS3TransferManagerErrorCancelled:
                    case AWSS3TransferManagerErrorPaused:
                        break;
                        
                    default:
                        DEBUG_LOG(@"Upload failed: [%@]", task.error);
                        break;
                }
            }
            else {
                DEBUG_LOG(@"Upload failed: [%@]", task.error);
            }
            
            if (completedBlock) {
                completedBlock(FALSE);
            }
        }
        
        if (task.result) {
            
            // Mark saved data to S3
            [ud setObject:@(YES) forKey:kBEBSavedDataToS3];
            [ud synchronize];
            
            // File upload successfully.
            if (completedBlock) {
                completedBlock(TRUE);
            }
        }
        
        return nil;
    }];
}

- (void)updateLocalNotificationAllStories;
{
    // Reset notifications dictionary
    self.notificationsDict = [NSMutableDictionary dictionary];
    
    // Filter local notification for all stories
    for (BEBStory *story in self.stories) {
        [self filterLocalNotificationForStory:story];
    }
    
    // Schedule all local notifications
    [self scheduleAllLocalNotifications];
}

- (void)updateLocalNotificationForStory:(BEBStory *)story;
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    [self filterLocalNotificationForStory:story];
    
    [self scheduleAllLocalNotifications];
}

- (void)filterLocalNotificationForStory:(BEBStory *)story;
{
    if (story.frequence == FrequencyTypeBiweekly && [self.settings isReminderBiWeekly]) {
        
        [self filterLocalNotificationAtFireDate:story.startDate
                                        storyId:story.storyId];
        
        [self filterLocalNotificationAtFireDate:[story.startDate dateByAddingTimeInterval:3*24*60*60]
                                        storyId:story.storyId];
    }
    else if (story.frequence == FrequencyTypeWeekly && [self.settings isReminderWeekly]) {
        
        [self filterLocalNotificationAtFireDate:story.startDate
                                        storyId:story.storyId];
    }
    else if (story.frequence == FrequencyTypeDaily && [self.settings isReminderDaily]) {
        for (NSInteger i = 0; i < 7; i++) {
            [self filterLocalNotificationAtFireDate:[story.startDate dateByAddingTimeInterval:i*24*60*60]
                                            storyId:story.storyId];
        }
    }
}

- (void)filterLocalNotificationAtFireDate:(NSDate *)fireDate
                                  storyId:(NSInteger)storyId;
{
    NSNumber *weekday = [BEBUtilities weekdayFromDate:fireDate];
    NSString *key = [NSString stringWithFormat:@"%@", weekday];
    if (self.notificationsDict[key]) {
        NSDate *prevDate = self.notificationsDict[key][@"fireDate"];
        
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *currComponents = [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:fireDate];
        NSDateComponents *prevComponents = [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:prevDate];
        NSInteger currTotalSeconds = [currComponents hour] * 3600 + [currComponents minute] * 60 + [currComponents second];
        NSInteger prevTotalSeconds = [prevComponents hour] * 3600 + [prevComponents minute] * 60 + [prevComponents second];
        
        if (currTotalSeconds < prevTotalSeconds) {
            self.notificationsDict[key][@"fireDate"] = fireDate;
            self.notificationsDict[key][@"storyId"] = @(storyId);
        }
    }
    else {
        self.notificationsDict[key] = [NSMutableDictionary dictionary];
        self.notificationsDict[key][@"fireDate"] = fireDate;
        self.notificationsDict[key][@"storyId"] = @(storyId);
    }
}

- (void)scheduleAllLocalNotifications;
{
    NSString *title = @"Belly Bump photoshoot time!!";
    for (NSString *key in [self.notificationsDict allKeys]) {
        
        NSDate *fireDate = self.notificationsDict[key][@"fireDate"];
        NSInteger storyId = [self.notificationsDict[key][@"storyId"] integerValue];
        
        [self scheduleLocalNotificationAtFireDate:fireDate
                                   repeatInterval:NSCalendarUnitWeekOfYear
                                          storyId:storyId
                                            title:title];
    }
}

- (void)scheduleLocalNotificationAtFireDate:(NSDate *)fireDate
                             repeatInterval:(NSCalendarUnit)repeatInterval
                                    storyId:(NSInteger)storyId
                                      title:(NSString *)title;
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.alertBody = title;
    notification.userInfo = @{kStoryIdKey: @(storyId)};
    notification.repeatInterval = repeatInterval;
    notification.fireDate = fireDate;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (void)cancelLocalNotificationForStory:(BEBStory *)story;
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [self updateLocalNotificationAllStories];
}

- (void)updateReminderDailySettingsOn:(BOOL)on
{
    [self.settings setReminderDaily:on];
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [self updateLocalNotificationAllStories];
}

- (void)updateReminderWeeklySettingsOn:(BOOL)on
{
    [self.settings setReminderWeekly:on];
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [self updateLocalNotificationAllStories];
}

- (void)updateReminderBiWeeklySettingsOn:(BOOL)on
{
    [self.settings setReminderBiWeekly:on];
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [self updateLocalNotificationAllStories];
}

- (void)updateAutoSaveSettingsOn:(BOOL)on;
{
    [self.settings setAutoSave:on];
}

- (void)mockingData;
{
    // Add the data for story list.
    for (int i = 0; i < 30; i++) {
        
        BEBStory *story = [[BEBStory alloc] init];
        
        story.storyId = i;
        
        if (i % 2 == 1) {
            story.title = [NSString stringWithFormat:@"Sweet love - %d months", i + 1];
        }
        else {
            story.title = [NSString stringWithFormat:@"Story: Alice %d months", i + 1];
        }
        
        NSInteger randomHours = arc4random() % 72;
        story.frequence = (BEBFrequencyType) (i % 3);
        story.startDate = [[NSDate date] dateByAddingTimeInterval:-7*24*60*60 + randomHours*60*60];
        
        int startIdx = arc4random_uniform(10);
        int imageCnt = arc4random_uniform(8);
        if (imageCnt > 1 && imageCnt < 5) imageCnt += 4;
        
        if (i == 0) {
            imageCnt = 100;
        }
        
        for (int j = startIdx; j < startIdx + imageCnt; j++) {
            
            BEBImage *image = [[BEBImage alloc] init];
            
            NSString *imageName = [NSString stringWithFormat:@"card%d", j%8];
            image.image = [UIImage imageNamed:imageName];
            image.uuid = imageName;
            image.savedS3 = YES;
            [image saveImageToLocal];
            [story.photos addObject:image];
        }
        
        [self.stories addObject:story];
    }
    
    [self saveStoryDataToFile];
}

- (void)setupFonts;
{
    NSArray *arrayFont = [NSArray arrayWithObjects:
                          @"Coolvetica-20",
                          @"YoungandBeautiful-22",
                          @"ArmModern-22",
                          @"Brush Script MT-25",
                          @"Beautiful Every Time-21",
                          
                          @"Ford Script-22",
                          @"Get the Message-20",
                          @"Condiment-22",
                          @"A Charming Font Expanded-20",
                          @"Merpati Putih-21",
                          
                          @"Verona-21",
                          @"Villa-21",
                          @"Comfortaa-22",
                          @"Comic Sans MS-22",
                          @"GiddyupStd-22",
                          
                          @"HaloHandletter-22",
                          @"Kristen ITC-20",
                          @"Lobster 1.4-21",
                          @"UVN Con Thuy-22",
                          @"LoveMeForever-21",
                          
                          @"Gretoon Highlight-21",
                          @"Dancing Script-23",
                          @"KBCuriousSoul-21",
                          @"Old London Alternate-23",
                          @"NewRocker-21",
                          
                          @"Hand Of Sean-22",
                          @"Slicks-21",
                          @"Bens Hand-21",
                          @"Crystal Radio Kit-22",
                          @"Earwig Factory-21",
                          
                          @"Highway to Heck-21",
                          @"Vectroid-21",
                          @"Buffied-20",
                          @"Bauhaus ITC-21",
                          @"junko's typewriter-21",
                          
                          @"Bready Alternates Demo-21",
                          @"Creepster Caps-21",
                          @"Sancreek-21",
                          @"VT323-21", nil];
    
    self.fonts = [[NSMutableArray alloc] init];

    // TODO: just handle 10 font now
    
//    for (int i = 0; i < arrayFont.count; i++) {
    for (int i = 0; i < 15; i++) {
        NSString *fstr  = [arrayFont objectAtIndex:i];
        NSArray *farr   = [fstr componentsSeparatedByString:@"-"];
        UIFont *font    = [UIFont fontWithName:[farr objectAtIndex:0] size:[[farr objectAtIndex:1] floatValue]];
        
        if (font) {
            [self.fonts addObject:font];

        }
        else {
            NSLog(@"%@", [farr objectAtIndex:0]);
        }
    }
}

@end

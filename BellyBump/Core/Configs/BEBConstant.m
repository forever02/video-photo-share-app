#import "BEBConstant.h"

@implementation BEBConstant

AWSRegionType const CognitoRegionType = AWSRegionUSEast1;
AWSRegionType const DefaultServiceRegionType = AWSRegionUSEast1;
NSString *const CognitoIdentityPoolId = @"us-east-1:f2896bb0-c96c-4a06-bc03-d235eb04af36";
NSString *const S3BucketName = @"bellybump";
NSString *const kReceiveFeedbackEmail = @"support@bellybump.co";
NSString *const kFacebookAppID = @"1139882032725068";

NSString *const kHTTPHeaderApplication = @"application/json";
NSString *const kHTTPHeaderContentType = @"Content-Type";
NSString *const kBEBErrorResponseObjectKey = @"BEBErrorResponseObjectKey";
NSString *const kBEBErrorDomain = @"BEBErrorDomain";
NSString *const kDataName = @"photo";
NSString *const kMIMEType = @"image/jpeg";
NSString *const kStoryIdKey = @"storyId";
NSString *const kBEBSavedDataToS3 = @"BEBSavedDataToS3";
NSString *const kBEBMergeLocalData = @"BEBMergeLocalData";
NSString *const kSkipShowTutorial = @"SkipShowTutorial";

// User settings
NSString *const kReminderDailySettings = @"ReminderDailySettings";
NSString *const kReminderWeeklySettings = @"ReminderWeeklySettings";
NSString *const kReminderBiWeeklySettings = @"ReminderBiWeeklySettings";
NSString *const kPhotosAutoSaveSettings = @"PhotosAutoSaveSettings";

NSString *const kTwitterAPIUploadMedia = @"https://upload.twitter.com/1.1/media/upload.json";
NSString *const kTwitterAPIUpdateStatus = @"https://api.twitter.com/1.1/statuses/update.json";
NSString *const kTwitterConsumerKey = @"uqcNDhY6nK3BjyIhjQe7XdU9r";
NSString *const kTwitterConsumerSecret = @"jYS4rvZmvSoXXlZGNYy4Dm8SPEmzjmRMIAc01MK0tuLz8JF4Bh";

// Animation Key
NSString *const kCollectionViewAnimationKey = @"UICollectionViewReloadDataAnimationKey";
NSString *const kThumbnailImageViewAnimationKey = @"ThumbnailImageViewAnimationKey";

// Cell Identifier
NSString *const kShowMoreCellIdentifier = @"showMoreCellIdentifier";
NSString *const kMyStoriesCellIdentifier = @"myStoriesCellIdentifier";
NSString *const kSettingsCellIdentifier = @"settingsCellIdentifier";
NSString *const kStoryDetailGridCellIdentifier = @"storyDetailGridCellIdentifier";
NSString *const kFontSelectionCellIdentifier = @"fontSelectionCellIdentifier";

// View Controller Identifier
NSString *const kTutorialViewControllerIdentifier = @"BEBTutorialViewControllerIdentifier";
NSString *const kNewStoryViewControllerIdentifier = @"BEBNewStoryViewControllerIdentifier";
NSString *const kStoriesDetailViewControllerIdentifier = @"BEBStoriesDetailViewControllerIdentifier";
NSString *const kCreateVideoViewControllerIdentifier = @"BEBCreateVideoViewControllerIdentifier";
NSString *const kCameraCaptureViewControllerIdentifier = @"BNCamViewControllerIdentifier";
NSString *const kMyStoriesViewControllerIdentifier = @"BEBMyStoriesViewControllerIdentifier";
NSString *const kCropImageViewControllerIdentifier = @"BEBCropImageViewControllerIdentifier";
NSString *const kSharingImageViewControllerIdentifier = @"BEBSharingImageViewControllerIdentifier";
NSString *const kSharingVideoViewControllerIdentifier = @"BEBSharingVideoViewControllerIdentifier";
NSString *const kNotificationViewControllerIdentifier = @"BEBNotificationViewControllerIdentifier";
NSString *const kImageEditorViewControllerIdentifier = @"BEBImageEditorViewControllerIdentifier";
NSString *const kBEBTextEditorViewControllerIdentifier = @"BEBTextEditorViewControllerIdentifier";


NSString *const kMyStoriesHeaderViewIdentifier = @"BEBMyStoriesHeaderViewIdentifier";

// Alert Message
NSString *const kConfirmDeleteStoryMessage = @"Wait... these photos are priceless, are you sure?";
NSString *const kConfirmDeletePhotoMessage = @"Wait... this photo is priceless, are you sure?";
NSString *const kWarningVideoTooShortForMusic = @"Your video is too short for the music cue.";

// Notification Message
NSString *const kFinishedMergeDataNotification = @"FinishedMergeDataNotification";
NSString *const kGetUserNameFacebookNotification = @"GetUserNameFacebookNotification";
NSString *const kGetUserNameTwitterNotification = @"GetUserNameTwitterNotification";

// Guide Message
NSString *const kKeepCurrentStatue = @"Keep current state";
NSString *const kMoveUp = @"move up";
NSString *const kMoveDown = @"move down";
NSString *const kMoveLeft = @"a little to the left";
NSString *const kMoveRight = @"a little to the right";
NSString *const kMoveUpLeft = @"move up and left";
NSString *const kMoveUppRight = @"move up & right";
NSString *const kMoveDownLeft = @"move down & left";
NSString *const kMoveDownRight = @"move down & right";
NSString *const kMoveIn = @"Move in";
NSString *const kMoveOut = @"Move out";

// Stencil Position
CGPoint const kKidFullShot_FaceCenter = {50, 50};
NSUInteger const kKidFullShot_EyeLinePositionY = 100;
CGPoint const kKidFullShot_BellyBumpCenter = {200, 200};
NSUInteger const kKidFullShot_BellyBumpLinePositionY = 200;

@end

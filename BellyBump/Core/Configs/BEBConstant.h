
#import <AWSCore/AWSCore.h>

@interface BEBConstant : NSObject

FOUNDATION_EXPORT AWSRegionType const CognitoRegionType;
FOUNDATION_EXPORT AWSRegionType const DefaultServiceRegionType;
FOUNDATION_EXPORT NSString *const CognitoIdentityPoolId;
FOUNDATION_EXPORT NSString *const S3BucketName;
FOUNDATION_EXPORT NSString *const kReceiveFeedbackEmail;
FOUNDATION_EXPORT NSString *const kFacebookAppID;

extern NSString *const kHTTPHeaderApplication;
extern NSString *const kHTTPHeaderContentType;
extern NSString *const kBEBErrorResponseObjectKey;
extern NSString *const kBEBErrorDomain;
extern NSString *const kDataName;
extern NSString *const kMIMEType;
extern NSString *const kStoryIdKey;
extern NSString *const kBEBSavedDataToS3;
extern NSString *const kBEBMergeLocalData;
extern NSString *const kSkipShowTutorial;

extern NSString *const kTwitterAPIUploadMedia;
extern NSString *const kTwitterAPIUpdateStatus;

extern NSString *const kReminderDailySettings;
extern NSString *const kReminderWeeklySettings;
extern NSString *const kReminderBiWeeklySettings;
extern NSString *const kPhotosAutoSaveSettings;

// Animation Key
extern NSString *const kCollectionViewAnimationKey;
extern NSString *const kThumbnailImageViewAnimationKey;
extern NSString *const kTwitterConsumerKey;
extern NSString *const kTwitterConsumerSecret;

// Cell Identifier
extern NSString *const kShowMoreCellIdentifier;
extern NSString *const kMyStoriesCellIdentifier;
extern NSString *const kSettingsCellIdentifier;
extern NSString *const kStoryDetailGridCellIdentifier;
extern NSString *const kFontSelectionCellIdentifier;

// View Controller Identifier
extern NSString *const kTutorialViewControllerIdentifier;
extern NSString *const kNewStoryViewControllerIdentifier;
extern NSString *const kStoriesDetailViewControllerIdentifier;
extern NSString *const kCreateVideoViewControllerIdentifier;
extern NSString *const kCameraCaptureViewControllerIdentifier;
extern NSString *const kMyStoriesViewControllerIdentifier;
extern NSString *const kCropImageViewControllerIdentifier;
extern NSString *const kSharingImageViewControllerIdentifier;
extern NSString *const kSharingVideoViewControllerIdentifier;
extern NSString *const kNotificationViewControllerIdentifier;
extern NSString *const kImageEditorViewControllerIdentifier;
extern NSString *const kMyStoriesHeaderViewIdentifier;
extern NSString *const kBEBTextEditorViewControllerIdentifier;

// Alert Message
extern NSString *const kConfirmDeleteStoryMessage;
extern NSString *const kConfirmDeletePhotoMessage;
extern NSString *const kWarningVideoTooShortForMusic;

// Notification Message
extern NSString *const kFinishedMergeDataNotification;
extern NSString *const kGetUserNameFacebookNotification;
extern NSString *const kGetUserNameTwitterNotification;

// Guide message
extern NSString *const kKeepCurrentStatue;
extern NSString *const kMoveUp;
extern NSString *const kMoveDown;
extern NSString *const kMoveLeft;
extern NSString *const kMoveRight;
extern NSString *const kMoveUpLeft;
extern NSString *const kMoveUppRight;
extern NSString *const kMoveDownLeft;
extern NSString *const kMoveDownRight;
extern NSString *const kMoveIn;
extern NSString *const kMoveOut;

extern CGPoint const kKidFullShot_FaceCenter;
extern NSUInteger const kKidFullShot_EyeLinePositionY;

extern CGPoint const kKidFullShot_BellyBumpCenter;
extern NSUInteger const kKidFullShot_BellyBumpLinePositionY;
@end

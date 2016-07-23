#import "BEBSharingVideoViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "BEBInstagram.h"

#import "GTLYouTube.h"
#import "VideoData.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "UploadController.h"
#import "Utils.h"
#import "YouTubeUploadVideo.h"
#import "MBProgressHUD.h"
#import <TwitterKit/TwitterKit.h>

@interface BEBSharingVideoViewController() <YouTubeUploadVideoDelegate>

@property (nonatomic, strong) YouTubeUploadVideo *uploadVideo;
@property (nonatomic, strong) GTLServiceYouTube *youtubeService;
@property (nonatomic, copy) NSString *twitterUserId;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *shareView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topPhotoAddedConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topShareViewConstraint;
@property (weak, nonatomic) IBOutlet UILabel *videoCompleteLabel;

@property (weak, nonatomic) IBOutlet UIImageView *tip17ImageView;
@property (weak, nonatomic) IBOutlet UIButton *tip17Close;


- (IBAction)youtubeButtonDidTouch:(id)sender;
- (IBAction)instagramButtonDidTouch:(id)sender;
- (IBAction)twitterButtonDidTouch:(id)sender;
- (IBAction)saveToAlbumButtonDidTouch:(id)sender;
- (IBAction)shareMoreButtonDidTouch:(id)sender;
- (IBAction)viewStoryButtonDidTouch:(id)sender;
- (IBAction)tip17ButtonClick:(id)sender;

@end

@implementation BEBSharingVideoViewController

- (void)viewDidLoad;
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title =  @"SHARE VIDEO";
    self.videoCompleteLabel.layer.cornerRadius = CGRectGetHeight(self.videoCompleteLabel.frame) / 2;
    self.videoCompleteLabel.clipsToBounds = YES;
    
    if (IS_IPHONE_4) {
        self.topPhotoAddedConstraint.constant = 30.0f;
        [self.imageView layoutIfNeeded];
        
        self.topShareViewConstraint.constant = 100.0f;
        [self.shareView layoutIfNeeded];
    }
    
    // Create Youtube upload object
    self.uploadVideo = [[YouTubeUploadVideo alloc] init];
    self.uploadVideo.delegate = self;
    
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"tip17Name"] isEqualToString:@"passed"]) {
        [self.tip17ImageView setHidden:YES];
        [self.tip17Close setHidden:YES];
    } else {
        [self.tip17ImageView setHidden:NO];
        [self.tip17Close setHidden:NO];
        CABasicAnimation *fadeInAnimate   = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeInAnimate.duration            = 3;
        fadeInAnimate.repeatCount         = 1;
        fadeInAnimate.autoreverses        = NO;
        fadeInAnimate.fromValue           = [NSNumber numberWithFloat:0.0];
        fadeInAnimate.toValue             = [NSNumber numberWithFloat:1.0];
        fadeInAnimate.removedOnCompletion = YES;
        [self.tip17ImageView.layer addAnimation:fadeInAnimate forKey:@"animateOpacity"];
        [self.tip17Close.layer addAnimation:fadeInAnimate forKey:@"animateOpacity"];
        [[NSUserDefaults standardUserDefaults] setObject:@"passed" forKey:@"tip17Name"];
    }
    
}

- (void)didReceiveMemoryWarning;
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//*****************************************************************************
#pragma mark -
#pragma mark - ** Helper Methods **

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message
{
    if (iOS_Version >= 8) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action) {
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];
        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)saveVideoToAlbum;
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:self.videoURL]) {
        [library writeVideoAtPathToSavedPhotosAlbum:self.videoURL completionBlock:^(NSURL *assetURL, NSError *error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *title, *message;
                if (error) {
                    title = @"Error";
                    message = @"Video Saving Failed";
                }
                else {
                    title = @"Video Saved";
                    message = @"Saved To Photo Album";
                }
                [self showAlertViewWithTitle:title message:message];
            });
        }];
    }
}

- (void)shareYoutube;
{
    self.youtubeService = [[GTLServiceYouTube alloc] init];
    self.youtubeService.authorizer = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                                                           clientID:kClientID
                                                                                       clientSecret:kClientSecret];
    if (![self isYoutubeAuthorized]) {
        
        [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                             forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        
        // Not yet authorized, request authorization and push the login UI onto the navigation stack.
        GTMOAuth2ViewControllerTouch *authController = [self createAuthController];
        authController.title = @"Share Video";
        [self.navigationController pushViewController:authController animated:YES];
    }
    else {
        
        // Show indicator creating video
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
        hud.labelText = @"Uploading video...";
        
        // Upload video to YouTube
        NSData *fileData = [NSData dataWithContentsOfURL:self.videoURL];
        NSString *description = @"Uploaded from BellyBump";
        [self.uploadVideo uploadYouTubeVideoWithService:self.youtubeService
                                               fileData:fileData
                                                  title:self.titleVideo
                                            description:description];
    }
}

- (void)uploadVideoWithUserId:(NSString *)userId;
{
    TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:userId];
    NSData *videoData = [NSData dataWithContentsOfURL:self.videoURL];
    
    // Init the uploading task.
    NSDictionary *params = @{
                             @"command" : @"INIT",
                             @"media_type" : @"video/mp4",
                             @"total_bytes" : [@([videoData length]) stringValue]
                             };
    NSError *clientError = nil;
    
    NSURLRequest *request = [client URLRequestWithMethod:@"POST"
                                                     URL:kTwitterAPIUploadMedia
                                              parameters:params
                                                   error:&clientError];
    
    if (request) {
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
        hud.labelText = @"Uploading video...";
        
        __weak typeof(self) weakSelf = self;
        [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (data) {
                // handle the response data e.g.
                NSError *jsonError;
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                DEBUG_LOG(@"Init: %@", json);
                
                NSString *mediaId = [json objectForKey:@"media_id_string"];
                [weakSelf apiClient:client
                 appendUploadedData:videoData
                           medicaId:mediaId];
            }
            else {
                DEBUG_LOG(@"Init error: %@", connectionError);
                [MBProgressHUD hideHUDForView:weakSelf.view.window animated:YES];
            }
        }];
    }
    else {
        DEBUG_LOG(@"Error: %@", clientError);
    }
}

// Appeding data task
- (void)apiClient:(TWTRAPIClient *)client appendUploadedData:(NSData *)data medicaId:(NSString *)mediaId;
{
    NSDictionary *params = @{
                             @"command" : @"APPEND",
                             @"segment_index" : @"0",
                             @"media_id" : mediaId,
                             @"media_data" : [data base64EncodedStringWithOptions:0]
                             };
    NSError *clientError = nil;
    NSURLRequest *request = [client URLRequestWithMethod:@"POST"
                                                     URL:kTwitterAPIUploadMedia
                                              parameters:params
                                                   error:&clientError];
    
    if (!clientError) {
        __weak typeof(self) weakSelf = self;
        [client sendTwitterRequest:request
                        completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                            if (data) {
                                // handle the response data e.g.
                                NSError *jsonError;
                                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                                DEBUG_LOG(@"Append json: %@", json);
                                [weakSelf apiClient:client finializeUploadingWithMedicaId:mediaId];
                            }
                            else {
                                DEBUG_LOG(@"Append Error: %@", connectionError);
                                [MBProgressHUD hideHUDForView:weakSelf.view.window animated:YES];
                            }
                        }];
    }
    else {
        DEBUG_LOG(@"Creating appending request error: %@", clientError);
    }
}

// Finalize task
- (void)apiClient:(TWTRAPIClient *)client finializeUploadingWithMedicaId:(NSString *)mediaId;
{
    NSDictionary *params = @{
                             @"command" : @"FINALIZE",
                             @"media_id" : mediaId
                             };
    NSError *clientError = nil;
    NSURLRequest *request = [client URLRequestWithMethod:@"POST"
                                                     URL:kTwitterAPIUploadMedia
                                              parameters:params
                                                   error:&clientError];
    __weak typeof(self) weakSelf = self;
    [client sendTwitterRequest:request
                    completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                        if (data) {
                            // publish video with status
                            [weakSelf apiClient:client
                            updateStatuWithText:weakSelf.titleVideo
                                       medicaId:mediaId];
                        }
                        else {
                            [MBProgressHUD hideHUDForView:weakSelf.view.window animated:YES];
                            DEBUG_LOG(@"Finalize error: %@", connectionError);
                        }
                    }];
}

- (void)apiClient:(TWTRAPIClient *)client updateStatuWithText:(NSString *)status medicaId:(NSString *)mediaId;
{
    NSError *clientError = nil;
    NSDictionary *params = @{
                             @"status" : status,
                             @"wrap_links" : @"false",
                             @"media_ids" : mediaId
                             };
    NSURLRequest *request = [client URLRequestWithMethod:@"POST"
                                                     URL:kTwitterAPIUpdateStatus
                                              parameters:params
                                                   error:&clientError];
    __weak typeof(self) weakSelf = self;
    [client sendTwitterRequest:request
                    completion:^(NSURLResponse *urlResponse, NSData *responseData, NSError *connectionError) {
                        if(!connectionError){
                            NSError *jsonError;
                            NSDictionary *json = [NSJSONSerialization
                                                  JSONObjectWithData:responseData
                                                  options:0
                                                  error:&jsonError];
                            DEBUG_LOG(@"Update status: %@", json);
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [Utils showAlert:nil // @"Video Uploaded"
                                         message:@"Share to Twitter successfully"];
                            });
                        }
                        else {
                            DEBUG_LOG(@"Update status error: %@", connectionError);
                        }
                        [MBProgressHUD hideHUDForView:weakSelf.view.window animated:YES];
                    }];
}

//*****************************************************************************
#pragma mark -
#pragma mark - Youtube Authentication

// Helper to check if user is authorized
- (BOOL)isYoutubeAuthorized;
{
    return [((GTMOAuth2Authentication *)self.youtubeService.authorizer) canAuthorize];
}

// Creates the auth controller for authorizing access to YouTube.
- (GTMOAuth2ViewControllerTouch *)createAuthController
{
    GTMOAuth2ViewControllerTouch *authController;
    
    authController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:kGTLAuthScopeYouTube
                                                                clientID:kClientID
                                                            clientSecret:kClientSecret
                                                        keychainItemName:kKeychainItemName
                                                                delegate:self
                                                        finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    return authController;
}

// Handle completion of the authorization process, and updates the YouTube service with the new credentials.
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)authResult
                 error:(NSError *)error
{
    if (error != nil) {
        [self showAlertViewWithTitle:@"Authentication Error" message:error.localizedDescription];
        self.youtubeService.authorizer = nil;
    }
    else {
        self.youtubeService.authorizer = authResult;
        [self shareYoutube];
    }
}

//*****************************************************************************
#pragma mark -
#pragma mark - Youtube Delegate

- (void)uploadYouTubeVideo:(YouTubeUploadVideo *)uploadVideo
      didFinishWithResults:(GTLYouTubeVideo *)video;
{
    [MBProgressHUD hideHUDForView:self.view.window animated:YES];
    
    [Utils showAlert:nil // @"Video Uploaded"
             message:@"Share to YouTube successfully"]; // video.identifier
}

//*****************************************************************************
#pragma mark -
#pragma mark - ** IBAction methods **

- (IBAction)youtubeButtonDidTouch:(id)sender;
{
    [self shareYoutube];
}

- (IBAction)instagramButtonDidTouch:(id)sender;
{
    if ([BEBInstagram isAppInstalled]) {
        [BEBInstagram postVideo:self.videoURL withCaption:@""];
    }
    else {
        NSString *title = @"Instagram Not Installed!";
        NSString *message = @"Instagram not installed in this device!\nTo share video please install Instagram.";
        [self showAlertViewWithTitle:title message:message];
    }
}

- (IBAction)twitterButtonDidTouch:(id)sender;
{
    if (self.videoTime > 30) {
        // Show alert limit video time.
        NSString *title = @"Video Time Limit";
        NSString *message = @"Video time must less than 30 seconds for sharing Twitter. Please change FPS bigger when create video.";
        [self showAlertViewWithTitle:title message:message];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    ACAccountStoreRequestAccessCompletionHandler completion = ^(BOOL granted, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                NSArray *accounts = [accountStore accountsWithAccountType:accountType];
                if (accounts.count > 0) {
                    ACAccount *account = [accounts lastObject];
                    NSString *userID = ((NSDictionary*)[account valueForKey:@"properties"])[@"user_id"];
                    BEBSharingVideoViewController *strongSelf = weakSelf;
                    [strongSelf uploadVideoWithUserId:userID];
                }
                else {
                    // Show error message no Twitter account.
                    NSString *title = @"No Twitter Accounts";
                    NSString *message = @"There are no Twitter accounts configured. You can add or create a Twitter account by going to Settings > Twitter on your device.";
                    [self showAlertViewWithTitle:title message:message];
                }
            }
            else {
                // Show error message not granted access Twitter account.
                NSString *title = @"No Access To Twitter";
                NSString *message = @"BellyBump needs permission to access your Twitter account. You can control this by going to Settings > Twitter on your device.";
                [self showAlertViewWithTitle:title message:message];
            }
        });
    };
    
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:completion];
}

- (IBAction)saveToAlbumButtonDidTouch:(id)sender;
{
    [self saveVideoToAlbum];
}

- (IBAction)shareMoreButtonDidTouch:(id)sender;
{
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[self.videoURL]
                                                                             applicationActivities:nil];
    
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePostToWeibo,
                                   UIActivityTypePrint,
                                   UIActivityTypeCopyToPasteboard,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo,
                                   UIActivityTypePostToTencentWeibo];
    
    activityVC.excludedActivityTypes = excludeActivities;
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (IBAction)viewStoryButtonDidTouch:(id)sender;
{
//    NSArray *viewControllers = self.navigationController.viewControllers;
//    UIViewController *vc = viewControllers[viewControllers.count - 3];
//    [self.navigationController popToViewController:vc animated:YES];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)tip17ButtonClick:(id)sender {
    [self.tip17Close setHidden:YES];
    [self.tip17ImageView setHidden:YES];
    [[NSUserDefaults standardUserDefaults] setObject:@"passed" forKey:@"tip17Name"];
}

@end

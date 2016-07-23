#import <MessageUI/MessageUI.h>
#import "BEBSettingsViewController.h"
#import "BEBSettingsCell.h"
#import "BEBDataManager.h"
#import "BEBSettings.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Twitter/Twitter.h>
#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>
#import "GTLYouTube.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "Utils.h"

#define KAUTHURL @"https://api.instagram.com/oauth/authorize/"
#define kAPIURl @"https://api.instagram.com/v1/users/"
#define KCLIENTID @"cf78f65c5f7c460989c3460fde6e4e92"
#define KCLIENTSERCRET @"d9acdf9adfc64096ab5ba0e06f89eec8"
#define kREDIRECTURI @"http://www.bellybump.co"
@interface BEBSettingsViewController () <BEBSettingsCellDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;@property (nonatomic) NSUserDefaults *prefs;
@property (nonatomic) NSMutableData *receivedData;

@property (nonatomic, strong) GTLServiceYouTube *youtubeService;
@end
UIActivityIndicatorView *indicator;

@implementation BEBSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getSocialUsername:)
                                                 name:kGetUserNameFacebookNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getSocialUsername:)
                                                 name:kGetUserNameTwitterNotification
                                               object:nil];
    self.prefs = [NSUserDefaults standardUserDefaults];
    if (!IS_IPHONE_4 || !IS_IPHONE_5)
    {
    }else{
        self.tableView.scrollEnabled = NO;
    }
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.webView addSubview:indicator];
    [indicator setHidden:YES];
    
    [self.prefs setObject:@"passed" forKey:@"tip2Name"];
}

- (void)viewDidAppear:(BOOL)animated
{    
    [super viewDidAppear:animated];
    
//    BEBSettings *settings = [BEBDataManager sharedManager].settings;
//    [settings getSocialUsernameFacebook];
//    [settings getSocialUsernameTwitter];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//*****************************************************************************
#pragma mark -
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 3;
        case 1:
            return 1;
        case 2:
            return 4;
        default:
            return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BEBSettingsCell *cell = [tableView dequeueReusableCellWithIdentifier:kSettingsCellIdentifier forIndexPath:indexPath];
    CGFloat scale = IS_IPHONE_5 ? 0.7f : IS_IPHONE_6 ? 0.77f : 0.8f;
    cell.settingsSwitch.transform = CGAffineTransformMakeScale(scale, scale);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.facebookImageView setHidden:YES];
    [cell.twitterImageView setHidden:YES];
    [cell.instagramImageView setHidden:YES];
    [cell.youtubuImageView setHidden:YES];
    [cell.socialUsername setHidden:YES];
    [cell.settingsSwitch setHidden:NO];
    [cell.titleLabel setHidden:NO];
    cell.indexPath = indexPath;
    cell.delegate = self;
    
    BEBSettings *settings = [BEBDataManager sharedManager].settings;
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            cell.titleLabel.text = @"daily";
            cell.containerView.backgroundColor = RGB(250, 218, 229, 1);
            cell.settingsSwitch.on = settings.reminderDaily;
        }
        else if (indexPath.row == 1) {
            cell.titleLabel.text = @"weekly";
            cell.containerView.backgroundColor = RGB(255, 245, 230, 1);
            cell.settingsSwitch.on = settings.reminderWeekly;
        }
        else {
            cell.titleLabel.text = @"bi-weekly";
            cell.containerView.backgroundColor = RGB(199, 224, 228, 1);
            cell.settingsSwitch.on = settings.reminderBiWeekly;
        }
    }
    else if (indexPath.section == 1) {
        cell.titleLabel.text = @"auto save";
        cell.containerView.backgroundColor = RGB(252, 220, 206, 1);
        cell.settingsSwitch.on = settings.autoSave;
    }
    else if (indexPath.section == 2) {
        
        [cell.socialUsername setHidden:NO];
        [cell.titleLabel setHidden:YES];
        [cell.settingsSwitch setHidden:YES];
        
        if (indexPath.row == 0) {
            [cell.facebookImageView setHidden:NO];
            NSString *name =[self.prefs stringForKey:@"facebookName"];
            if(name == nil) name = @"";
            cell.socialUsername.text = name;
            cell.containerView.backgroundColor = RGB(150, 185, 212, 1);
        }
        else if(indexPath.row == 1){
            [cell.twitterImageView setHidden:NO];
            NSString *name =[self.prefs stringForKey:@"twitterName"];
            if(name != nil){
                cell.socialUsername.text = [NSString stringWithFormat:@"@%@", name];
            }
            else {
                cell.socialUsername.text = @"";
            }
            cell.containerView.backgroundColor = RGB(185, 212, 232, 1);
        }else if(indexPath.row == 2){
            [cell.instagramImageView setHidden:NO];
            NSString *name =[self.prefs stringForKey:@"instagramName"];
            if(name != nil){
                cell.socialUsername.text = [NSString stringWithFormat:@"@%@", name];
            }
            else {
                cell.socialUsername.text = @"";
            }
            cell.containerView.backgroundColor = RGB(198, 180, 154, 1);
            
        }else if(indexPath.row == 3){
            [cell.youtubuImageView setHidden:NO];
            NSString *name =[self.prefs stringForKey:@"youtubeName"];
            if(name != nil){
                cell.socialUsername.text = [NSString stringWithFormat:@"@%@", name];
            }
            else {
                cell.socialUsername.text = @"";
            }
            cell.containerView.backgroundColor = RGB(215, 41, 35, 1);
            
        }
    }
    else {
        [cell.settingsSwitch setHidden:YES];
        
        if (indexPath.row == 0) {
            cell.titleLabel.text = @"have an idea?";
            cell.containerView.backgroundColor = RGB(199, 224, 228, 1);
        }
        else {
            cell.titleLabel.text = @"find a bug?";
            cell.containerView.backgroundColor = RGB(250, 218, 229, 1);
        }
    }
    
    return cell;
}

//*****************************************************************************
#pragma mark -
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (IS_IPHONE_5 ? 33.0f : IS_IPHONE_6 ? 36.0f : 38.0f);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSArray *heights = nil;
    if (IS_IPHONE_5) {
        heights = @[@24, @43, @43, @43];
    }
    else if (IS_IPHONE_6) {
        heights = @[@30, @52, @52, @52];
    }
    else {
        heights = @[@38, @60, @60, @60];
    }
    return [heights[section] floatValue];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray *heights = nil;
    CGFloat labelX, labelH, fontSize;
    if (IS_IPHONE_5) {
        heights = @[@24, @43, @43, @43];
        labelX = 14.0f;
        labelH = 14.0f;
        fontSize = 11.0f;
    }
    else if (IS_IPHONE_6) {
        heights = @[@30, @52, @52, @52];
        labelX = 14.0f;
        labelH = 16.0f;
        fontSize = 11.0f;
    }
    else {
        heights = @[@38, @60, @60, @60];
        labelX = 15.0f;
        labelH = 18.0f;
        fontSize = 12.0f;
    }
    CGFloat rectHeight = [heights[section] floatValue];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, rectHeight)];
    view.backgroundColor = RGB(236, 239, 241, 1);
    
    NSArray *texts = @[@"REMINDERS", @"PHOTOS", @"LINKED ACCOUNTS", @"HELP US IMPROVE"];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(labelX, rectHeight - labelH, 150, labelH)];
    label.font = [UIFont fontWithName:@"OpenSans-Light" size:fontSize];
    label.backgroundColor = RGB(236, 239, 241, 1);
    label.textColor = RGB(139, 139, 138, 1);
    label.text = texts[section];
    
    [view addSubview:label];
    
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 3 && [MFMailComposeViewController canSendMail]) {
        
        NSString *subject;
        if (indexPath.row == 0) {
            subject = @"Have an idea";
        }
        else {
            subject = @"Find a bug";
        }
        
        MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] init];
        composeViewController.mailComposeDelegate = self;
        
        [composeViewController setSubject:subject];
        [composeViewController setMessageBody:@"" isHTML:NO];
        [composeViewController setToRecipients:@[kReceiveFeedbackEmail]];
        
        [self presentViewController:composeViewController animated:YES completion:nil];
    }else if(indexPath.section == 2){
        if(indexPath.row == 0){ // facebook
            [self FacebookLogin:nil];
        }else if(indexPath.row == 1){ // twitter
            [self TwitterLogin];
        }else if(indexPath.row == 2){ // instagram
            [self InstagramLogin];
        }else if(indexPath.row == 3){ // youtubu
            [self YoutubuLogin];
        }
        
    }
}

-(void)InstagramLogin{
    
    NSString *url = [NSString stringWithFormat:@"%@?client_id=%@&redirect_uri=%@&response_type=code",KAUTHURL,KCLIENTID,kREDIRECTURI];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    [self.webView setHidden:NO];
    [indicator startAnimating];
    [indicator setHidden:NO];
}
-(void)YoutubuLogin{
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
        authController.title = @"Youtube Login";
        [self.navigationController pushViewController:authController animated:YES];
    }else{
        NSString* email = [self.youtubeService.authorizer userEmail];
        //                    settings.usernameFacebook = email;
        [self.prefs setObject:email forKey:@"youtubeName"];
        [self.tableView reloadData];
    }
}

-(void)TwitterLogin{
    
    BEBSettings *settings = [BEBDataManager sharedManager].settings;
    if([settings.usernameTwitter isEqualToString:@""]){
        [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
            if (session) {
//                BEBSettings *settings = [BEBDataManager sharedManager].settings;
                NSString *name = [session userName];
//                settings.usernameTwitter = name;
                [self.prefs setObject:name forKey:@"twitterName"];
                [self.tableView reloadData];
                //            NSLog(@"signed in as %@", [session userName]);
            } else {
                //            NSLog(@"error: %@", [error localizedDescription]);
            }
        }];

    
    }
}

- (IBAction)FacebookLogin:(id)sender {
    BEBSettings *settings = [BEBDataManager sharedManager].settings;
    if([settings.usernameFacebook isEqualToString:@""]){
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        if([FBSDKAccessToken currentAccessToken])
        {
            [self fetchUserInfo];
        }else{
            [login logInWithReadPermissions:@[@"email"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                if(error)
                {
                    NSLog(@"Login process error");
                }else if(result.isCancelled){
                    NSLog(@"User cancelled login");
                }else{
                    NSLog(@"Login success");
                    if([result.grantedPermissions containsObject:@"email"])
                    {
                        [self fetchUserInfo];
                    }else{
                        //                    [SVProgressHUD showErrorWithStatus:@"Facebook email permission error"];
                    }
                }
            }];
        }
    }
}
-(void)fetchUserInfo{
    if([FBSDKAccessToken currentAccessToken])
    {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields":@"id, name, email"}] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            if(!error)
            {
                NSString *email = [result objectForKey:@"email"];
//                NSString *userId = [result objectForKey: @"id"];
                if(email.length > 0){
//                    BEBSettings *settings = [BEBDataManager sharedManager].settings;
//                    settings.usernameFacebook = email;
                    [self.prefs setObject:email forKey:@"facebookName"];
                    [self.tableView reloadData];
                }else{
                    NSLog(@"Facebook email is not verified");
                }
            }else
            {
                NSLog(@"Error %@", error);
            }
        }];
    }
}

//*****************************************************************************
#pragma mark -
#pragma mark - ** BEBSettingsCellDelegate **
- (void)bebSettingsCell:(BEBSettingsCell *)cell didTurnOn:(BOOL)on atIndexPath:(NSIndexPath *)indexPath
{
    BEBDataManager *dataManager = [BEBDataManager sharedManager];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [dataManager updateReminderDailySettingsOn:on];
        }
        else if (indexPath.row == 1) {
            [dataManager updateReminderWeeklySettingsOn:on];
        }
        else {
            [dataManager updateReminderBiWeeklySettingsOn:on];
        }
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [dataManager updateAutoSaveSettingsOn:on];
        }
    }
}

//*****************************************************************************
#pragma mark -
#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    if (error) {
        DEBUG_LOG(@"Error: %@", error.localizedDescription);
    }
    
    switch (result) {
        case MFMailComposeResultCancelled:
            DEBUG_LOG(@"Result: canceled");
            break;
        case MFMailComposeResultSaved:
            DEBUG_LOG(@"Result: saved");
            break;
        case MFMailComposeResultSent:
            DEBUG_LOG(@"Result: sent");
            break;
        case MFMailComposeResultFailed:
            DEBUG_LOG(@"Result: failed");
            break;
        default:
            DEBUG_LOG(@"Result: not sent");
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

//*****************************************************************************
#pragma mark -
#pragma mark - ** Notification get social username **
- (void)getSocialUsername:(NSNotification *)notif
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}
#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    //    [indicator startAnimating];
    NSString *asds =[[request URL] host];
    if ([[[request URL] host] isEqualToString:@"www.bellybump.co"]) {//drive.google.com/a/bellybump.co/file/d/0B6BG0gbw02UXUnd5YVFEcnhfeHM/view
        
        // Extract oauth_verifier from URL query
        NSString* verifier = nil;
        NSString* urlString = [[request URL] absoluteString];
        NSArray* urlParams = [urlString componentsSeparatedByString:[NSString stringWithFormat:@"%@/", kREDIRECTURI]];
        urlString = [urlParams objectAtIndex:1];
        NSRange accessToken = [urlString rangeOfString:@"?code="];
        if(accessToken.location != NSNotFound){
            verifier = [urlString substringFromIndex: NSMaxRange(accessToken)];
        }
        
        if (verifier) {
        
            NSString *data = [NSString stringWithFormat:@"client_id=%@&client_secret=%@&grant_type=authorization_code&redirect_uri=%@&code=%@",KCLIENTID,KCLIENTSERCRET,kREDIRECTURI,verifier];
            
            NSString *url = [NSString stringWithFormat:@"https://api.instagram.com/oauth/access_token"];
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
            [request setHTTPMethod:@"POST"];
            [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
            NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
            self.receivedData = [[NSMutableData alloc] init];
            [self.webView setHidden:YES];
            [indicator stopAnimating];
        } else {
            //            // ERROR!
            
            [indicator stopAnimating];
            [webView removeFromSuperview];
        }
        
        return NO;
    }
    return YES;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
     [indicator stopAnimating];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.receivedData appendData:data];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    [indicator stopAnimating];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:[NSString stringWithFormat:@"%@", error]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *response = [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding];
    NSData *jsonData = [response dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:nil error:&e];
    NSString* username = [[dict valueForKey:@"user"] objectForKey:@"username"];
    
    [self.prefs setObject:username forKey:@"instagramName"];
    [self.tableView reloadData];
    
    [self.webView setHidden:YES];
    [indicator stopAnimating];
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
//        [self showAlertViewWithTitle:@"Authentication Error" message:error.localizedDescription];
        self.youtubeService.authorizer = nil;
    }
    else {
        self.youtubeService.authorizer = authResult;
        NSString* email = [self.youtubeService.authorizer userEmail];
        //                    settings.usernameFacebook = email;
        [self.prefs setObject:email forKey:@"youtubeName"];
        [self.tableView reloadData];
//        [self shareYoutube];
    }
}

@end

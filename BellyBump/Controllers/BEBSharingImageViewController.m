
#import "BEBSharingImageViewController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "BEBInstagram.h"
#import "BEBDataManager.h"
#import "BEBSettings.h"
#import "ImageCropView.h"

@interface BEBSharingImageViewController ()<ImageCropViewControllerDelegate>

@property (nonatomic, strong) UIImage *watermarkImage;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *shareView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topPhotoAddedConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topShareViewConstraint;
@property (weak, nonatomic) IBOutlet UILabel *photoAddedLabel;
@property (weak, nonatomic) IBOutlet UIButton *saveToAlbumButton;
@property (weak, nonatomic) IBOutlet UIImageView *tip17ImageView;
@property (weak, nonatomic) IBOutlet UIButton *tip17Close;

- (IBAction)facebookButtonDidTouch:(id)sender;
- (IBAction)instagramButtonDidTouch:(id)sender;
- (IBAction)twitterButtonDidTouch:(id)sender;
- (IBAction)saveToAlbumButtonDidTouch:(id)sender;
- (IBAction)closeButtonClick:(id)sender;
- (IBAction)tip17ButtonClick:(id)sender;

@end

@implementation BEBSharingImageViewController

- (void)viewDidLoad;
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title =  @"SHARE PHOTO";
    self.photoAddedLabel.layer.cornerRadius = CGRectGetHeight(self.photoAddedLabel.frame) / 2;
    self.photoAddedLabel.clipsToBounds = YES;
    
    if (IS_IPHONE_4) {
        self.topPhotoAddedConstraint.constant = 30.0f;
        [self.imageView layoutIfNeeded];
        
        self.topShareViewConstraint.constant = 100.0f;
        [self.shareView layoutIfNeeded];
    }
    
    // Make water mark for image.
    self.watermarkImage = [BEBUtilities generateWatermarkForImage:self.image];
    
    BEBSettings *settings = [BEBDataManager sharedManager].settings;
    if ([settings isAutoSave]) {
        UIImageWriteToSavedPhotosAlbum(self.image, nil, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        
        self.saveToAlbumButton.enabled = NO;
    }
    
    return;
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

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
}

- (void)didReceiveMemoryWarning;
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

- (IBAction)facebookButtonDidTouch:(id)sender;
{
    // Handle sharing with the Facebook
    SLComposeViewController *vc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    [vc setInitialText:@""];
    [vc addImage:self.watermarkImage];

    [self presentViewController:vc animated:NO completion:nil];
}

// CropImage for upload instagram
- (void)cropImage:(UIImage *)image{
    ImageCropViewController *controller = [[ImageCropViewController alloc] initWithImage:image];
    controller.delegate = self;
    [[self navigationController] pushViewController:controller animated:YES];
}

- (void)ImageCropViewControllerSuccess:(ImageCropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage{
    
    [[self navigationController] popViewControllerAnimated:YES];
    
     UIImage *image = [BEBUtilities generateWatermarkForImage:croppedImage];
     [BEBInstagram postImage:image withCaption:@"" inView:self.view];
    // share image to instagram
    
}

- (void)ImageCropViewControllerDidCancel:(ImageCropViewController *)controller{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)instagramButtonDidTouch:(id)sender;
{
    if ([BEBInstagram isAppInstalled]) {
        if (self.image) {
            [self cropImage:self.image];
        } 
    }else{
        NSString *title = @"Instagram Not Installed!";
        NSString *message = @"Instagram not installed in this device!\nTo share image please install Instagram.";
        [self showAlertViewWithTitle:title message:message];
    }
    /*
    if ([BEBInstagram isAppInstalled]) {
        
        if (self.watermarkImage != nil){
            CGRect CropRect;
            if(self.watermarkImage.size.height > self.watermarkImage.size.width){
                CropRect = CGRectMake(0, 0, self.watermarkImage.size.width, self.watermarkImage.size.width);
            }else{
                CropRect = CGRectMake(0, 0, self.watermarkImage.size.height, self.watermarkImage.size.height);
                
            };
            CGImageRef imageRef = CGImageCreateWithImageInRect([self.watermarkImage CGImage], CropRect) ;
            UIImage *cropped = [UIImage imageWithCGImage:imageRef];
            CGImageRelease(imageRef);
            cropped = [BEBUtilities generateWatermarkForImage:cropped];
            if (cropped) {
                [BEBInstagram postImage:cropped withCaption:@"" inView:self.view];
            }
            else {
                NSString *title = @"Message";
                NSString *message = @"Something wrong. Please try again.";
                [self showAlertViewWithTitle:title message:message];
            }
        }
    }
    else {
        NSString *title = @"Instagram Not Installed!";
        NSString *message = @"Instagram not installed in this device!\nTo share image please install Instagram.";
        [self showAlertViewWithTitle:title message:message];
    }*/
//
//    if ([BEBInstagram isAppInstalled]) {
//        [BEBInstagram postImage:self.watermarkImage withCaption:@"" inView:self.view];
//    }
//    else {
//        NSString *title = @"Instagram Not Installed!";
//        NSString *message = @"Instagram not installed in this device!\nTo share image please install Instagram.";
//        [self showAlertViewWithTitle:title message:message];
//    }
}

- (IBAction)twitterButtonDidTouch:(id)sender;
{
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    ACAccountStoreRequestAccessCompletionHandler completion = ^(BOOL granted, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                SLComposeViewController *vc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                [vc setInitialText:@""];
                [vc addImage:self.watermarkImage];
                [self presentViewController:vc animated:NO completion:nil];
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
    self.saveToAlbumButton.enabled = NO;
    
    UIImageWriteToSavedPhotosAlbum(self.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
{
    NSString *title, *message;
    
    if (error) {
        title = @"Error";
        message = @"Unable to save image to Photo Album.";
    }
    else {
        title = @"Success";
        message = @"Image saved to Photo Album.";
    }
    
    [self showAlertViewWithTitle:title message:message];
    
    self.saveToAlbumButton.enabled = YES;

}

- (IBAction)closeButtonClick:(id)sender;
{
    if ([self.delegate respondsToSelector:@selector(bebSharingImageViewController:dismissWithAnimation:)]) {
        [self.delegate bebSharingImageViewController:self dismissWithAnimation:YES];
    }
}

- (IBAction)tip17ButtonClick:(id)sender {
    return;
    [self.tip17ImageView setHidden:YES];
    [self.tip17Close setHidden:YES];
    [[NSUserDefaults standardUserDefaults] setObject:@"passed" forKey:@"tip17Name"];
}

@end

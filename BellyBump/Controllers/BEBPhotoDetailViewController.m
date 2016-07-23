#import "BEBPhotoDetailViewController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "BEBInstagram.h"
#import "BEBStory.h"
#import "BEBImage.h"
#import "BEBDataManager.h"
#import "BEBCamViewController.h"
#import "BEBImageEditorViewController.h"
#import "BEBTextEditorViewController.h"
#import "ImageCropView.h"
#import "UIImage+Scale.h"


@interface BEBPhotoDetailViewController ()<BEBCamViewControllerDelegate, UINavigationControllerDelegate,
UIImagePickerControllerDelegate, HFImageEditorViewControllerDelegate, ImageCropViewControllerDelegate>

#pragma mark - Properties
@property (nonatomic, copy) NSString *currentImageURL;
@property (nonatomic, strong) NSMutableArray *imageViews;
@property (nonatomic, strong) UIImagePickerController *picker;
@property (nonatomic, strong) UINavigationController *presentVC;
@property (nonatomic) BOOL editTextOnly;
#pragma mark - IBOutlets
@property (weak, nonatomic) IBOutlet UILabel *nameStoryLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *deletePhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *replacePhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *openCameraButton;
@property (weak, nonatomic) IBOutlet UIButton *openLibraryButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *instagramButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *saveToDiskButton;

#pragma mark - IBActions
- (IBAction)closeButtonDidTouch:(id)sender;
- (IBAction)fontButtonDidTouch:(id)sender;
- (IBAction)shareFacebookButtonDidTouch:(id)sender;
- (IBAction)shareInstagramButtonDidTouch:(id)sender;
- (IBAction)shareTwitterButtonDidTouch:(id)sender;
- (IBAction)saveToDiskButtonDidTouch:(id)sender;
- (IBAction)deletePhotoButtonDidTouch:(id)sender;
- (IBAction)replacePhotoButtonDidTouch:(id)sender;
- (IBAction)openCameraButtonDidTouch:(id)sender;
- (IBAction)openLibraryButtonDidTouch:(id)sender;

@end

@implementation BEBPhotoDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.nameStoryLabel.text = self.story.title;
    self.nameStoryLabel.layer.cornerRadius = CGRectGetHeight(self.nameStoryLabel.frame)/2.0;
    self.nameStoryLabel.clipsToBounds = YES;
    
    self.editTextOnly = NO;
    self.deletePhotoButton.layer.cornerRadius = CGRectGetHeight(self.deletePhotoButton.frame)/2.0;
    self.deletePhotoButton.clipsToBounds = YES;
    
    self.replacePhotoButton.layer.cornerRadius = CGRectGetHeight(self.replacePhotoButton.frame)/2.0;
    self.replacePhotoButton.clipsToBounds = YES;
    
    if (IS_IPHONE_4) {
        CGRect frame = self.scrollView.frame;
        frame.size.height -= 88.0f;
        self.scrollView.frame = frame;
    }
    
    [self updateImagesForScrollView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateImagesForScrollView;
{
    for (UIImageView *imageView in self.imageViews) {
        [imageView removeFromSuperview];
    }
    
    self.imageViews = [NSMutableArray array];
    NSInteger count = self.story.photos.count;
    CGFloat margin = IS_IPHONE_6PLUS ? 27.0f : IS_IPHONE_6 ? 22.0f : 20.0f;
    for (NSInteger i = 0; i < count; i++) {
        CGFloat width = CGRectGetWidth(self.scrollView.frame);
        CGFloat height = CGRectGetHeight(self.scrollView.frame);
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(width * i + margin, 0, width - margin * 2, height)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.clipsToBounds = YES;
        [self.scrollView addSubview:imageView];
        [self.imageViews addObject:imageView];
    }
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame) * count,
                                             CGRectGetHeight(self.scrollView.frame));
    [self scrollToPage:self.currentPage];
}

- (void)scrollToPage:(NSInteger)page
{
    self.currentPage = page;
    
    // Load Data
    [self loadDataOnPage:page];
    [self loadDataOnPage:page - 1];
    [self loadDataOnPage:page + 1];
    
    // Scroll to visible page
    CGRect bounds = self.scrollView.bounds;
    bounds.origin.x = CGRectGetWidth(bounds) * page;
    bounds.origin.y = 0;
    [self.scrollView scrollRectToVisible:bounds animated:NO];
}

- (void)loadDataOnPage:(NSInteger)page
{
    if (page < 0 || page >= self.story.photos.count)
        return;
    
    BEBImage *bebImage = self.story.photos[page];
    self.currentImageURL = [NSString stringWithFormat:@"%@/%@", [BEBUtilities userCacheDirectory], bebImage.localPath];
    UIImage *image;
    if (bebImage.captionImage) {
        image = bebImage.captionImage;
    }
    else {
        image = bebImage.image;
    }
    
    if (image || page != self.currentPage) {
        if (image) {
            UIImageView *imageView = self.imageViews[page];
            imageView.image = image;
            if (page == self.currentPage) {
                [self.loadingIndicator stopAnimating];
                [self enableShareButtons:YES];
            }
        }
    }
    else {
        [self.loadingIndicator startAnimating];
        [self.loadingIndicator setHidden:NO];
        [self enableShareButtons:NO];
        
        // Download image from S3
        __weak typeof(self) weakSelf = self;
        [bebImage getImageFromS3:^(NSString *url) {
            dispatch_async(dispatch_get_main_queue(), ^{
                BEBPhotoDetailViewController *strongSelf = weakSelf;
                if ([strongSelf.currentImageURL isEqualToString:url]) {
                    UIImageView *imageView = strongSelf.imageViews[strongSelf.currentPage];
                    imageView.image = bebImage.image;
                    [strongSelf.loadingIndicator stopAnimating];
                    [strongSelf enableShareButtons:YES];
                }
            });
        }];
    }
}

- (void)enableShareButtons:(BOOL)isEnabled;
{
    [self.facebookButton setEnabled:isEnabled];
    [self.instagramButton setEnabled:isEnabled];
    [self.twitterButton setEnabled:isEnabled];
    [self.saveToDiskButton setEnabled:isEnabled];
}

- (UIImage *)createWaterMarkCurrentImage;
{
    BEBImage *bebImage = self.story.photos[self.currentPage];
    
    if (bebImage.captionImage) {
        return [BEBUtilities generateWatermarkForImage:bebImage.captionImage];
    }
    return [BEBUtilities generateWatermarkForImage:bebImage.image];
}

// CropImage for upload instagram
- (void)cropImage:(UIImage *)image{
    ImageCropViewController *controller = [[ImageCropViewController alloc] initWithImage:image];
    controller.delegate = self;
    [[self navigationController] pushViewController:controller animated:YES];
}

- (void)ImageCropViewControllerSuccess:(ImageCropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage{
    // Make imagesize to instagram size
//    UIImage *scaledImage = [croppedImage scaleToSize:CGSizeMake(1080.0f, 1080.0f)];
//    image = croppedImage;
//    imageView.image = croppedImage;

    BEBImage *bebImage = self.story.photos[self.currentPage];
    
    if (bebImage.captionImage) {
        bebImage.captionImage = croppedImage;
    } else
        bebImage.image = croppedImage;
    
    [[self navigationController] popViewControllerAnimated:YES];
    
    
    // share image to instagram
    if ([BEBInstagram isAppInstalled]) {
        UIImage *image = [self createWaterMarkCurrentImage];
        if (image) {
            [BEBInstagram postImage:image withCaption:@"" inView:self.view];
        }
        else {
            NSString *title = @"Message";
            NSString *message = @"Something wrong. Please try again.";
            [self showAlertViewWithTitle:title message:message];
        }
    }
    else {
        NSString *title = @"Instagram Not Installed!";
        NSString *message = @"Instagram not installed in this device!\nTo share image please install Instagram.";
        [self showAlertViewWithTitle:title message:message];
    }
}

- (void)ImageCropViewControllerDidCancel:(ImageCropViewController *)controller{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)deleteCurrentPhoto;
{
    // Get delete image
    BEBImage *bebImage = self.story.photos[self.currentPage];
    
    // Delete item data model
    [self.story.photos removeObjectAtIndex:self.currentPage];
    [[BEBDataManager sharedManager].deletedImages addObject:bebImage];
    
    // Delete image from S3
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Save story data to file to cache local
        [[BEBDataManager sharedManager] saveStoryDataToFile];
        [[BEBDataManager sharedManager] saveDeletedImagesToFile];
        [bebImage deleteImageLocal];
        
        // Save data to S3
        [[BEBDataManager sharedManager] saveDataToS3:nil];
        [[BEBDataManager sharedManager] syncDeletedImagesToS3];
    });
    
    if (self.story.photos.count > 0) {
        
        if (self.currentPage >= self.story.photos.count) {
            self.currentPage = self.story.photos.count - 1;
        }
        
        [self updateImagesForScrollView];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

//*****************************************************************************
#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView;
{
    scrollView.scrollEnabled = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
{
    CGFloat pageWidth = CGRectGetWidth(self.scrollView.frame);
    NSUInteger page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    if (self.currentPage != page) {
        [self scrollToPage:page];
        [self.openCameraButton setHidden:YES];
        [self.openLibraryButton setHidden:YES];
    }
    
    scrollView.scrollEnabled = YES;
}

//*****************************************************************************
#pragma mark -
#pragma mark ** IBActions **

- (IBAction)closeButtonDidTouch:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)fontButtonDidTouch:(id)sender
{
    self.editTextOnly = YES;
    [self showTextEditorViewController];
}

- (void)imageEditor:(HFImageEditorViewController *)imageEditor
    finishWithImage:(UIImage *)editedImage
       captionImage:(UIImage *)captionImage
             cancel:(BOOL) canceled;
{
    if (canceled) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        if ([imageEditor isKindOfClass:[BEBImageEditorViewController class]]) {
            
            // Add image to story
            [self replaceImageWithEditedImage:editedImage];
            
            if (captionImage) {
                self.editTextOnly = NO;
                [self showTextEditorViewController];
            }
            else {
                
                // Finish
                // Update image and hidden the present view controller

                [self updateImagesForScrollView];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
        else {
            // BEBTextEditorViewController
            // Finish

            // Update image and hidden the present view controller
            [self updateTextForImage:captionImage];
        }
        
        [self.openCameraButton setHidden:YES];
        [self.openLibraryButton setHidden:YES];
    }
}

- (void)showTextEditorViewController;
{
    // Show text edit view controller
    BEBTextEditorViewController *textEditorViewController = (BEBTextEditorViewController*)[self.storyboard instantiateViewControllerWithIdentifier:kBEBTextEditorViewControllerIdentifier];
    
    textEditorViewController.checkBounds = NO;
    textEditorViewController.rotateEnabled = YES;
    textEditorViewController.scaleEnabled = YES;
    textEditorViewController.delegate = self;
    
    BEBImage *image = self.story.photos[self.currentPage];
    textEditorViewController.sourceImage = image.image;
    
    if (self.editTextOnly) {
        [self.navigationController pushViewController:textEditorViewController animated:YES];
    }
    else {
        [self.presentVC pushViewController:textEditorViewController animated:YES];
    }
}

- (void)updateTextForImage:(UIImage *)captionImage
{
    // Update the caption imageto the story list
    BEBImage *image = (BEBImage *)self.story.photos[self.currentPage];
    image.captionImage = captionImage;
    
    if (self.editTextOnly) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    // Reload the image for item
    [self updateImagesForScrollView];
}

- (void)replaceImageWithEditedImage:(UIImage *)croppedImage
{
    // New bebImage with the taken image.
    BEBImage *bebImage = [[BEBImage alloc] init];
    
    // General uiid for image name
    bebImage.uuid = [BEBUtilities getUUID];
    
    // Crop the image to small size
//    CGSize imageSize = croppedImage.size;
//    CGSize videoSize = [BEBUtilities videoSizeByIndex:1];
//    CGFloat scale = MIN(videoSize.width / imageSize.width, videoSize.height / imageSize.height);
    CGFloat scale = 1.0;
    croppedImage = [BEBUtilities scaleImage:croppedImage scaleFactor:scale];
    bebImage.image = croppedImage;
    
    // Save the image to local cache directory
    [bebImage saveImageToLocal];
    
    // Add the image to the story list
    [self.story.photos replaceObjectAtIndex:self.currentPage withObject:bebImage];
    
    // Upload image to s3
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Save story data to file to cache local
        [[BEBDataManager sharedManager] saveStoryDataToFile];
        
        // Save image to S3
        [bebImage saveImageToS3:^(BOOL result) {
            if (result) {
                // Save story data to file to update image saved on S3
                [[BEBDataManager sharedManager] saveStoryDataToFile];
                
                // Save data to S3
                [[BEBDataManager sharedManager] saveDataToS3:nil];
            }
        }];
    });
}

- (IBAction)shareFacebookButtonDidTouch:(id)sender
{
    // Handle sharing with the Facebook
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]){
        SLComposeViewController *vc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        if(vc == nil) {
            NSString *title = @"Message";            
            NSString *message = @"Something wrong. Please try again.";
            [self showAlertViewWithTitle:title message:message];
            
        }else{
            UIImage *image = [self createWaterMarkCurrentImage];
            [vc setInitialText:@""];
            [vc addImage:image];
            
            [self presentViewController:vc animated:NO completion:nil];
        }
    }
}

- (IBAction)shareInstagramButtonDidTouch:(id)sender
{
    if ([BEBInstagram isAppInstalled]) {
        BEBImage *bebImage = self.story.photos[self.currentPage];
        if (bebImage.captionImage) {
            [self cropImage:bebImage.captionImage];
        } else{
            [self cropImage:bebImage.image];
        }
    }else{
        NSString *title = @"Instagram Not Installed!";
        NSString *message = @"Instagram not installed in this device!\nTo share image please install Instagram.";
        [self showAlertViewWithTitle:title message:message];
    }

//    if ([BEBInstagram isAppInstalled]) {
//        
//        if (bebImage.image != nil){
//            CGRect CropRect;
//            if(bebImage.image.size.height > bebImage.image.size.width){
//                CropRect = CGRectMake(0, 0, bebImage.image.size.width, bebImage.image.size.width);
//            }else{
//                CropRect = CGRectMake(0, 0, bebImage.image.size.height, bebImage.image.size.height);
//                
//            };
//            CGImageRef imageRef = CGImageCreateWithImageInRect([bebImage.image CGImage], CropRect) ;
//            UIImage *cropped = [UIImage imageWithCGImage:imageRef];
//            CGImageRelease(imageRef);
//            cropped = [BEBUtilities generateWatermarkForImage:cropped];
//            if (cropped) {
//                [BEBInstagram postImage:cropped withCaption:@"" inView:self.view];
//            }
//            else {
//                NSString *title = @"Message";
//                NSString *message = @"Something wrong. Please try again.";
//                [self showAlertViewWithTitle:title message:message];
//            }
//        }
//    }
//    else {
//        NSString *title = @"Instagram Not Installed!";
//        NSString *message = @"Instagram not installed in this device!\nTo share image please install Instagram.";
//        [self showAlertViewWithTitle:title message:message];
//    }
}

- (IBAction)shareTwitterButtonDidTouch:(id)sender
{
    UIImage *image = [self createWaterMarkCurrentImage];
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    ACAccountStoreRequestAccessCompletionHandler completion = ^(BOOL granted, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                SLComposeViewController *vc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                [vc setInitialText:@""];
                [vc addImage:image];
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

- (IBAction)saveToDiskButtonDidTouch:(id)sender
{
    BEBImage *bebImage = self.story.photos[self.currentPage];
    UIImage *image = bebImage.captionImage ? bebImage.captionImage : bebImage.image;
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
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
}

- (IBAction)deletePhotoButtonDidTouch:(id)sender
{
    // Show alert message to confirm delete
    if (iOS_Version >= 8) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:kConfirmDeletePhotoMessage
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action) {
                                                           [alert dismissViewControllerAnimated:YES completion:nil];
                                                       }];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action) {
                                                       [self deleteCurrentPhoto];
                                                   }];
        
        [alert addAction:cancel];
        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:kConfirmDeletePhotoMessage
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:@"Cancel", nil];
        [alert show];
    }
}

- (IBAction)replacePhotoButtonDidTouch:(id)sender
{
    [self.openCameraButton setHidden:NO];
    [self.openLibraryButton setHidden:NO];
}

- (IBAction)openCameraButtonDidTouch:(id)sender
{
    // View the capture image
    BEBCamViewController *cameraViewController = [self.storyboard instantiateViewControllerWithIdentifier:kCameraCaptureViewControllerIdentifier];
    cameraViewController.delegate = self;
    cameraViewController.story = self.story;
    
    if (self.currentPage > 0) {
        BEBImage *lastImage = self.story.photos[self.currentPage - 1];
        
        // Set the photo as the previous photo
        cameraViewController.previousPhoto = lastImage.image;
    }
    
    // Present the capture image
    [self.navigationController presentViewController:cameraViewController
                                            animated:YES
                                          completion:nil];

}


//*****************************************************************************
#pragma mark -
#pragma mark - ** BEBCamViewControllerDelegate methods **
- (void)bebCamViewController:(BEBCamViewController *)camViewController
           finishedWithImage:(UIImage *)image;
{
    // Init the image editor
    BEBImageEditorViewController *imageEditorViewController = (BEBImageEditorViewController*)[self.storyboard instantiateViewControllerWithIdentifier:kImageEditorViewControllerIdentifier];
    
    imageEditorViewController.checkBounds = YES;
    imageEditorViewController.rotateEnabled = NO;
    imageEditorViewController.scaleEnabled = YES;
    imageEditorViewController.sourceImage = image;
    imageEditorViewController.delegate = self;
    
    imageEditorViewController.previousImage = camViewController.previousPhoto;
    imageEditorViewController.previousImageAlpha = camViewController.previousPhotoView.alpha;
    imageEditorViewController.previousImageHidden = (camViewController.previousPhotoView.image == nil);
    
    // Hidden the camera view and show the image editor view
    [self dismissViewControllerAnimated:NO completion:^{
        self.presentVC = [[UINavigationController alloc] initWithRootViewController:imageEditorViewController];
        [self presentViewController:self.presentVC animated:YES completion:nil];
    }];
}

- (void)showImageEditorViewControllerWithImage:(UIImage *)image
{
    // Select image from LIBRARY -> Edit Image Editor
    BEBImageEditorViewController *imageEditorViewController = (BEBImageEditorViewController*)[self.storyboard instantiateViewControllerWithIdentifier:kImageEditorViewControllerIdentifier];
    
    imageEditorViewController.checkBounds = YES;
    imageEditorViewController.rotateEnabled = NO;
    imageEditorViewController.scaleEnabled = YES;
    imageEditorViewController.sourceImage = image;
    imageEditorViewController.delegate = self;
    
    if (self.currentPage > 0) {
        BEBImage *lastImage = self.story.photos[self.currentPage - 1];
        
        imageEditorViewController.previousImage = lastImage.image;
        imageEditorViewController.previousImageAlpha = 0.4;
        imageEditorViewController.previousImageHidden = YES;
    }

    self.presentVC = [[UINavigationController alloc] initWithRootViewController:imageEditorViewController];
    [self presentViewController:self.presentVC animated:YES completion:nil];
}

- (IBAction)openLibraryButtonDidTouch:(id)sender
{
    // If still not take the photo: show the photo library view selection.
    
    // Show the photo library.
    // Call the image picker view controller
    if (!self.picker) {
        
        // Init the picker image view controller show the photo library
        self.picker = [[UIImagePickerController alloc] init];
        self.picker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
        self.picker.delegate = self;
        self.picker.allowsEditing = NO;
        self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self.picker.navigationBar setBarStyle:UIBarStyleBlack];
        
        self.picker.navigationBar.barTintColor = kNavigationBarColor;
        self.picker.navigationBar.tintColor = [UIColor whiteColor];
        
        NSDictionary *navTextAttributes = @{
                                            NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:15.0f],
                                            NSForegroundColorAttributeName : [UIColor whiteColor]
                                            };
        
        NSDictionary* barButtonItemAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:15.0f]};
        [[UIBarButtonItem appearance] setTitleTextAttributes: barButtonItemAttributes forState:UIControlStateNormal];
        
        [self.picker.navigationBar setTitleTextAttributes:navTextAttributes];
    }
    
    [self presentViewController:self.picker
                       animated:YES
                     completion:nil];
}

//*****************************************************************************
#pragma mark -
#pragma mark ** UIImagePickerViewControllerDelegate **

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
{
    // Show device's status bar
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    // Check media type to ensure that the user has chosen an image (not a camera)
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        // Get the image chosen by the user
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
        [self showImageEditorViewControllerWithImage:image];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated;
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

//*****************************************************************************
#pragma mark -
#pragma mark - ** UIAlertViewDelegate methods **
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if (buttonIndex == 0) {
        [self deleteCurrentPhoto];
    }
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

@end

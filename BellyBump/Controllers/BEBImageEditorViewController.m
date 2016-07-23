#import "HFImageEditorViewController+Private.h"
#import "BEBImageEditorViewController.h"
#import "BEBFontSelectionView.h"
#import "BEBDataManager.h"
#import "MBProgressHUD.h"
#import "BEBTextEditorViewController.h"
#import "BEBStoryboard.h"

static const int margin = 4;
static NSString *const placeHolderText = @"Double tap to edit text";

@interface BEBImageEditorViewController () <BEBFontSelectionViewDelegate, UITextFieldDelegate>

#pragma mark Outlet Propeties
@property (weak, nonatomic) IBOutlet UIImageView *previousImageView;
@property (weak, nonatomic) IBOutlet BEBFontSelectionView *fontSelectionView;
@property (weak, nonatomic) IBOutlet UIView *captionView;
@property (weak, nonatomic) IBOutlet UIView *rotationSelectionView;
@property (weak, nonatomic) IBOutlet UISlider *rotationSlider;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (weak, nonatomic) IBOutlet UIButton *captionButton;
@property (weak, nonatomic) IBOutlet UIButton *cropButton;
@property (weak, nonatomic) IBOutlet UIButton *previousButton;

@property (weak, nonatomic) IBOutlet UITextField *captionTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *captionWidthLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *captionPositionXLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *captionPositionYLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *captionViewWidthLayoutConstraint;

@property (weak, nonatomic) IBOutlet UIImageView *tip10ImageView;
@property (weak, nonatomic) IBOutlet UIButton *tip10Close;


@property (strong, nonatomic) UIPinchGestureRecognizer *pinchGestureRecognizer;
@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognize;
@property (strong, nonatomic) UITapGestureRecognizer *singleTap;
@property (strong, nonatomic) UITapGestureRecognizer *doubleTap;
#pragma mark Propeties
@property (nonatomic) BOOL showPreviousImage;
@property (nonatomic) BOOL editCaptionMode;
@property (nonatomic) CGPoint priorPoint;

#pragma mark - IBActions
- (IBAction)showPreviousButtonClick:(id)sender;
- (IBAction)fontButtonDidTouch:(id)sender;
- (IBAction)cropImageButtonDidTouch:(id)sender;
- (IBAction)acceptButtonDidTouch:(id)sender;
- (IBAction)cancelButtonDidTouch:(id)sender;
- (IBAction)sliderValueChange:(id)sender;
- (IBAction)tip10ButtonClick:(id)sender;
@end

@implementation BEBImageEditorViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.maximumScale = 10;
    
    // Show the previous image (if it display in the capture scene)
    if (self.previousImage) {
        if (!self.previousImageHidden) {
            self.previousImageView.image = self.previousImage;
            self.previousButton.alpha = 0.7f;
        }
        else {
            self.previousButton.alpha = 1.0f;
        }
        
        self.previousImageView.alpha = self.previousImageAlpha;
//        self.previousImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.showPreviousImage = YES;
    }
    else {
        self.previousButton.hidden = YES;
    }
    
    // Set the full screen image capture.
    [self setSquareAction:nil];
    
    // Set the font select
    [self configureFontSelectionView];
    
    [self configureRotationView];
    
    // Add caption Gesture
    [self configureCaptionGestureRecognizer];
    [self viewTip10];
    
    
}
-(void)viewTip10
{
    
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"tip10Name"] isEqualToString:@"passed"]) {
        [self.tip10ImageView setHidden:YES];
        [self.tip10Close setHidden:YES];
    } else {
        [self.tip10ImageView setHidden:NO];
        [self.tip10Close setHidden:NO];
        CABasicAnimation *fadeInAnimate   = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeInAnimate.duration            = 3;
        fadeInAnimate.repeatCount         = 1;
        fadeInAnimate.autoreverses        = NO;
        fadeInAnimate.fromValue           = [NSNumber numberWithFloat:0.0];
        fadeInAnimate.toValue             = [NSNumber numberWithFloat:1.0];
        fadeInAnimate.removedOnCompletion = YES;
        [self.tip10ImageView.layer addAnimation:fadeInAnimate forKey:@"animateOpacity"];
        
        [self.tip10Close.layer addAnimation:fadeInAnimate forKey:@"animateOpacity"];
        [[NSUserDefaults standardUserDefaults] setObject:@"passed" forKey:@"tip10Name"];
    }
    
}
- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    
    [self saveAppearanceSettings];
    
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];

    NSDictionary *textAttributes = @{
                                     NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:15.0f],
                                     NSForegroundColorAttributeName : [UIColor whiteColor]
                                     };
    [self.navigationController.navigationBar setTitleTextAttributes:textAttributes];
    
    [self changeTabSelected:BEBEditImageTabSelectionTypeCropSize];
    self.addTextProcess = NO;

}

- (void)viewWillDisappear:(BOOL)animated;
{
    [super viewWillDisappear:animated];
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    [self.navigationController.navigationBar setBackgroundImage:nil
                                                  forBarMetrics:UIBarMetricsDefault];
    [self restoreAppearanceSettings];
}

#pragma mark Helper Method

- (void)goBack {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark IBAction Method

- (IBAction)setSquareAction:(id)sender
{
    // Cut some space in the bottom of the image because we don't show them when we take and edit the image
    CGRect rect = [UIScreen mainScreen].bounds;
    
    CGRect rect1 = CGRectMake(0, 0, rect.size.width, rect.size.height * self.sourceImage.size.width / self.sourceImage.size.height);
    self.cropRect = rect1;
    
}

- (IBAction)acceptButtonDidTouch:(id)sender;
{

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // Call method accept the crop
    [self doneAction:sender];
}

- (IBAction)cancelButtonDidTouch:(id)sender;
{
    [self cancelAction:sender];
}

- (IBAction)showPreviousButtonClick:(id)sender;
{
    if (self.showPreviousImage) {
        self.previousImageView.image = nil;
        self.previousButton.alpha = 1.0f;

    }
    else {
        self.previousImageView.image = self.previousImage;
        self.previousButton.alpha = 0.7f;
    }
    
    self.showPreviousImage = !self.showPreviousImage;
    
}

- (IBAction)fontButtonDidTouch:(id)sender;
{

    
    self.addTextProcess = YES;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // Call method accept the crop
    [self doneAction:sender];
}

- (IBAction)cropImageButtonDidTouch:(id)sender;
{
    [[NSUserDefaults standardUserDefaults] setObject:@"passed" forKey:@"tip10Name"];
    [self.tip10ImageView setHidden:YES];
    [self.tip10Close setHidden:YES];

    // Show font selection
    [self changeTabSelected:BEBEditImageTabSelectionTypeCropSize];
}


- (void)changeTabSelected:(NSInteger)tabSelected;
{
    
    if (tabSelected == BEBEditImageTabSelectionTypeFont) {
        
        self.captionButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_button_crop"]];
        self.cropButton.backgroundColor = [UIColor clearColor];
        
        // Setting show the selection view
        [self.fontSelectionView setHidden:NO];
        [self.frameView setUserInteractionEnabled:NO];
        [self.previousImageView setUserInteractionEnabled:YES];
        
        self.pinchGestureRecognizer.enabled = YES;
        self.panGestureRecognize.enabled = YES;
        self.singleTap.enabled = YES;
        self.doubleTap.enabled = YES;
        
        // Hidden the slider rotation view
        self.rotationSelectionView.hidden = YES;

    }
    else {

        self.captionButton.backgroundColor = [UIColor clearColor];
        self.cropButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_button_crop"]];
        
        // Setting hide the selection view
        [self.fontSelectionView setHidden:YES];
        [self.frameView setUserInteractionEnabled:YES];
        [self.previousImageView setUserInteractionEnabled:NO];
        
        self.pinchGestureRecognizer.enabled = NO;
        self.panGestureRecognize.enabled = NO;
        self.singleTap.enabled = NO;
        self.doubleTap.enabled = NO;
        
        // Show the slider rotation view
        self.rotationSelectionView.hidden = NO;

    }
}

- (IBAction)sliderValueChange:(id)sender;
{
//    NSLog(@"sliderValueChange %f", self.rotationSlider.value);
    [self handleRotationWithValue:self.rotationSlider.value];
    
}

- (IBAction)tip10ButtonClick:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:@"passed" forKey:@"tip10Name"];
    [self.tip10ImageView setHidden:YES];
    [self.tip10Close setHidden:YES];
}


- (void)captionFunctionDisable:(BOOL)value;
{
    // Change the user interaction for the caption view
    if (!value) {
        [self doTapOutside];
    }
    
    [self.captionView setUserInteractionEnabled:value];
}

//*****************************************************************************
#pragma mark -
#pragma mark - ** Caption touch Methods **
- (void)configureFontSelectionView;
{
    self.fontSelectionView.positionItemSelected = -1;
    
    NSArray *fonts = [BEBDataManager sharedManager].fonts;
    [self.fontSelectionView setFonts:fonts];
    self.fontSelectionView.delegate = self;
}

- (void)configureCaptionGestureRecognizer;
{
    // Add tapGestureRecognizer for image crop view
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(doTapOutside)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.previousImageView addGestureRecognizer:tapGestureRecognizer];
    
    // Set the place hoder text for caption textfield
    self.captionTextField.text = placeHolderText;
    self.captionTextField.enabled = NO;
    [self.captionTextField setUserInteractionEnabled:YES];
    [self.captionTextField sizeToFit];
    
    self.captionTextField.layer.borderColor = [UIColor whiteColor].CGColor;
    self.captionTextField.layer.cornerRadius = 3;
    self.captionTextField.delegate = self;
    
    self.editCaptionMode = NO;
    
    // Adding single tap for user out of the edit mode
    self.panGestureRecognize = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                       action:@selector(moveCaptionLabel:)];
    [self.captionView addGestureRecognizer:self.panGestureRecognize];
    
    // Adding single tap for user out of the edit mode
    self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                             action:@selector(doSingleTap)];
    self.singleTap.numberOfTapsRequired = 1;
    [self.captionView addGestureRecognizer:self.singleTap];
    
    // Double click bring user to edit caption mode.
    self.doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doDoubleTap)];
    self.doubleTap.numberOfTapsRequired = 2;
    [self.captionView addGestureRecognizer:self.doubleTap];
    
    [self.singleTap requireGestureRecognizerToFail:self.doubleTap];
    
    // Add GestureRecognizer allow zoom the text
    self.pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchCaption:)];
    [self.captionView addGestureRecognizer:self.pinchGestureRecognizer];
    
}

- (void)configureRotationView;
{
    UIImage *blankTrackImage = [[UIImage imageNamed:@"img_video_slider_blank"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 12, 0, 12)];
    [self.rotationSlider setMaximumTrackImage:blankTrackImage
                                  forState:UIControlStateNormal];
    
    [self.rotationSlider setMinimumTrackImage:blankTrackImage
                                  forState:UIControlStateNormal];
    
    [self.rotationSlider setThumbImage:[UIImage imageNamed:@"icon_rotation_slider_thumb"]
                           forState:UIControlStateNormal];
    
    [self.rotationSlider addTarget:self
                            action:@selector(itemSlider:withEvent:)
                  forControlEvents:UIControlEventValueChanged];
    
}

- (IBAction)itemSlider:(UISlider *)itemSlider withEvent:(UIEvent*)e;
{
    UITouch * touch = [e.allTouches anyObject];
    
    if( touch.phase != UITouchPhaseMoved && touch.phase != UITouchPhaseBegan) {
        //The user hasn't ended using the slider yet.
        
        NSLog(@"End of rotation");
//        [self rollBackCorrectTransform];
    }
}

- (void)resetSliderValueAtChildView:(CGFloat)value;
{
    [UIView animateWithDuration:0.2 animations:^{
        self.rotationSlider.value = value;
    }];
}
//*****************************************************************************
#pragma mark -
#pragma mark - ** BEBFontSelectionViewDelegate **
- (void)bebFontSelectionView:(id)fontSelectionView didSelectFontAtIndex:(NSInteger)index;
{
    DEBUG_LOG(@"Font Index: %d", (int)index);
    if (index < 0) return;
    
    self.captionView.hidden = NO;
    
    NSArray *fonts = [BEBDataManager sharedManager].fonts;
    
    // Change font for the caption view
    self.captionTextField.font = fonts[index];
    
    // Call method update size for the caption.
    [self doSingleTap];
}


// Single tap for user out of the edit mode
- (void)doSingleTap;
{
    // Set caption can not edit
    self.captionTextField.enabled = NO;
    
    // Show the border of the textfield
    NSDictionary *attributes = @{NSFontAttributeName: self.captionTextField.font};
    
    CGSize size = [self.captionTextField.text sizeWithAttributes:attributes];
    
    if (self.captionTextField.text > 0) {
        self.captionWidthLayoutConstraint.constant = size.width + margin;
    }
    else {
        self.captionWidthLayoutConstraint.constant = size.width + 2 * margin;
    }
    
    // Show border of the text field
    self.captionTextField.layer.borderWidth = 1;
    
    // Update frame of the textfield
    [self.captionTextField layoutIfNeeded];
}

// Double click bring user to edit caption mode.
- (void)doDoubleTap;
{
    // Set caption can edit
    self.captionTextField.enabled = YES;
    
    // Remove the place holder text
    if (![self.captionTextField.placeholder isEqualToString:@""]) {
        self.captionTextField.placeholder = @"";
    }
    
    self.captionTextField.layer.borderWidth = 0;
    
    self.captionWidthLayoutConstraint.constant = CGRectGetWidth(self.view.frame);
    
    // Update frame of the textfield
    [self.captionTextField layoutIfNeeded];
    
    // Set focus for the caption
    [self.captionTextField becomeFirstResponder];
}


- (void)doTapOutside;
{
    
    // Set caption can not edit
    self.captionTextField.enabled = NO;
    
    // Show the border of the textfield
    NSDictionary *attributes = @{NSFontAttributeName: self.captionTextField.font};
    CGSize size = [self.captionTextField.text sizeWithAttributes:attributes];
    
    if (self.captionTextField.text.length > 0) {
        self.captionWidthLayoutConstraint.constant = size.width + margin;
    }
    else {
        self.captionWidthLayoutConstraint.constant = size.width + 20;
    }
    
    // Remove the border of view.
    self.captionTextField.layer.borderWidth = 0;
    
    self.captionView.backgroundColor = [UIColor clearColor];
}

//*****************************************************************************
#pragma mark
#pragma mark UIPinchGestureRecognizer

- (IBAction)handlePinchCaption:(UIPinchGestureRecognizer *)recognizer {
    
    self.captionTextField.transform = CGAffineTransformScale(self.captionTextField.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
}


- (void)moveCaptionLabel:(UIPanGestureRecognizer *)gesture
{
    // Get the touch object.
    UIView *view = gesture.view;
    CGPoint point = [gesture locationInView:view.superview];
    
    if(gesture.state == UIGestureRecognizerStateBegan) {
        
        // Show border of the text field
        self.captionTextField.layer.borderWidth = 1;
        [self doSingleTap];
    }
    else if(gesture.state == UIGestureRecognizerStateChanged) {
        
        // Move the view base on user move the finger
        self.captionPositionXLayoutConstraint.constant += point.x - _priorPoint.x;
        self.captionPositionYLayoutConstraint.constant += point.y - _priorPoint.y;
        
        [self.captionView layoutIfNeeded];
    }
    else if(gesture.state == UIGestureRecognizerStateEnded) {
        
    }
    
    self.priorPoint = point;
}

//*****************************************************************************
#pragma mark -
#pragma mark - ** UITextfieldDelegate **
- (void)textFieldDidBeginEditing:(UITextField *)textField;
{
    if ([textField.text isEqualToString:placeHolderText]) {
        textField.text = @"";
    }
}

// Override the method from super class
- (UIImage *)addCaptionInImage:(UIImage *)image;
{
//    // Check user had input the caption text
//    if (self.captionTextField.text.length > 0 &&
//        ![self.captionTextField.text isEqualToString:placeHolderText]) {
//        
//        
//        CGPoint textPosition = [self captionFrame].origin;
//        
//        textPosition.x *= 2;
//        textPosition.y *= 2;
//        
//        UIFont *textFont = [self captionFont];
//        UIColor *textColor = self.captionTextField.textColor;
//        
//        return [super image:image withCaption:self.captionTextField.text position:textPosition font:textFont color:textColor];
//    }
//    
//    return image;
    if (self.addTextProcess) {
        return [[UIImage alloc] init];
    }
    else {
        return nil;
    }
}


- (CGRect)captionFrame;
{
    // Get the position of caption text with the image cropview
    CGRect rect = [self.view convertRect:self.captionTextField.frame fromView:self.captionView];
    
    return rect;
}

- (UIFont *)captionFont;
{
    float scaleRate = 2;
    double scaleCaptionValue = [self captionScale];
    
    // And font of the text.
    UIFont *font = self.captionTextField.font;
    CGFloat fontSize = font.pointSize * scaleRate * scaleCaptionValue;
    
    return [font fontWithSize:fontSize];
}

- (double)captionScale;
{
    // Get tranform value of the caption text
    CGAffineTransform t = self.captionTextField.transform;
    double scaleCaptionValue = sqrt(t.a * t.a + t.c * t.c);
    
    return scaleCaptionValue;
}

@end

#import "HFImageEditorViewController+Private.h"
#import "BEBTextEditorViewController.h"
#import "BEBFontSelectionView.h"
#import "BEBDataManager.h"
#import "MBProgressHUD.h"

static const int margin = 4;
static NSString *const placeHolderText = @"Double tap to edit text";

@interface BEBTextEditorViewController () <BEBFontSelectionViewDelegate, UITextFieldDelegate>

#pragma mark Outlet Propeties
@property (weak, nonatomic) IBOutlet BEBFontSelectionView *fontSelectionView;
@property (weak, nonatomic) IBOutlet UIView *topContainerView;
@property (weak, nonatomic) IBOutlet UIView *captionView;
@property (weak, nonatomic) IBOutlet UIView *colorContainerView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (weak, nonatomic) IBOutlet UIButton *captionButton;
@property (weak, nonatomic) IBOutlet UIButton *hiddenBottomButton;

@property (weak, nonatomic) IBOutlet UITextField *captionTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *captionWidthLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *captionPositionXLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *captionPositionYLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *captionViewWidthLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewLayoutConstraintHeight;

@property (strong, nonatomic) UIPinchGestureRecognizer *pinchGestureRecognizer;
@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognize;
@property (strong, nonatomic) UITapGestureRecognizer *singleTap;
@property (strong, nonatomic) UITapGestureRecognizer *doubleTap;

#pragma mark Propeties
@property (nonatomic) CGPoint priorPoint;
@property (nonatomic) BOOL bottomViewHidden;
@property (nonatomic) NSInteger bottomViewHeight;

#pragma mark - IBActions
- (IBAction)acceptButtonDidTouch:(id)sender;
- (IBAction)cancelButtonDidTouch:(id)sender;
- (IBAction)colorButtonDidTouch:(UIButton *)sender;
- (IBAction)hiddenButtonDidTouch:(id)sender;

@end

@implementation BEBTextEditorViewController

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
    
    self.minimumScale = 0.2;
    self.maximumScale = 10;
    
    self.bottomViewHidden = NO;
    self.bottomViewHeight = self.bottomViewLayoutConstraintHeight.constant;

    // Make blur navigation bar
    CGSize frameSize = self.navigationController.navigationBar.frame.size;
    
    UIView *navigationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frameSize.width, frameSize.height + 20.0f)];
    navigationView.backgroundColor = RGB(143, 206, 220, 0.1);
    [self.view addSubview:navigationView];
    
    // Set the full screen image capture.
    [self setSquareAction:nil];
    
    // Set the font select
    [self configureFontSelectionView];
    
    // Add caption Gesture
    [self configureCaptionGestureRecognizer];
    [self.view bringSubviewToFront:self.hiddenBottomButton];


}

- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    
    [self saveAppearanceSettings];
    
    self.title = @"CREATE IMAGE";
    
    NSDictionary *textAttributes = @{
                                     NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:15.0f],
                                     NSForegroundColorAttributeName : [UIColor whiteColor]
                                     };
    [self.navigationController.navigationBar setTitleTextAttributes:textAttributes];
        
    [self configView];
    self.captionTextField.textColor = self.topContainerView.backgroundColor;
    self.bottomView.alpha = 0.8f;

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
    self.cropRect = rect;
    
}

- (IBAction)acceptButtonDidTouch:(id)sender;
{
    [self doTapOutside];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // Call method accept the crop
    [self doneAction:sender];
}

- (IBAction)cancelButtonDidTouch:(id)sender;
{
    [self cancelAction:sender];
}

- (IBAction)colorButtonDidTouch:(UIButton *)sender;
{
    UIColor *color = sender.backgroundColor;
    
    // Set color of the text field as selected color
    self.captionTextField.textColor = color;
    
    self.topContainerView.backgroundColor = color;
}


- (IBAction)hiddenButtonDidTouch:(id)sender;
{
    if (self.bottomViewHidden == NO) {
        self.bottomViewHidden = YES;
        [self.hiddenBottomButton setImage:[UIImage imageNamed:@"up_images"] forState:UIControlStateNormal];
        
        [UIView animateWithDuration:0.2 animations:^{
            
            // Update height for buttom view -> hidden it
            self.bottomViewLayoutConstraintHeight.constant = 48;
            
            self.bottomView.alpha = 0.6f;
            
            [self.view bringSubviewToFront:self.bottomView];
            [self.view bringSubviewToFront:self.hiddenBottomButton];

            [self.view layoutIfNeeded];
            
        }];
    }
    else {
        
        self.bottomViewHidden = NO;
        [self.hiddenBottomButton setImage:[UIImage imageNamed:@"down_images"] forState:UIControlStateNormal];
        
        [UIView animateWithDuration:0.2 animations:^{
            
            // Update height for buttom view -> show it
            self.bottomViewLayoutConstraintHeight.constant = self.bottomViewHeight;
            
            self.bottomView.alpha = 0.8f;

            [self.view layoutIfNeeded];
            
        }];
    }
}


- (void)configView;
{
    
    self.captionButton.layer.cornerRadius = 15;
    
    // Setting show the selection view
    [self.fontSelectionView setHidden:NO];
    [self.frameView setUserInteractionEnabled:NO];
    
    self.pinchGestureRecognizer.enabled = YES;
    self.panGestureRecognize.enabled = YES;
    self.singleTap.enabled = YES;
    self.doubleTap.enabled = YES;
    
    [self captionFunctionDisable: YES];

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
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(doTapOutside)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    // Set the place hoder text for caption textfield
    self.captionTextField.text = placeHolderText;
    self.captionTextField.enabled = NO;
    [self.captionTextField setUserInteractionEnabled:YES];
    [self.captionTextField sizeToFit];
    
    self.captionTextField.layer.borderColor = [UIColor whiteColor].CGColor;
    self.captionTextField.layer.cornerRadius = 3;
    self.captionTextField.delegate = self;
    
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
    // Check user had input the caption text
    if (self.captionTextField.text.length > 0 &&
        ![self.captionTextField.text isEqualToString:placeHolderText]) {
        
        
        CGPoint textPosition = [self captionFrame].origin;
        
        textPosition.x *= 2;
        textPosition.y *= 2;
        
        UIFont *textFont = [self captionFont];
        UIColor *textColor = self.captionTextField.textColor;
        
        return [super image:image withCaption:self.captionTextField.text position:textPosition font:textFont color:textColor];
    }
    
    return image;
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

#import "BEBCreateVideoViewController.h"
#import "AVCamPreviewView.h"
#import "BEBStory.h"
#import "BEBImage.h"
#import "DVSwitch.h"
#import "DVSwitchWithIcon.h"
#import "BEBFontSelectionView.h"
#import "BEBDataManager.h"
#import <AVFoundation/AVFoundation.h>
#import "MBProgressHUD.h"
//#import "ImageFilter.h"
#import "UIImage+Helper.h"
#import "BEBSharingVideoViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "NSString+TimeToString.h"

#import "WLRangeSlider.h"
#import "BEBStoriesDetailViewController.h"

static const int margin = 4;
static const CGFloat kMinVideoLengthForMusic = 15.0f;
static NSString *const placeHolderText = @"Double tap to edit text";

@interface BEBCreateVideoViewController () <BEBFontSelectionViewDelegate, AVAudioPlayerDelegate, UITextFieldDelegate, MPMediaPickerControllerDelegate> {
    NSMutableArray *audioExportNameArray;
    
}

#pragma mark - Properties
@property (nonatomic) NSInteger fpsValue;
@property (nonatomic, getter = isPaused) BOOL paused;
@property (nonatomic, strong) NSTimer *playbackTimer;
@property (nonatomic) CGFloat updateImageTime;
@property (nonatomic) CGFloat videoTime;
@property (nonatomic) CGFloat playedTime;
@property (nonatomic) NSInteger photoIdx;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, getter = isSilentMode) BOOL silentMode;
@property (nonatomic) NSInteger seletedAudioIdx;
@property (nonatomic) CGPoint priorPoint;
@property (nonatomic) BOOL editCaptionMode;
@property (nonatomic) BOOL bottomViewHidden;
@property (nonatomic) MPMediaItem *mediaItem;
@property (nonatomic) NSURL *musicLibaryURL;
@property (strong, nonatomic) AVAsset *asset;
@property (assign, nonatomic) CGFloat startTime;
@property (assign, nonatomic) CGFloat stopTime;
@property (nonatomic) NSInteger selectedFilterIdx;
@property (nonatomic) NSInteger bottomViewHeight;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSOperation *priorCompletionOperation;

@property (nonatomic,strong)WLRangeSlider *rangeSlider;
@property (nonatomic) float songMaxTime;
@property (nonatomic) float initialLeftVal;
@property (nonatomic) float initialRightVal;

//slider min button
@property (nonatomic, strong) UIImage *sliderSecondIMG;
//@property (nonatomic, strong) ImageFilter *imageFilter;
@property BOOL panningProgress;
@property UIBarButtonItem *customizedButton;
@property UIBarButtonItem *customizedButton2;
@property UIBarButtonItem *backButton;
@property UIBarButtonItem *selectSongButton;
@property UILabel *titleLabelNavigationBar;
@property double testingTimeFrame;
@property int loopCount;
@property BOOL selectedMusicFile;

@property BOOL istouchforpause;

#pragma mark - IBOutlets
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet AVCamPreviewView *previewView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *playedTimeLabel;
@property (weak, nonatomic) IBOutlet UISlider *videoSlider;
@property (weak, nonatomic) IBOutlet UIButton *volumeButton;
@property (weak, nonatomic) IBOutlet BEBFontSelectionView *fontSelectionView;
@property (weak, nonatomic) IBOutlet UIView *audioSelectionView;
@property (weak, nonatomic) IBOutlet UIView *fpsSelectionView;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (weak, nonatomic) IBOutlet UITextField *captionTextField;
@property (weak, nonatomic) IBOutlet UIView *captionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *captionWidthLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *captionPositionXLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *captionPositionYLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *captionViewWidthLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playButtonLayoutConstraint;
@property (weak, nonatomic) IBOutlet UIButton *fontButton;
@property (weak, nonatomic) IBOutlet UIButton *musicButton;
@property (weak, nonatomic) IBOutlet UIButton *fpsButton;
@property (weak, nonatomic) IBOutlet UIView *containerColorView;
@property (weak, nonatomic) IBOutlet UILabel *speedValueLabel;
@property (weak, nonatomic) IBOutlet UISwitch *loopVideoSwitch;
@property (weak, nonatomic) IBOutlet UISlider *speedSlider;
@property (weak, nonatomic) IBOutlet UIView *topContainerView;
@property (weak, nonatomic) IBOutlet UIButton *hiddenBottomButton;
@property (weak, nonatomic) IBOutlet UILabel *nameOfSelectedSong;
@property (weak, nonatomic) IBOutlet UILabel *nameOfSelectedSongTrimerPortion;
@property (weak, nonatomic) IBOutlet UIView *audioTrimmerView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *fourthButtonOutlet;
@property (weak, nonatomic) IBOutlet UISlider *sliderTrimmer;
@property (weak, nonatomic) IBOutlet UILabel *trackCurrentPlayback;
@property (weak, nonatomic) IBOutlet UILabel *trackCurrentLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *loopSelect;
@property (weak, nonatomic) IBOutlet UIImageView *tip14ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *tip16ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *tip15ImageView;
@property (weak, nonatomic) IBOutlet UIButton *tip14Close;
@property (weak, nonatomic) IBOutlet UIButton *tip15Close;
@property (weak, nonatomic) IBOutlet UIButton *tip16Close;

#pragma mark - IBActions
- (IBAction)playButtonDidTouch:(id)sender;
- (IBAction)videoSliderSeekTime:(id)sender;
- (IBAction)volumeButtonDidTouch:(id)sender;
- (IBAction)fontButtonDidTouch:(id)sender;
- (IBAction)audioButtonDidTouch:(id)sender;
- (IBAction)fpsButtonDidTouch:(id)sender;
- (IBAction)volumeSliderValueChanged:(id)sender;
- (IBAction)colorButtonDidTouch:(id)sender;
- (IBAction)firstAudioButtonDidTouch:(id)sender;
- (IBAction)secondAudioButtonDidTouch:(id)sender;
- (IBAction)thirdAudioButtonDidTouch:(id)sender;
- (IBAction)fourthAudioButtonDidTouch:(id)sender;
- (IBAction)speedSliderValueChanged:(id)sender;
- (IBAction)loopVideoSwitchValueChanged:(id)sender;
- (IBAction)doneButtonDidTouch:(id)sender;
- (IBAction)hiddenButtonDidTouch:(id)sender;
- (IBAction)nextBarButton:(id)sender;
- (IBAction)sliderTrimmerButton:(id)sender;
- (IBAction)changeLoop:(id)sender;
- (IBAction)tip14ButtonClick:(id)sender;
- (IBAction)tip15ButtonClick:(id)sender;
- (IBAction)tip16ButtonClick:(id)sender;

@end

@implementation BEBCreateVideoViewController

//*****************************************************************************
#pragma mark -
#pragma mark - ** Initializer & Lifecycle methods **
- (void)viewDidLoad;
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.paused = YES;
    self.fpsValue = 1;
    self.loopCount = 0;
    self.selectedMusicFile = false;
    
    
    self.titleLabelNavigationBar = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabelNavigationBar.backgroundColor = [UIColor clearColor];
    self.titleLabelNavigationBar.font = [UIFont boldSystemFontOfSize:15.0];
    self.titleLabelNavigationBar.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    self.titleLabelNavigationBar.textAlignment = NSTextAlignmentCenter;
    self.titleLabelNavigationBar.textColor = [UIColor whiteColor]; // change this color
    self.navigationItem.titleView = self.titleLabelNavigationBar;
    self.titleLabelNavigationBar.text = NSLocalizedString(@"CREATE VIDEO", @"");
    
    [self.titleLabelNavigationBar sizeToFit];
    
    
    
    
    self.bottomViewHidden = NO;
    self.bottomViewHeight = self.bottomViewLayoutConstraint.constant;
    if (IS_IPHONE_4) {
        self.playButtonLayoutConstraint.constant = 115.0f;
        [self.view layoutIfNeeded];
    }
    
    //    self.imageFilter = [[ImageFilter alloc] init];
    
    self.fontButton.layer.cornerRadius = CGRectGetHeight(self.fontButton.frame) / 2;
    self.fontButton.clipsToBounds = YES;
    
    self.musicButton.layer.cornerRadius = CGRectGetHeight(self.musicButton.frame) / 2;
    self.musicButton.clipsToBounds = YES;
    
    self.fpsButton.layer.cornerRadius = CGRectGetHeight(self.fpsButton.frame) / 2;
    self.fpsButton.clipsToBounds = YES;
    
    self.loopVideoSwitch.transform = CGAffineTransformMakeScale(0.8, 0.8);
    self.captionTextField.textColor = self.topContainerView.backgroundColor;
    //    self.captionTextField.transform = CGAffineTransformScale(self.captionTextField.transform, 1.5, 1.5);
    
    // Display title story
    UIImage *maximumTrackImage = [[UIImage imageNamed:@"img_video_slider_max"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 12, 0, 12)];
    [self.videoSlider setMaximumTrackImage:maximumTrackImage
                                  forState:UIControlStateNormal];
    
    UIImage *minimumTrackImage = [[UIImage imageNamed:@"img_video_slider_min"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 12, 0, 12)];
    [self.videoSlider setMinimumTrackImage:minimumTrackImage
                                  forState:UIControlStateNormal];
    
    [self.videoSlider setThumbImage:[UIImage imageNamed:@"img_video_slider_thumb"]
                           forState:UIControlStateNormal];
    
    // Setup volume slider
    [self.volumeSlider setMaximumTrackImage:maximumTrackImage
                                   forState:UIControlStateNormal];
    [self.volumeSlider setMinimumTrackImage:minimumTrackImage
                                   forState:UIControlStateNormal];
    [self.volumeSlider setThumbImage:[UIImage imageNamed:@"img_video_slider_thumb"]
                            forState:UIControlStateNormal];
    self.volumeSlider.transform = CGAffineTransformMakeRotation(-M_PI * 0.5);
    [self.volumeSlider setHidden:YES];
    
    // Setup speed slider
    UIImage *trackImage = [[UIImage imageNamed:@"img_speed_slider"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 12, 0, 12)];
    [self.speedSlider setMaximumTrackImage:trackImage
                                  forState:UIControlStateNormal];
    [self.speedSlider setMinimumTrackImage:trackImage
                                  forState:UIControlStateNormal];
    [self.speedSlider setThumbImage:[UIImage imageNamed:@"img_speed_slider_thumb"]
                           forState:UIControlStateNormal];
    self.speedSlider.value = 0;
    self.speedValueLabel.text = @"x1";
    
    // Configure audio player
    [self handleSelectedAudioAtIndex:1];
    
    // Configure font selection view
    [self configureFontSelectionView];
    
    // Show font selection
    [self changeTabSelected:BEBCreateVideoTabSelectionTypeFont];
    
    // Add caption Gesture
    [self configureCaptionGestureRecognizer];
    
    // Set the first image
    BEBImage *bebImage = self.story.photos[0];
    self.imageView.image = bebImage.image;
    
    // Compute time update image and total time play video
    self.updateImageTime = 1.0f / self.fpsValue;
    self.videoTime = (CGFloat)self.story.photos.count / (CGFloat)self.fpsValue;
    
    // Set default value for time label
    [self.playedTimeLabel setText:@"0:00"];
    self.istouchforpause = false;
    
    [self.nextButton setEnabled:NO];
    [self.nextButton setTintColor:[UIColor clearColor]];
    
    self.customizedButton = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"icon_close"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(backButtonDidTouch:)];
    self.navigationItem.leftBarButtonItem = self.customizedButton;
    
    [self.imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(touchPauseVideo:)]];
    
    [self.imageView setUserInteractionEnabled:YES];
    
    
    [self updateImagesForStory];
    
    self.rangeSlider = [[WLRangeSlider alloc] initWithFrame:self.sliderTrimmer.frame];
    [self.rangeSlider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventAllEvents];
    self.rangeSlider.leftValue = 0;
//    [self.rangeSlider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.audioTrimmerView addSubview:self.rangeSlider];
    [self.sliderTrimmer setHidden:YES];
    [self viewTip14];
    //    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"tip15Name"] isEqualToString:@"passed"]) {
//        [self.tip15ImageView setHidden:YES];
//    } else {
//        [self.tip15ImageView setHidden:NO];
//    }
    

}
-(void)viewTip14{
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"tip14Name"] isEqualToString:@"passed"]) {
        [self.tip14ImageView setHidden:YES];
        [self.tip14Close setHidden:YES];
        [self viewTip16];
    } else {
        [self.tip14ImageView setHidden:NO];
        [self.tip14Close setHidden:NO];
        CABasicAnimation *fadeInAnimate   = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeInAnimate.duration            = 3;
        fadeInAnimate.repeatCount         = 1;
        fadeInAnimate.autoreverses        = NO;
        fadeInAnimate.fromValue           = [NSNumber numberWithFloat:0.0];
        fadeInAnimate.toValue             = [NSNumber numberWithFloat:1.0];
        fadeInAnimate.removedOnCompletion = YES;
        [self.tip14ImageView.layer addAnimation:fadeInAnimate forKey:@"animateOpacity"];
        [self.tip14Close.layer addAnimation:fadeInAnimate forKey:@"animateOpacity"];
        [[NSUserDefaults standardUserDefaults] setObject:@"passed" forKey:@"tip14Name"];
    }
}
-(void)viewTip15{
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"tip15Name"] isEqualToString:@"passed"]) {
        [self.tip15ImageView setHidden:YES];
        [self.tip15Close setHidden:YES];
    } else {
        [self.tip15Close setHidden:NO];
        [self.tip15ImageView setHidden:NO];
        CABasicAnimation *fadeInAnimate   = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeInAnimate.duration            = 3;
        fadeInAnimate.repeatCount         = 1;
        fadeInAnimate.autoreverses        = NO;
        fadeInAnimate.fromValue           = [NSNumber numberWithFloat:0.0];
        fadeInAnimate.toValue             = [NSNumber numberWithFloat:1.0];
        fadeInAnimate.removedOnCompletion = YES;
        [self.tip15Close.layer addAnimation:fadeInAnimate forKey:@"animateOpacity"];
        [self.tip15ImageView.layer addAnimation:fadeInAnimate forKey:@"animateOpacity"];
        
        [[NSUserDefaults standardUserDefaults] setObject:@"passed" forKey:@"tip15Name"];
    }
    
}

-(void)viewTip16{
    
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"tip16Name"] isEqualToString:@"passed"]) {
        [self.tip16ImageView setHidden:YES];
        [self.tip16Close setHidden:YES];
        [self viewTip15];
    } else {
        [self.tip16ImageView setHidden:NO];
        [self.tip16Close setHidden:NO];
        CABasicAnimation *fadeInAnimate   = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeInAnimate.duration            = 3;
        fadeInAnimate.repeatCount         = 1;
        fadeInAnimate.autoreverses        = NO;
        fadeInAnimate.fromValue           = [NSNumber numberWithFloat:0.0];
        fadeInAnimate.toValue             = [NSNumber numberWithFloat:1.0];
        fadeInAnimate.removedOnCompletion = YES;
        [self.tip16ImageView.layer addAnimation:fadeInAnimate forKey:@"animateOpacity"];
        [self.tip16Close.layer addAnimation:fadeInAnimate forKey:@"animateOpacity"];
        [[NSUserDefaults standardUserDefaults] setObject:@"passed" forKey:@"tip16Name"];
    }

}
- (void)valueChanged:(WLRangeSlider *)slider{
    //    slide
    self.panningProgress = YES;
    self.trackCurrentPlayback.text = [NSString stringFromTime:slider.leftValue*self.songMaxTime];
    float _left = slider.leftValue;
    float _right = slider.rightValue;
    int frames = self.story.photos.count;
    if(self.initialLeftVal != _left){ // left changed
        self.initialLeftVal = _left;
        self.rangeSlider.leftValue = self.initialLeftVal;
        self.rangeSlider.rightValue = self.rangeSlider.leftValue + frames / (self.songMaxTime * self.fpsValue);
        if(self.rangeSlider.rightValue >= 1){
            self.rangeSlider.rightValue = 1;
            self.rangeSlider.leftValue = 1 - frames / (self.songMaxTime * self.fpsValue);
        }
    }else // right changed
    {
        self.initialRightVal = _right;
        self.rangeSlider.rightValue = self.initialRightVal;
        self.rangeSlider.leftValue = self.rangeSlider.rightValue - frames / (self.songMaxTime * self.fpsValue);
        if(self.rangeSlider.leftValue <= 0){
            self.rangeSlider.leftValue = 0;
            self.rangeSlider.rightValue = frames / (self.songMaxTime * self.fpsValue);
        }
    }
    
    self.audioPlayer.currentTime = slider.leftValue*self.songMaxTime;//self.sliderTrimmer.value;
    self.panningProgress = NO;
}

-(IBAction)changeLoop:(UISegmentedControl *)sender
{
    self.loopCount = 0;
    
}

- (IBAction)tip14ButtonClick:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:@"passed" forKey:@"tip14Name"];
    [self.tip14ImageView setHidden:YES];
    [self.tip14Close setHidden:YES];
    [self viewTip16];
}

- (IBAction)tip15ButtonClick:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:@"passed" forKey:@"tip15Name"];
    [self.tip15ImageView setHidden:YES];
    [self.tip15Close setHidden:YES];
}

- (IBAction)tip16ButtonClick:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:@"passed" forKey:@"tip16Name"];
    [self.tip16ImageView setHidden:YES];
    [self.tip16Close setHidden:YES];
    [self viewTip15];
}
- (void)didReceiveMemoryWarning;
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    
    [self saveAppearanceSettings];
    
    NSDictionary *textAttributes = @{
                                     NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:15.0f],
                                     NSForegroundColorAttributeName : [UIColor whiteColor]
                                     };
    [self.navigationController.navigationBar setTitleTextAttributes:textAttributes];
}

- (void)viewWillDisappear:(BOOL)animated;
{
    [super viewWillDisappear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:nil
                                                  forBarMetrics:UIBarMetricsDefault];
    [self restoreAppearanceSettings];
    
    if (!self.paused) {
        [self.playButton setHidden:NO];
        [self.playButton setAlpha:1.0f];
        [self playButtonDidTouch:nil];
    }
}

//*****************************************************************************
#pragma mark -
#pragma mark - ** Caption touch Methods **
- (void)configureCaptionGestureRecognizer;
{
    // Add tapGestureRecognizer for image crop view
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(doTapOutside)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.previewView addGestureRecognizer:tapGestureRecognizer];
    
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
    UIPanGestureRecognizer *panGestureRecognize = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(moveCaptionLabel:)];
    [self.captionView addGestureRecognizer:panGestureRecognize];
    
    // Adding single tap for user out of the edit mode
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doSingleTap)];
    singleTap.numberOfTapsRequired = 1;
    [self.captionView addGestureRecognizer:singleTap];
    
    // Double click bring user to edit caption mode.
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doDoubleTap)];
    doubleTap.numberOfTapsRequired = 2;
    [self.captionView addGestureRecognizer:doubleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    // Add GestureRecognizer allow zoom the text
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self.captionView addGestureRecognizer:pinchGestureRecognizer];
    
}

- (void)moveCaptionLabel:(UIPanGestureRecognizer *)gesture
{
    // Get the touch object.
    UIView *view = gesture.view;
    CGPoint point = [gesture locationInView:view.superview];
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        // Show border of the text field
        self.captionTextField.layer.borderWidth = 1;
        [self doSingleTap];
    }
    else if (gesture.state == UIGestureRecognizerStateChanged) {
        
        // Move the view base on user move the finger
        self.captionPositionXLayoutConstraint.constant += point.x - _priorPoint.x;
        self.captionPositionYLayoutConstraint.constant += point.y - _priorPoint.y;
        
        [self.captionView layoutIfNeeded];
    }
    else if (gesture.state == UIGestureRecognizerStateEnded) {
        
    }
    
    self.priorPoint = point;
}

- (void)doTapOutside;
{
    // Hide volume
    [self.volumeSlider setHidden:YES];
    
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

//*****************************************************************************
#pragma mark
#pragma mark UIPinchGestureRecognizer

- (IBAction)handlePinch:(UIPinchGestureRecognizer *)recognizer {
    
    self.captionTextField.transform = CGAffineTransformScale(self.captionTextField.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
}

//*****************************************************************************
#pragma mark -
#pragma mark - ** Helper Methods **

- (BOOL)isEnableExportVideo;
{
    for (BEBImage *bebImage in self.story.photos) {
        if (!bebImage.image) {
            return NO;
        }
    }
    return YES;
}

- (void)updateImagesForStory;
{
    __weak typeof(self) weakSelf = self;
    for (BEBImage *bebImage in self.story.photos) {
        if (!bebImage.image) {
            // Disable button export video
            [self.navigationItem.rightBarButtonItem setEnabled:NO];
            // Download image from S3
            [bebImage getImageFromS3:^(NSString *url) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    BEBCreateVideoViewController *strongSelf = weakSelf;
                    BEBImage *currentPhoto = strongSelf.story.photos[strongSelf.photoIdx];
                    if (bebImage == currentPhoto) {
                        strongSelf.imageView.image = bebImage.image;
                    }
                    // Enable button export video
                    if ([strongSelf isEnableExportVideo]) {
                        [strongSelf.navigationItem.rightBarButtonItem setEnabled:YES];
                    }
                });
            }];
        }
    }
}

- (DVSwitch *)switchWithStringsArray:(NSArray *)strings;
{
    DVSwitch *selectionSwitch = [DVSwitch switchWithStringsArray:strings];
    selectionSwitch.frame = CGRectMake(6, 2, 53 * 5, 28);
    selectionSwitch.layer.cornerRadius = 14;
    selectionSwitch.clipsToBounds = YES;
    selectionSwitch.backgroundColor = RGB(230, 231, 232, 1); //RGB(187, 90, 89, 1);
    selectionSwitch.sliderColor = RGB(161, 211, 223, 1);
    selectionSwitch.labelTextColorInsideSlider = RGB(15, 15, 15, 1);
    selectionSwitch.labelTextColorOutsideSlider = RGB(15, 15, 15, 1);
    selectionSwitch.font = [UIFont fontWithName:@"OpenSans-Light" size:9.0f];
    
    return selectionSwitch;
}

- (DVSwitchWithIcon *)switchMusicWithStringsArray:(NSArray *)strings;
{
    DVSwitchWithIcon *selectionSwitch = [DVSwitchWithIcon switchWithStringsArray:strings];
    selectionSwitch.frame = CGRectMake(6, 2, 53 * 5, 28);
    selectionSwitch.layer.cornerRadius = 14;
    selectionSwitch.clipsToBounds = YES;
    selectionSwitch.backgroundColor = RGB(230, 231, 232, 1); //RGB(187, 90, 89, 1);
    selectionSwitch.sliderColor = RGB(161, 211, 223, 1);
    selectionSwitch.labelTextColorInsideSlider = RGB(15, 15, 15, 1);
    selectionSwitch.labelTextColorOutsideSlider = RGB(15, 15, 15, 1);
    selectionSwitch.font = [UIFont fontWithName:@"OpenSans-Light" size:9.0f];
    
    return selectionSwitch;
}

- (void)configureFontSelectionView;
{
    self.fontSelectionView.positionItemSelected = -1;
    
    NSArray *fonts = [BEBDataManager sharedManager].fonts;
    [self.fontSelectionView setFonts:fonts];
    self.fontSelectionView.delegate = self;
}

- (void)configureMusicSelectionView;
{
    
    self.audioSelectionView.backgroundColor = RGB(230, 231, 232, 1); //RGB(187, 90, 89, 1);
    self.audioSelectionView.layer.cornerRadius = 16;
    self.audioSelectionView.clipsToBounds = YES;
    
    // Create selection switch
    NSArray *strings = @[@" ", @"1", @"2", @"3", @"4", @"5"];
    DVSwitchWithIcon *selectionSwitch = [self switchMusicWithStringsArray:strings];
    selectionSwitch.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10.0f];
    
    // Set handler selected item index
    __weak BEBCreateVideoViewController *weakSelf = self;
    [selectionSwitch setPressedHandler:^(NSUInteger index) {
        [weakSelf handleSelectedAudioAtIndex:index];
    }];
    
    [self.audioSelectionView addSubview:selectionSwitch];
    
}

- (void)configureFPSSelectionView;
{
    self.fpsSelectionView.backgroundColor = RGB(230, 231, 232, 1); //RGB(187, 90, 89, 1);
    self.fpsSelectionView.layer.cornerRadius = 16;
    self.fpsSelectionView.clipsToBounds = YES;
    
    // Create selection switch
    NSArray *strings = @[@"x1", @"x3", @"x5", @"x7", @"x9"];
    DVSwitch *selectionSwitch = [self switchWithStringsArray:strings];
    
    // Set handler selected item index
    __weak BEBCreateVideoViewController *weakSelf = self;
    [selectionSwitch setPressedHandler:^(NSUInteger index) {
        [weakSelf handleSelectedFPSAtIndex:index];
    }];
    
    [self.fpsSelectionView addSubview:selectionSwitch];
}

- (void)configureAudioPlayerFromURL:(NSURL *)audioURL;
{
    // Create audio player
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioURL error:nil];
    self.audioPlayer.delegate = self;       // We need this so we can restart after interruptions
    self.audioPlayer.numberOfLoops = -1;	// Negative number means loop forever
    self.audioPlayer.volume = self.volumeSlider.value;
}

- (void)playAudio;
{
    //Responsible for playing trimmed song from music library only
    if(audioExportNameArray.count > 0) {
        
        NSTimeInterval trackLength = [[self.mediaItem valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue];
        
        self.trackCurrentLabel.text = [NSString stringFromTime:trackLength];
        
        if(self.audioPlayer.currentTime > self.sliderTrimmer.value) {
            NSLog(@"Playing trimmed song");
            
        } else if([self.loopVideoSwitch isUserInteractionEnabled]) {
            self.audioPlayer.currentTime = self.sliderTrimmer.value + self.rangeSlider.leftValue*self.songMaxTime;
            
        } else if(self.audioPlayer.currentTime == trackLength) {
            self.audioPlayer.currentTime = self.sliderTrimmer.value + self.rangeSlider.leftValue*self.songMaxTime;
            NSLog(@"%f.", trackLength);
            
        }
        
    }
    else {
        
        NSLog(@"music names are empty, trim audio first");
        if(self.istouchforpause) // pause else
        {
            self.audioPlayer.currentTime = self.sliderTrimmer.value + self.rangeSlider.leftValue*self.songMaxTime;
            self.istouchforpause = false;
        }
    }
    
    
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];
}

- (void)pauseAudio;
{
    
    [self.audioPlayer pause];
}

- (void)stopAudio;
{
    [self.audioPlayer stop];
    self.audioPlayer.currentTime = 0;
    self.istouchforpause = true;
    
}

- (void)playVideo;
{
    // Make playback timer for update playback
    self.playbackTimer = [NSTimer scheduledTimerWithTimeInterval:0.03f
                                                          target:self
                                                        selector:@selector(updatePlayback)
                                                        userInfo:nil
                                                         repeats:YES];
    [self playAudio];
}

- (void)pauseVideo;
{
    [self.playbackTimer invalidate];
    self.playbackTimer = nil;
    [self pauseAudio];
}

- (void)resetVideo;
{
    // Compute new video time
    self.updateImageTime = 1.0f / self.fpsValue;
    self.videoTime = (CGFloat)self.story.photos.count / (CGFloat)self.fpsValue;
    
    // Reset value
    self.playedTime = 0;
    self.photoIdx = 0;
    self.paused = NO;
    [self playButtonDidTouch:nil];
    [self stopAudio];
    [self.playButton setHidden:NO];
    [self.playButton setAlpha:1.0f];
    
    // Set default value for time label
    [self.playedTimeLabel setText:@"0:00"];
    [self.videoSlider setValue:0.0f];
    
    BEBImage *bebImage = self.story.photos[self.photoIdx];
    if (self.selectedFilterIdx == 0 || self.selectedFilterIdx == 4) {
        self.imageView.image = bebImage.image;
    }
    else {
        self.imageView.image = bebImage.effectImage;
    }
}

- (void)updatePlayback;
{
    // Update played time
    self.playedTime += 0.03f;
    
    // Reset played time
    if (self.playedTime >= self.videoTime) {
        self.playedTime = 0;
        self.photoIdx = 0;
        self.loopCount++;
        
        // Pause video and just play one time
        if(self.loopSelect.selectedSegmentIndex != 3){ //!loop
            if(self.loopCount >= self.loopSelect.selectedSegmentIndex+1){
                [self playButtonDidTouch:nil];
                [self stopAudio];
                self.loopCount = 0;
                
                [self.playButton setHidden:NO];
                [self.playButton setAlpha:1.0f];
            }
        }else{
//            self.audioPlayer.currentTime = self.sliderTrimmer.value + self.rangeSlider.leftValue*self.songMaxTime;
        }
    }
    else if (self.playedTime > (self.photoIdx + 1) * self.updateImageTime) {
        self.photoIdx++;
    }
    
    // Update time label
    [self.playedTimeLabel setText:[NSString stringWithFormat:@"%d:%02d", (int)self.playedTime / 60, (int)self.playedTime % 60]];
    
    // Update slider
    [self.videoSlider setValue:self.playedTime / self.videoTime];
    
    // Update image
    BEBImage *bebImage = self.story.photos[self.photoIdx];
    if (self.selectedFilterIdx == 0 || self.selectedFilterIdx == 4) {
        self.imageView.image = bebImage.image;
    }
    else {
        self.imageView.image = bebImage.effectImage;
    }
}

- (void)changeTabSelected:(NSInteger)tabSelected;
{
    // Hide volume
    [self.volumeSlider setHidden:YES];
    
    if (tabSelected == BEBCreateVideoTabSelectionTypeFont) {
        
        [self.fontSelectionView setHidden:NO];
        [self.containerColorView setHidden:NO];
        [self.audioSelectionView setHidden:YES];
        [self.fpsSelectionView setHidden:YES];
        
        
        [self.audioTrimmerView setHidden:YES];
        
        
        [self.fontButton setSelected:YES];
        [self.fontButton setBackgroundColor:RGB(255, 246, 223, 1)];
        
        [self.musicButton setSelected:NO];
        [self.musicButton setBackgroundColor:[UIColor clearColor]];
        
        [self.fpsButton setSelected:NO];
        [self.fpsButton setBackgroundColor:[UIColor clearColor]];
    }
    else if (tabSelected == BEBCreateVideoTabSelectionTypeMusic) {
        
        
        [self.fontSelectionView setHidden:YES];
        [self.containerColorView setHidden:YES];
        
        
        
        [self.fpsSelectionView setHidden:YES];
        
        if(self.selectedMusicFile){
            [self.audioTrimmerView setHidden:NO];
            [self.audioSelectionView setHidden:YES];
        }
        else{
            [self.audioSelectionView setHidden:NO];
            [self.audioTrimmerView setHidden:YES];
        }
        
        
        [self.musicButton setSelected:YES];
        [self.musicButton setBackgroundColor:RGB(255, 246, 223, 1)];
        
        [self.fontButton setSelected:NO];
        [self.fontButton setBackgroundColor:[UIColor clearColor]];
        
        [self.fpsButton setSelected:NO];
        [self.fpsButton setBackgroundColor:[UIColor clearColor]];
    }
    else {
        [self.fontSelectionView setHidden:YES];
        [self.containerColorView setHidden:YES];
        [self.audioSelectionView setHidden:YES];
        [self.audioTrimmerView setHidden:YES];
        [self.fpsSelectionView setHidden:NO];
        
        [self.fpsButton setSelected:YES];
        [self.fpsButton setBackgroundColor:RGB(255, 246, 223, 1)];
        
        [self.musicButton setSelected:NO];
        [self.musicButton setBackgroundColor:[UIColor clearColor]];
        
        [self.fontButton setSelected:NO];
        [self.fontButton setBackgroundColor:[UIColor clearColor]];
    }
}

- (void)handleSelectedFPSAtIndex:(NSInteger)index;
{
    NSArray *fpsValues = @[@1, @3, @5, @7, @9];
    self.fpsValue = [fpsValues[index] integerValue];
    [self resetVideo];
    
    // Hide volume
    [self.volumeSlider setHidden:YES];
}

- (void)handleSelectedAudioAtIndex:(NSInteger)index;
{
    if (index == 0) {
        self.silentMode = YES;
        self.audioPlayer.volume = 0;
    }
    
    else if (index  <= 3){
        self.silentMode = NO;
        NSString *fileName = [NSString stringWithFormat:@"audio%d", (int)index];
        NSString *audioPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"mp3"];
        NSURL *audioURL = [NSURL fileURLWithPath:audioPath];
        [self configureAudioPlayerFromURL:audioURL];
        [self resetVideo];
    }
    
    else {
        
    }
    
    // Set selected audio index
    self.seletedAudioIdx = index;
    
    // Hide volume
    [self.volumeSlider setHidden:YES];
}

- (CGRect)captionFrame;
{
    // Get the position of caption text with the image cropview
    CGRect rect = [self.previewView convertRect:self.captionTextField.frame fromView:self.captionView];
    
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

- (void)backButtonDidTouch:(id)sender;
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)backBarButtonDidTouch:(id)sender {
    BEBStoriesDetailViewController *storiesDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:kStoriesDetailViewControllerIdentifier];
    storiesDetailVC.story = self.story;
    
    [self.navigationController pushViewController:storiesDetailVC animated:NO];
}

- (void)rightButtonDidTouch:(id)sender {
   
        MPMediaPickerController *musicLibraryPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    
        musicLibraryPicker.delegate = self;
        musicLibraryPicker.allowsPickingMultipleItems = NO;
        musicLibraryPicker.showsCloudItems = NO;
        [self presentViewController:musicLibraryPicker animated:YES completion:nil];
}


- (void)touchPauseVideo:(UITapGestureRecognizer *)gestureRecognizer;
{
    
    if (!self.paused) {
        [self.playButton setHidden:NO];
        [self.playButton setAlpha:1.0f];
    }
    [self playButtonDidTouch:nil];
    
}

- (void)checkWarningVideoTooShortForMusic;
{
    if (self.videoTime < kMinVideoLengthForMusic) {
        
        // Show alert message to confirm delete
        if (iOS_Version >= 8) {
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                           message:kWarningVideoTooShortForMusic
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action) {
                                                               [alert dismissViewControllerAnimated:YES completion:nil];
                                                           }];
            
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action) {
                                                           [self alertView:nil clickedButtonAtIndex:0];
                                                       }];
            
            [alert addAction:cancel];
            [alert addAction:ok];
            
            [self presentViewController:alert animated:YES completion:nil];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:kConfirmDeleteStoryMessage
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:@"Cancel", nil];
            [alert show];
        }
    }
    else {
        
        // Get the caption position and font
        [self doTapOutside];
        
        // Show indicator creating video
        [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
        
        // Create video
        dispatch_async(dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL), ^{
            [self createVideo];
        });
    }
}

//*****************************************************************************
#pragma mark -
#pragma mark - ** Filter image methods **
- (void)changeFilterAtIndex:(NSInteger)index;
{
    if (self.selectedFilterIdx != index) {
        self.selectedFilterIdx = index;
        
        // Mocking new effect for image
        GPUImageShowcaseFilterType newEffect = GPUIMAGE_NONE;
        switch (index) {
            case 1:
                newEffect = GPUIMAGE_GRAYSCALE;
                break;
                
            case 2:
                newEffect = GPUIMAGE_MONOCHROMESUMMER;
                break;
                
            case 3:
                newEffect = GPUIMAGE_MONOCHROMESOFTBLUE;
                break;
                
            case 4:
                newEffect = GPUIMAGE_NATURAL;
                break;
        }
        
        // Apply effect for story
        [self applyFilterByEffect:newEffect];
    }
}

- (void)applyFilterByEffect:(GPUImageShowcaseFilterType)effect;
{
    // Show the processing
    [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    
    // Reset all the effect first
    for (BEBImage *bebImage in self.story.photos) {
        bebImage.effectImage = nil;
    }
    
    dispatch_queue_t myQueue = dispatch_queue_create("My Queue", NULL);
    dispatch_async(myQueue, ^{
        
        //        for (BEBImage *bebImage in self.story.photos) {
        //
        //            // Make the effect for images
        //            bebImage.effectImage = [self.imageFilter gpuImageFromImage:bebImage.image withType:effect];
        //        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self finishImageEffect];
        });
    });
}

- (void)finishImageEffect;
{
    // Reload the current view
    [self resetVideo];
    
    // Hidden the processing indicator
    [MBProgressHUD hideAllHUDsForView:self.view.window animated:YES];
}

//*****************************************************************************
#pragma mark -
#pragma mark - ** BEBFontSelectionViewDelegate **
- (void)bebFontSelectionView:(id)fontSelectionView didSelectFontAtIndex:(NSInteger)index;
{
    DEBUG_LOG(@"Font Index: %d", (int)index);
    if (index < 0) return;
    
    // Hide volume
    [self.volumeSlider setHidden:YES];
    
    self.captionView.hidden = NO;
    
    NSArray *fonts = [BEBDataManager sharedManager].fonts;
    
    // Change font for the caption view
    self.captionTextField.font = fonts[index];
    
    // Call method update size for the caption.
    [self doSingleTap];
}

//*****************************************************************************
#pragma mark -
#pragma mark - ** BEBAudioSelectionViewDelegate **
- (void)bebAudioSelectionView:(id)audioSelectionView didSelectAudioAtIndex:(NSInteger)index;
{
    /*
     DEBUG_LOG(@"Audio Index: %d", (int)index);
     if (index < 0) return;
     
     [self handleSelectedAudioAtIndex:index];
     
     // Hide volume
     [self.volumeSlider setHidden:YES];
     */
}

//*****************************************************************************
#pragma mark -
#pragma mark - ** AVAudioPlayerDelegate methods **

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player;
{
    //It is often not necessary to implement this method since by the time
    //this method is called, the sound has already stopped. You don't need to
    //stop it yourself.
    //In this case the backgroundMusicPlaying flag could be used in any
    //other portion of the code that needs to know if your music is playing.
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags;
{
    //Since this method is only called if music was previously interrupted
    //you know that the music has stopped playing and can now be resumed.
    [self playAudio];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField.text isEqualToString:@""]) {
        textField.text = placeHolderText;
    }
    
    [textField resignFirstResponder];
    
    return YES;
}

//*****************************************************************************
#pragma mark -
#pragma mark - ** IBAction methods **

- (IBAction)playButtonDidTouch:(id)sender;
{
    self.paused = !self.paused;
    
    if ([self isPaused]) {
        [self.playButton setImage:[UIImage imageNamed:@"icon_play"]
                         forState:UIControlStateNormal];
        [self pauseVideo];
        if(sender != nil) self.istouchforpause = true;
        else self.istouchforpause = false;
    }
    else {
        [self.playButton setImage:[UIImage imageNamed:@"icon_pause"]
                         forState:UIControlStateNormal];
        [self playVideo];
        
        [UIView animateWithDuration:0.1f animations:^{
            [self.playButton setAlpha:0];
        } completion:^(BOOL finished) {
            if (![self isPaused]) {
                [self.playButton setHidden:YES];
            }
        }];
    }
    
    // Hide volume
    if (sender) {
        [self.volumeSlider setHidden:YES];
    }
}

- (IBAction)videoSliderSeekTime:(id)sender;
{
    // Update played time
    self.playedTime = self.videoTime * self.videoSlider.value;
    
    // Update time label
    [self.playedTimeLabel setText:[NSString stringWithFormat:@"%d:%02d", (int)self.playedTime / 60, (int)self.playedTime % 60]];
    
    // Get photo index
    self.photoIdx = 0;
    while (self.playedTime > (self.photoIdx + 1) * self.updateImageTime) {
        self.photoIdx++;
    }
    // Update image
    BEBImage *bebImage = self.story.photos[self.photoIdx];
    if (self.selectedFilterIdx == 0 || self.selectedFilterIdx == 4) {
        self.imageView.image = bebImage.image;
    }
    else {
        self.imageView.image = bebImage.effectImage;
    }
    
    // Update current time audio
    self.audioPlayer.currentTime = self.playedTime +  + self.rangeSlider.leftValue*self.songMaxTime;
    
    // Hide volume
    [self.volumeSlider setHidden:YES];
}

- (IBAction)volumeButtonDidTouch:(id)sender;
{
    if ([self.volumeSlider isHidden]) {
        [self.volumeSlider setHidden:NO];
    }
    else {
        [self.volumeSlider setHidden:YES];
    }
}

- (IBAction)fontButtonDidTouch:(id)sender;
{
    [[NSUserDefaults standardUserDefaults] setObject:@"passed" forKey:@"tip14Name"];
    [self.tip14ImageView setHidden:YES];
    [self.tip14Close setHidden:YES];

    // Show font selection
    [self changeTabSelected:BEBCreateVideoTabSelectionTypeFont];
    
    [self captionFunctionDisable: YES];
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"tip15Name"] isEqualToString:@"passed"]) {
        [self.tip15ImageView setHidden:YES];
        [self.tip15Close setHidden:YES];
    }
}

- (IBAction)audioButtonDidTouch:(id)sender;
{
    [[NSUserDefaults standardUserDefaults] setObject:@"passed" forKey:@"tip16Name"];
    [self.tip16ImageView setHidden:YES];
    [self.tip16Close setHidden:YES];
    // Show audio selection
    [self changeTabSelected:BEBCreateVideoTabSelectionTypeMusic];
    
    [self captionFunctionDisable: NO];
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"tip15Name"] isEqualToString:@"passed"]) {
        [self.tip15ImageView setHidden:YES];
        [self.tip15Close setHidden:YES];
    }
    
}

- (IBAction)fpsButtonDidTouch:(id)sender;
{
    [[NSUserDefaults standardUserDefaults] setObject:@"passed" forKey:@"tip14Name"];
    [self.tip14ImageView setHidden:YES];
    [self.tip14Close setHidden:YES];
    [[NSUserDefaults standardUserDefaults] setObject:@"passed" forKey:@"tip16Name"];
    [self.tip16ImageView setHidden:YES];
    [self.tip16Close setHidden:YES];    // Show FPS selection
    [self changeTabSelected:BEBCreateVideoTabSelectionTypeFPS];
    
    [self captionFunctionDisable: NO];
}

- (IBAction)volumeSliderValueChanged:(id)sender;
{
    [[NSUserDefaults standardUserDefaults] setObject:@"passed" forKey:@"tip15Name"];
    [self.tip15ImageView setHidden:YES];
    [self.tip15Close setHidden:YES];
    // Change volume audio player
    if (![self isSilentMode]) {
        [self.audioPlayer setVolume:self.volumeSlider.value];
    }
}

- (IBAction)colorButtonDidTouch:(id)sender {
    
    UIColor *color = ((UIButton *)sender).backgroundColor;
    
    // Set color of the text field as selected color
    self.captionTextField.textColor = color;
    
    self.topContainerView.backgroundColor = color;
}

- (IBAction)firstAudioButtonDidTouch:(id)sender
{
    [self handleSelectedAudioAtIndex:1];
    [self.volumeSlider setHidden:YES];
    audioExportNameArray = nil;
    
}

- (IBAction)secondAudioButtonDidTouch:(id)sender
{
    [self handleSelectedAudioAtIndex:2];
    [self.volumeSlider setHidden:YES];
    audioExportNameArray = nil;
}

- (IBAction)thirdAudioButtonDidTouch:(id)sender
{
    [self handleSelectedAudioAtIndex:3];
    [self.volumeSlider setHidden:YES];
    audioExportNameArray = nil;
    
    
}

//Song selection from Music Library
- (IBAction)fourthAudioButtonDidTouch:(id)sender {
    [self handleSelectedAudioAtIndex:4];
    [self.volumeSlider setHidden:YES];
    MPMediaPickerController *musicLibraryPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    
    musicLibraryPicker.delegate = self;
    musicLibraryPicker.allowsPickingMultipleItems = NO;
    musicLibraryPicker.showsCloudItems = NO;
    [self presentViewController:musicLibraryPicker animated:YES completion:nil];
    
    
    
}

- (IBAction)speedSliderValueChanged:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:@"passed" forKey:@"tip15Name"];
    [self.tip15ImageView setHidden:YES];
    [self.tip15Close setHidden:YES];
    
    NSInteger maxSpeed = 20;
    CGFloat currentValue = self.speedSlider.value * maxSpeed;
    self.fpsValue = (NSInteger)currentValue;
    if (self.fpsValue == 0) {
        self.fpsValue = 1;
    }
    
    self.speedValueLabel.text = [NSString stringWithFormat:@"x%ld", (long)self.fpsValue];
    [self resetVideo];
    
    // Hide volume
    [self.volumeSlider setHidden:YES];
}

- (IBAction)loopVideoSwitchValueChanged:(id)sender
{
    
}

- (IBAction)doneButtonDidTouch:(id)sender
{
    
    // Check warning video too short for music
    [self checkWarningVideoTooShortForMusic];
}

- (void)captionFunctionDisable:(BOOL)value;
{
    // Change the user interaction for the caption view
    if (!value) {
        [self doTapOutside];
    }
    
    [self.captionView setUserInteractionEnabled:value];
}



- (IBAction)hiddenButtonDidTouch:(id)sender;
{
    if (self.bottomViewHidden == NO) {
        self.bottomViewHidden = YES;
        [self.hiddenBottomButton setImage:[UIImage imageNamed:@"up_images"] forState:UIControlStateNormal];
        
        [UIView animateWithDuration:0.2 animations:^{
            
            // Update height for buttom view -> hidden it
            self.bottomViewLayoutConstraint.constant = 0;
            
            // Update pause/play position
            self.playButtonLayoutConstraint.constant += self.bottomViewHeight/2;
            
            [self.view layoutIfNeeded];
            
        }];
    }
    else {
        self.bottomViewHidden = NO;
        [self.hiddenBottomButton setImage:[UIImage imageNamed:@"down_images"] forState:UIControlStateNormal];
        
        [UIView animateWithDuration:0.2 animations:^{
            
            // Update height for buttom view -> show it
            self.bottomViewLayoutConstraint.constant = self.bottomViewHeight;
            
            // Update pause/play position
            self.playButtonLayoutConstraint.constant -= self.bottomViewHeight/2;
            
            [self.view layoutIfNeeded];
            
        }];
    }
}
//*****************************************************************************


#pragma
#pragma music trimming

- (IBAction)nextBarButton:(id)sender {
    audioExportNameArray = [[NSMutableArray alloc] init];
    NSString *musicNameList = @"";
    
    NSTimeInterval trackLength = [[self.mediaItem valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue];
    double startAt = self.sliderTrimmer.value;
    
    
    double endAt = trackLength;
    int i = 0;
    
    AVAsset *asset = [AVAsset assetWithURL:self.musicLibaryURL];
    NSString *outPutName = [NSString stringWithFormat:@"export%i.m4a",i];
    [audioExportNameArray addObject:outPutName];
    [self exportAsset:asset toFile:outPutName overwrite:YES startAt:startAt endAt:endAt];
    
    
    musicNameList = [NSString stringWithFormat:@"%@\n%@",musicNameList, self.musicLibaryURL.lastPathComponent];
    
    
    startAt += self.sliderTrimmer.value;
    endAt += trackLength;
    
    [self.audioTrimmerView setHidden:YES];
    [self.audioSelectionView setHidden:NO];
    [self.doneButton setHidden:NO];
    [self.nextButton setEnabled:NO];
    [self.nextButton setTintColor:[UIColor clearColor]];
    
    
    
    self.customizedButton2 = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"icon_close"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(backButtonDidTouch:)];
    
    self.navigationItem.leftBarButtonItem = self.customizedButton2;
    
    self.titleLabelNavigationBar.textColor = [UIColor whiteColor]; // change this color
    self.titleLabelNavigationBar.text = NSLocalizedString(@"CREATE VIDEO", @"");
    
}

- (IBAction)sliderTrimmerButton:(UISlider *)sender {
    self.panningProgress = YES;
    self.trackCurrentPlayback.text = [NSString stringFromTime:sender.value];
}

- (IBAction)rewindBackBarButton:(id)sender {
}

- (IBAction)progressEnd {
    // Only when dragging is done, we change the playback time.
    self.audioPlayer.currentTime = self.sliderTrimmer.value;
    self.panningProgress = NO;
}

- (NSString *) applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = paths.firstObject;
    return basePath;
}

-(void)exportAsset:(AVAsset*)asset toFile:(NSString*)filename overwrite:(BOOL)overwrite startAt:(float)vocalStartMarker endAt:(float)vocalEndMarker {
    
    AVAssetExportSession* exporter = [AVAssetExportSession exportSessionWithAsset:asset presetName:AVAssetExportPresetAppleM4A];
    
    if (exporter == nil) {
        NSLog(@"Failed creating exporter!");
        return;
    }
    
    NSLog(@"Created exporter! %@", exporter);
    
    // Set output file type
    NSLog(@"Supported file types: %@", exporter.supportedFileTypes);
    for (NSString* filetype in exporter.supportedFileTypes) {
        if ([filetype isEqualToString:AVFileTypeAppleM4A]) {
            exporter.outputFileType = AVFileTypeAppleM4A;
            break;
        }
    }
    if (exporter.outputFileType == nil) {
        NSLog(@"Needed output file type not found? (%@)", AVFileTypeAppleM4A);
        return;
    }
    
    //OutputURL
    
    NSString* outPath = [NSString stringWithFormat:@"%@/%@", [self applicationDocumentsDirectory], filename];
    NSLog(@"outPath: %@",outPath);
    
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:outPath]) {
        NSLog(@"%@ already exists!", outPath);
        if (!overwrite) {
            NSLog(@"Not overwriting, uh oh!");
            return;
        }
        else {
            // Overwrite
            NSLog(@"Overwrite! (delete first)");
            NSError* error = nil;
            if (![manager removeItemAtPath:outPath error:&error]) {
                NSLog(@"Failed removing %@, error: %@", outPath, error.description);
                return;
            }
            else {
                NSLog(@"Removed %@", outPath);
            }
        }
    }
    
    CMTime startTime = CMTimeMake((int)(floor(vocalStartMarker * 100)), 100);
    CMTime stopTime = CMTimeMake((int)(ceil(vocalEndMarker * 100)), 100);
    CMTimeRange exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime);
    
    NSURL* const outUrl = [NSURL fileURLWithPath:outPath];
    exporter.outputURL = outUrl;
    exporter.timeRange = exportTimeRange;
    exporter.outputFileType = AVFileTypeAppleM4A;
    
    NSLog(@"Starting export! (%@)", exporter.outputURL);
    [exporter exportAsynchronouslyWithCompletionHandler:^(void) {
        // Export ended for some reason. Check in status
        NSString* message;
        switch (exporter.status) {
            case AVAssetExportSessionStatusFailed:
                message = [NSString stringWithFormat:@"Export failed. Error: %@", exporter.error.description];
                NSLog(@"%@", message);
                
                break;
            case AVAssetExportSessionStatusCompleted: {
                
                message = [NSString stringWithFormat:@"Export completed: %@ %@",exporter.outputURL, filename];
                NSLog(@"%@", message);
                
                break;
            }
            case AVAssetExportSessionStatusCancelled:
                message = [NSString stringWithFormat:@"Export cancelled!"];
                NSLog(@"%@", message);
                
                break;
            default:
                NSLog(@"Export unhandled status: %ld", (long)exporter.status);
                break;
        }
    }];
}

//*****************************************************************************
#pragma mark -
#pragma mark - ** Video Create methods **

- (void)createVideo;
{
    NSError *error = nil;
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *videoOutputPath = [documentsDirectory stringByAppendingPathComponent:@"TempVideo.mp4"];
    if (![[NSFileManager defaultManager] removeItemAtPath:videoOutputPath error:&error]) {
        DEBUG_LOG(@"Unable to delete file: %@", [error localizedDescription]);
    }
    
    // (1920 x 1080), (1280 x 720), (640 x 480), (480 x 360)
    CGSize videoSize = [BEBUtilities videoSizeByIndex:1];
    //    BEBImage *bebImage = self.story.photos[0];
    //    CGSize videoSize = bebImage.image.size;
    
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:videoOutputPath]
                                                           fileType:AVFileTypeQuickTimeMovie
                                                              error:&error];
    NSParameterAssert(videoWriter);
    
    NSDictionary *videoSettings = @{AVVideoCodecKey: AVVideoCodecH264,
                                    AVVideoWidthKey: [NSNumber numberWithInt:videoSize.width],
                                    AVVideoHeightKey: [NSNumber numberWithInt:videoSize.height]};
    
    AVAssetWriterInput *videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                                                              outputSettings:videoSettings];
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoWriterInput
                                                     sourcePixelBufferAttributes:nil];
    NSParameterAssert(videoWriterInput);
    NSParameterAssert([videoWriter canAddInput:videoWriterInput]);
    
    videoWriterInput.expectsMediaDataInRealTime = YES;
    [videoWriter addInput:videoWriterInput];
    
    // Start a session
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    CVPixelBufferRef buffer = NULL;
    
    NSInteger frameCount = 0;
    for (BEBImage *bebImage in self.story.photos) {
        
        UIImage *image = bebImage.effectImage;
        if (self.selectedFilterIdx == 0 || self.selectedFilterIdx == 4) {
            image = bebImage.image;
        }
        
        // Convert UIImage to CGImage.
        buffer = [self pixelBufferFromCGImage:[image CGImage] videoSize:videoSize];
        
        BOOL appendOK = NO;
        NSInteger j = 0;
        
        while (!appendOK && j < 30) {
            
            if (adaptor.assetWriterInput.readyForMoreMediaData) {
                // Print out status
                DEBUG_LOG(@"Processing video frame (%ld, %ld)", (long)frameCount, (unsigned long)[self.story.photos count]);
                
                CMTime frameTime = CMTimeMake(frameCount, (int32_t)self.fpsValue);
                appendOK = [adaptor appendPixelBuffer:buffer withPresentationTime:frameTime];
                if (!appendOK) {
                    NSError *error = videoWriter.error;
                    if (error) {
                        DEBUG_LOG(@"Unresolved error %@, %@.", error, [error userInfo]);
                    }
                }
            }
            else {
                DEBUG_LOG(@"Adaptor not ready %ld, %ld\n", (long)frameCount, (long)j);
                [NSThread sleepForTimeInterval:0.1];
            }
            
            j++;
        }
        
        if (!appendOK) {
            DEBUG_LOG(@"Error appending image %ld times %ld\n, with error.", (long)frameCount, (long)j);
        }
        
        frameCount++;
    }
    
    // Finish the session
    [videoWriterInput markAsFinished];
    
    __weak typeof(self) weakSelf = self;
    [videoWriter finishWritingWithCompletionHandler:^{
        
        DEBUG_LOG(@"Successfully closed video writer");
        
        if (videoWriter.status == AVAssetWriterStatusCompleted) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                BEBCreateVideoViewController *strongSelf = weakSelf;
                [strongSelf addAudioAndExportVideoAtPath:videoOutputPath];
            });
        }
    }];
}

- (void)addAudioAndExportVideoAtPath:(NSString *)videoOutputPath;
{
    AVMutableComposition *mixComposition = [AVMutableComposition composition];
    
    // Audio input file
    NSString *bundleDirectory = [[NSBundle mainBundle] bundlePath];
    NSString *fileName = [NSString stringWithFormat:@"audio%d.mp3", (int)self.seletedAudioIdx];
    NSString *audioInputFilePath = [bundleDirectory stringByAppendingPathComponent:fileName];
    NSURL *audioInputFileUrl = [NSURL fileURLWithPath:audioInputFilePath];
    
    // Video input file URL
    NSURL *videoInputFileUrl = [NSURL fileURLWithPath:videoOutputPath];
    
    // Create the final video output file as MOV file - may need to be MP4, but this works so far...
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *outputFilePath = [documentsDirectory stringByAppendingPathComponent:@"FinalVideo.mp4"];
    NSURL *outputFileUrl = [NSURL fileURLWithPath:outputFilePath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputFilePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:outputFilePath error:nil];
    }
    
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:videoInputFileUrl options:nil];
    CMTimeRange videoTimeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                                   preferredTrackID:kCMPersistentTrackID_Invalid];
    
    AVAssetTrack *clipVideoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    [compositionVideoTrack insertTimeRange:videoTimeRange
                                   ofTrack:clipVideoTrack
                                    atTime:kCMTimeZero
                                     error:nil];
    
    // Check add audio to video
    if (![self isSilentMode] && self.videoTime >= kMinVideoLengthForMusic) {
        
        AVURLAsset *audioAsset = [[AVURLAsset alloc]initWithURL:audioInputFileUrl options:nil];
        CGFloat audioTime = audioAsset.duration.value / audioAsset.duration.timescale;
        CMTime duration = audioAsset.duration;
        if (self.videoTime < audioTime) {
            duration = videoAsset.duration;
        }
        
        CMTimeRange audioTimeRange = CMTimeRangeMake(kCMTimeZero, duration);
        AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                                       preferredTrackID:kCMPersistentTrackID_Invalid];
        
        AVAssetTrack *clipAudioTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        [compositionAudioTrack insertTimeRange:audioTimeRange
                                       ofTrack:clipAudioTrack
                                        atTime:kCMTimeZero
                                         error:nil];
        
        // Add audio loop
        CGFloat currentAudioTime = audioTime;
        CMTimeScale	timescale = audioAsset.duration.timescale;
        while (currentAudioTime < self.videoTime) {
            
            if (currentAudioTime + audioTime <= self.videoTime) {
                duration = audioAsset.duration;
            }
            else {
                duration = CMTimeMake(timescale * (self.videoTime - currentAudioTime), timescale);
            }
            
            CMTime startTime = CMTimeMake(timescale * currentAudioTime, timescale);
            [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, duration)
                                           ofTrack:clipAudioTrack
                                            atTime:startTime
                                             error:nil];
            currentAudioTime += audioTime;
        }
    }
    
    CGSize videoSize = [clipVideoTrack naturalSize];
    
    // Create an AVMutableVideoCompositionLayerInstruction for the video track and fix the orientation.
    AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTrack];
    
    [layerInstruction setTransform:clipVideoTrack.preferredTransform atTime:kCMTimeZero];
    [layerInstruction setOpacity:0.0 atTime:videoAsset.duration];
    
    // Create AVMutableVideoCompositionInstruction
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [mixComposition duration]);
    
    // Add instructions
    instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
    
    AVMutableVideoComposition *videoComposition = nil;
    
    // Check user input caption for video
    if (self.captionTextField.text.length > 0 &&
        ![self.captionTextField.text isEqualToString:placeHolderText]) {
        
        // AVMutableVideoComposition
        videoComposition = [AVMutableVideoComposition videoComposition];
        videoComposition.renderSize = videoSize;
        videoComposition.instructions = [NSArray arrayWithObject:instruction];
        videoComposition.frameDuration = CMTimeMake(1, 30);
        
        // Adjust caption frame since the video align it on bottom - left.
        CGRect frame = [self captionFrame];
        NSUInteger scale = [UIScreen mainScreen].scale;
        frame.origin.x *= scale;
        frame.origin.y *= scale;
        frame.size.width *= scale;
        frame.size.height *= scale;
        
        // Y position from the bottom to the top
        CGFloat frameHeight = scale * CGRectGetHeight(self.previewView.frame);
        frame.origin.y = frameHeight - frame.origin.y;
        
        /***** THIS FUNCTION IS NOT AVAIABLE IN THE SIMULATOR  ****/
        
        // Set up the text layer
        UIFont *font = [self captionFont];
        CATextLayer *captionText = [[CATextLayer alloc] init];
        [captionText setFont:(__bridge CFTypeRef)(font.fontName)];
        [captionText setFontSize:font.pointSize];
        [captionText setFrame:frame];
        [captionText setString:self.captionTextField.text];
        [captionText setAlignmentMode:kCAAlignmentCenter];
        [captionText setForegroundColor:[UIColor whiteColor].CGColor];
        
        // The usual overlay
        CALayer *overlayLayer = [CALayer layer];
        [overlayLayer addSublayer:captionText];
        overlayLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
        [overlayLayer setMasksToBounds:YES];
        
        CALayer *parentLayer = [CALayer layer];
        CALayer *videoLayer = [CALayer layer];
        parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
        videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
        [parentLayer addSublayer:videoLayer];
        [parentLayer addSublayer:overlayLayer];
        
        videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    }
    
    AVAssetExportSession *assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                         presetName:AVAssetExportPresetHighestQuality];
    assetExport.videoComposition = videoComposition;
    assetExport.outputFileType = AVFileTypeQuickTimeMovie;
    assetExport.shouldOptimizeForNetworkUse = YES;
    assetExport.outputURL = outputFileUrl;
    
    __weak typeof(self) weakSelf = self;
    [assetExport exportAsynchronouslyWithCompletionHandler:^(void ) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            BEBCreateVideoViewController *strongSelf = weakSelf;
            [MBProgressHUD hideHUDForView:strongSelf.view.window animated:YES];
            
            // Show sharing video view controller
            BEBSharingVideoViewController *sharingVideoVC = [strongSelf.storyboard instantiateViewControllerWithIdentifier:kSharingVideoViewControllerIdentifier];
            
            sharingVideoVC.titleVideo = strongSelf.story.title;
            sharingVideoVC.videoURL = outputFileUrl;
            sharingVideoVC.videoTime = strongSelf.videoTime;
            
            [strongSelf.navigationController pushViewController:sharingVideoVC
                                                       animated:YES];
        });
    }];
    
    DEBUG_LOG(@"DONE...OutputFilePath: %@", outputFilePath);
}

- (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image videoSize:(CGSize)size;
{
    NSDictionary *options = @{(id)kCVPixelBufferCGImageCompatibilityKey: @YES,
                              (id)kCVPixelBufferCGBitmapContextCompatibilityKey: @YES};
    
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                          size.width,
                                          size.height,
                                          kCVPixelFormatType_32ARGB,
                                          (__bridge CFDictionaryRef)options,
                                          &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    if (status != kCVReturnSuccess) {
        DEBUG_LOG(@"Failed to create pixel buffer");
    }
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, size.width,
                                                 size.height, 8, 4*size.width, rgbColorSpace,
                                                 (CGBitmapInfo)kCGImageAlphaPremultipliedFirst); // kCGImageAlphaNoneSkipFirst
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    CGRect rect = CGRectMake((size.width - CGImageGetWidth(image))/2,
                             (size.height - CGImageGetHeight(image))/2,
                             CGImageGetWidth(image),
                             CGImageGetHeight(image));
    
    CGContextDrawImage(context, rect, image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

//*****************************************************************************
#pragma mark -
#pragma mark - ** UIAlertViewDelegate methods **
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if (buttonIndex == 0) {
        
        // Get the caption position and font
        [self doTapOutside];
        
        // Show indicator creating video
        [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
        
        // Create video
        dispatch_async(dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL), ^{
            [self createVideo];
        });
    }
}

//*****************************************************************************
#pragma mark -
#pragma mark - ** MPMediaPickerControllerDelegate

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker
  didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    
    MPMediaItem *i;
    MPMediaItem *item = [[mediaItemCollection items] objectAtIndex:0];
    _musicLibaryURL = [item valueForProperty:MPMediaItemPropertyAssetURL];
    i = mediaItemCollection.items[0];
    self.mediaItem = i;
    self.nameOfSelectedSong.text = [i valueForProperty:MPMediaItemPropertyTitle];
    self.nameOfSelectedSongTrimerPortion.text = [i valueForProperty:MPMediaItemPropertyTitle];
    
    NSTimeInterval trackLength = [[self.mediaItem valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue];
    
    self.trackCurrentLabel.text = [NSString stringFromTime:trackLength];
    _rangeSlider.leftValue = 0;
    _rangeSlider.maxValue = 1.0;
    _rangeSlider.minValue = 0;
    int frames = self.story.photos.count;
    self.songMaxTime = trackLength;
    _rangeSlider.rightValue = frames / (self.songMaxTime * self.fpsValue);
    self.initialLeftVal = _rangeSlider.leftValue;
    self.initialRightVal = _rangeSlider.rightValue;
    self.sliderTrimmer.value = 0;
    self.sliderTrimmer.maximumValue = trackLength;
    
    [self.nextButton setEnabled:YES];
    [self.nextButton setTintColor:nil];
    
    
    [self.customizedButton setImage:nil];
    [self.customizedButton setEnabled:NO];
    
    
    
    self.backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backBarButtonDidTouch:)];
    self.selectSongButton = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStyleBordered target:self action:@selector(rightButtonDidTouch:)];
    self.navigationItem.rightBarButtonItem = self.selectSongButton;
    self.navigationItem.leftBarButtonItem = self.backButton;
    
    self.titleLabelNavigationBar.textColor = [UIColor whiteColor];
    self.titleLabelNavigationBar.text = NSLocalizedString(@"Edit Song Clip", @"");
    
    [self configureAudioPlayerFromURL:_musicLibaryURL];
    [self.audioTrimmerView setHidden:NO];
    [self.audioSelectionView setHidden:YES];
    [self.fpsSelectionView setHidden:YES];
    [self.fontSelectionView setHidden:YES];
    [self.containerColorView setHidden:YES];
    [self.doneButton setHidden:YES];
    self.selectedMusicFile = true;
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

#import "BEBCamViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImage+Helper.h"
#import "AVCamPreviewView.h"
#import "BEBDataManager.h"
#import "BEBMarginLabel.h"

@import ImageIO;

static const CGFloat kiOSVersion8 = 8.0;

static void * CapturingStillImageContext = &CapturingStillImageContext;
static void * SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;
static void * CameraTorchModeObservationContext     = &CameraTorchModeObservationContext;

static NSTimeInterval dayTime = 24.0f * 60.0f * 60.0f;

static int topViewHeight = 40;
static int bottomViewHeight = 40;
static CGFloat limitValue = 0.1;    // 10%

@interface BEBCamViewController () <AVCaptureVideoDataOutputSampleBufferDelegate, UIAlertViewDelegate>

#pragma mark IBOutlet.
@property (weak, nonatomic) IBOutlet AVCamPreviewView *previewView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *subBottomView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *flashButton;
@property (weak, nonatomic) IBOutlet UIButton *switchCameraButton;
@property (weak, nonatomic) IBOutlet UIButton *captureButton;
@property (weak, nonatomic) IBOutlet UIButton *showPreviousImageButton;
@property (weak, nonatomic) IBOutlet UIButton *gridCameraButton;
@property (weak, nonatomic) IBOutlet UIImageView *gridPhotoView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIImageView *leftArrow180ImageView;

// Guide part
@property (weak, nonatomic) IBOutlet UILabel *rightGuideLabel;   // Right label and icon
@property (weak, nonatomic) IBOutlet UIImageView *rightGuideIcon;

@property (weak, nonatomic) IBOutlet UILabel *leftGuideLabel;   // Left label and icon
@property (weak, nonatomic) IBOutlet UIImageView *leftGuideIcon;
@property (weak, nonatomic) IBOutlet BEBMarginLabel *guideWeekLabel;
@property (weak, nonatomic) IBOutlet BEBMarginLabel *guideAngleLabel;
// Constraint
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTopViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBottomViewHeight;
@property (weak, nonatomic) IBOutlet UISlider *transparenceOverlaySlider;

@property (weak, nonatomic) IBOutlet UIImageView *tip6ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *tip7ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *tip8ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *tip9ImageView;
@property (weak, nonatomic) IBOutlet UIButton *tip6Close;
@property (weak, nonatomic) IBOutlet UIButton *tip7Close;
@property (weak, nonatomic) IBOutlet UIButton *tip8Close;
@property (weak, nonatomic) IBOutlet UIButton *tip9Close;

#pragma mark Properties.
@property (nonatomic) BOOL showCameraGrid;
@property (nonatomic) BOOL isUsingFrontFacingCamera;
@property (nonatomic) BOOL takePhotoFlag;
@property (nonatomic) BOOL showPreviousPhotoFlag;

@property (strong, nonatomic) UIImage *image;

@property (nonatomic) BOOL faceDetectEnable;
@property (nonatomic, strong) CIDetector *faceDetector;
@property (nonatomic) BEBDetectFaceSimilarType currentGuide;

// Realtime video output
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic) dispatch_queue_t videoDataOutputQueue;
@property (nonatomic) UIDeviceOrientation orientation;

// Guide image face and belly bump
@property (strong, nonatomic) UIImageView *faceStencilImageView;
@property (strong, nonatomic) UIImageView *faceLineImageView;
@property (strong, nonatomic) UIImageView *bellBumpStencilImageView;
@property (strong, nonatomic) UIImageView *bellyBumpLineImageView;
@property (nonatomic) CGPoint priorPoint;

@property (nonatomic) CGRect faceRect;


#pragma mark IBAction.
- (IBAction)switchCameraButtonClick:(id)sender;
- (IBAction)captureImageButtonClick:(id)sender;
- (IBAction)changeFlashButtonClick:(id)sender;
- (IBAction)showPreviousButtonClick:(id)sender;
- (IBAction)closeButtonClick:(id)sender;
- (IBAction)gridCameraButtonClick:(id)sender;
- (IBAction)transparenceOverlaySliderValueChanged:(id)sender;
- (IBAction)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer;
- (IBAction)guideButtonClick:(id)sender;
- (IBAction)tip6ButtonClick:(id)sender;
- (IBAction)tip7ButtonClick:(id)sender;
- (IBAction)tip8ButtonClick:(id)sender;
- (IBAction)tip9ButtonClick:(id)sender;

// Session management.
@property (nonatomic) dispatch_queue_t sessionQueue; // Communicate with the session and other session objects on this queue.
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;

// Utilities.
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;
@property (nonatomic, getter = isDeviceAuthorized) BOOL deviceAuthorized;
@property (nonatomic, readonly, getter = isSessionRunningAndDeviceAuthorized) BOOL sessionRunningAndDeviceAuthorized;
@property (nonatomic) BOOL lockInterfaceRotation;
@property (nonatomic) id runtimeErrorHandlingObserver;
@property (weak, nonatomic) IBOutlet UIView *viewTest;

@end

@implementation BEBCamViewController

- (BOOL)isSessionRunningAndDeviceAuthorized
{
	return [[self session] isRunning] && [self isDeviceAuthorized];
}

+ (NSSet *)keyPathsForValuesAffectingSessionRunningAndDeviceAuthorized
{
	return [NSSet setWithObjects:@"session.running", @"deviceAuthorized", nil];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// Create the AVCaptureSession
	AVCaptureSession *session = [[AVCaptureSession alloc] init];
    [session setSessionPreset:AVCaptureSessionPresetPhoto];
	[self setSession:session];
	
	// Setup the preview view
	[[self previewView] setSession:session];
	
	// Check for device authorization
	[self checkDeviceAuthorizationStatus];
	
    // Configure the overlay transparence for the overlay
    [self configureTransparenceOverlaySlider];
    
    [self initLocalVarialble];

    // Checking if have the previous image -> enable the previous button
    [self displayPreviousImage];
    
    self.rightGuideLabel.clipsToBounds = YES;
    self.leftGuideLabel.clipsToBounds = YES;
    
    if (self.story.photos.count == 0) {
        self.firstImage = YES;
    }
    // Add the stencil to guide user how to capture the image
    [self addGuideStencil];
    
    [self show180DegreeGuideView];

    [self.view bringSubviewToFront:self.closeButton];
    
	// In general it is not safe to mutate an AVCaptureSession or any of its inputs, outputs, or connections from multiple threads at the same time.
	// Why not do all of this on the main queue?
	// -[AVCaptureSession startRunning] is a blocking call which can take a long time. We dispatch session setup to the sessionQueue so that the main queue isn't blocked (which keeps the UI responsive).
	
#if TARGET_IPHONE_SIMULATOR
    
#else
	dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
	[self setSessionQueue:sessionQueue];
	
    dispatch_async(sessionQueue, ^{
        [self setBackgroundRecordingID:UIBackgroundTaskInvalid];
        
        NSError *error = nil;
        
            AVCaptureDevice *videoDevice;
        if ((self.story.storyType == StoryTypeDetailShot && self.story.isPregnancy)||
            (self.story.storyType == StoryType180Degree && self.story.isPregnancy)) {
            videoDevice = [BEBCamViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionFront];
        }
        else {
            videoDevice = [BEBCamViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
        }
        
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        
        if (error) {
            NSLog(@"%@", error);
        }
        
        /****** PREVIEW IMAGE IN SCREEN *****/
        
        if ([session canAddInput:videoDeviceInput]) {
            [session addInput:videoDeviceInput];
            [self setVideoDeviceInput:videoDeviceInput];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // Why are we dispatching this to the main queue?
                // Because AVCaptureVideoPreviewLayer is the backing layer for AVCamPreviewView and UIView can only be manipulated on main thread.
                // Note: As an exception to the above rule, it is not necessary to serialize video orientation changes on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
                [(AVCaptureVideoPreviewLayer *)[self.previewView layer] setVideoGravity:AVLayerVideoGravityResizeAspectFill];
                
//               [[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)[self interfaceOrientation]];
            });
        }
        
        /****** FACE DETECT SUPPORT *****/
        // Using for detect face from image taken from video data output

        self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        
        // we want BGRA, both CoreGraphics and OpenGL work well with 'BGRA'
        NSDictionary *rgbOutputSettings = [NSDictionary dictionaryWithObject:
                                           [NSNumber numberWithInt:kCMPixelFormat_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
        [self.videoDataOutput setVideoSettings:rgbOutputSettings];
        [self.videoDataOutput setAlwaysDiscardsLateVideoFrames:YES]; // discard if the data output queue is blocked
        
        // create a serial dispatch queue used for the sample buffer delegate
        // a serial dispatch queue must be used to guarantee that video frames will be delivered in order
        // see the header doc for setSampleBufferDelegate:queue: for more information
        self.videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
        [self.videoDataOutput setSampleBufferDelegate:self queue:self.videoDataOutputQueue];
        
        if ([session canAddOutput:self.videoDataOutput]) {
            [session addOutput:self.videoDataOutput];
        }
        
        // get the output for doing face detection.
        [[self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:YES];

        
        /****** CAPTURE IMAGE LISTENING FUNCTION *****/
        
        AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        if ([session canAddOutput:stillImageOutput]) {
            [stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
            [session addOutput:stillImageOutput];
            [self setStillImageOutput:stillImageOutput];
        }
    });
    
#endif

}
-(void)viewTip6{
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"tip6Name"] isEqualToString:@"passed"]) {
        [self.tip6ImageView setHidden:YES];
        [self.tip6Close setHidden:YES];
        [self viewTip7];
    } else {
        [self.tip6ImageView setHidden:NO];
        [self.tip6Close setHidden:NO];
        CABasicAnimation *fadeInAnimate   = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeInAnimate.duration            = 3;
        fadeInAnimate.repeatCount         = 1;
        fadeInAnimate.autoreverses        = NO;
        fadeInAnimate.fromValue           = [NSNumber numberWithFloat:0.0];
        fadeInAnimate.toValue             = [NSNumber numberWithFloat:1.0];
        fadeInAnimate.removedOnCompletion = YES;
        [self.tip6ImageView.layer addAnimation:fadeInAnimate forKey:@"animateOpacity"];
        [self.tip6Close.layer addAnimation:fadeInAnimate forKey:@"animateOpacity"];
        [[NSUserDefaults standardUserDefaults] setObject:@"passed" forKey:@"tip6Name"];
    }
}
-(void)viewTip7{
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"tip7Name"] isEqualToString:@"passed"]) {
        [self.tip7ImageView setHidden:YES];
        [self.tip7Close setHidden:YES];
        [self viewTip8];
    } else {
        [self.tip7ImageView setHidden:NO];
        [self.tip7Close setHidden:NO];
        CABasicAnimation *fadeInAnimate   = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeInAnimate.duration            = 3;
        fadeInAnimate.repeatCount         = 1;
        fadeInAnimate.autoreverses        = NO;
        fadeInAnimate.fromValue           = [NSNumber numberWithFloat:0.0];
        fadeInAnimate.toValue             = [NSNumber numberWithFloat:1.0];
        fadeInAnimate.removedOnCompletion = YES;
        [self.tip7ImageView.layer addAnimation:fadeInAnimate forKey:@"animateOpacity"];
        [self.tip7Close.layer addAnimation:fadeInAnimate forKey:@"animateOpacity"];
        [[NSUserDefaults standardUserDefaults] setObject:@"passed" forKey:@"tip7Name"];
    }
}
-(void)viewTip8{
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"tip8Name"] isEqualToString:@"passed"]) {
        [self.tip8ImageView setHidden:YES];
        [self.tip8Close setHidden:YES];
        [self viewTip9];
    } else {
        [self.tip8ImageView setHidden:NO];
        [self.tip8Close setHidden:NO];
        
        CABasicAnimation *fadeInAnimate   = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeInAnimate.duration            = 3;
        fadeInAnimate.repeatCount         = 1;
        fadeInAnimate.autoreverses        = NO;
        fadeInAnimate.fromValue           = [NSNumber numberWithFloat:0.0];
        fadeInAnimate.toValue             = [NSNumber numberWithFloat:1.0];
        fadeInAnimate.removedOnCompletion = YES;
        [self.tip8ImageView.layer addAnimation:fadeInAnimate forKey:@"animateOpacity"];
        [self.tip8Close.layer addAnimation:fadeInAnimate forKey:@"animateOpacity"];
        [[NSUserDefaults standardUserDefaults] setObject:@"passed" forKey:@"tip8Name"];
    }
    
}
-(void)viewTip9{
    
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"tip9Name"] isEqualToString:@"passed"]) {
        [self.tip9ImageView setHidden:YES];
        [self.tip9Close setHidden:YES];
    } else {
        [self.tip9ImageView setHidden:NO];
        [self.tip9Close setHidden:NO];
        CABasicAnimation *fadeInAnimate   = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeInAnimate.duration            = 3;
        fadeInAnimate.repeatCount         = 1;
        fadeInAnimate.autoreverses        = NO;
        fadeInAnimate.fromValue           = [NSNumber numberWithFloat:0.0];
        fadeInAnimate.toValue             = [NSNumber numberWithFloat:1.0];
        fadeInAnimate.removedOnCompletion = YES;
        [self.tip9ImageView.layer addAnimation:fadeInAnimate forKey:@"animateOpacity"];
        [self.tip9Close.layer addAnimation:fadeInAnimate forKey:@"animateOpacity"];
        [[NSUserDefaults standardUserDefaults] setObject:@"passed" forKey:@"tip9Name"];
    }

}

- (void)viewWillAppear:(BOOL)animated
{
    [self viewTip6];
    
    [super viewWillAppear:animated];
    
    [self updateFlashButtonByTochMode:AVCaptureTorchModeOff];
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationNone];

    self.previewView.alpha = 1.0f;

#if TARGET_IPHONE_SIMULATOR
    
#else

	dispatch_async([self sessionQueue], ^{
		[self addObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:SessionRunningAndDeviceAuthorizedContext];
		[self addObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:CapturingStillImageContext];
        [self addObserver:self forKeyPath:@"torchMode" options:NSKeyValueObservingOptionNew context:CameraTorchModeObservationContext];
        
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
		
		__weak BEBCamViewController *weakSelf = self;
		[self setRuntimeErrorHandlingObserver:[[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureSessionRuntimeErrorNotification object:[self session] queue:nil usingBlock:^(NSNotification *note) {
			BEBCamViewController *strongSelf = weakSelf;
			dispatch_async([strongSelf sessionQueue], ^{
				// Manually restarting the session since it must have been stopped due to an error.
				[[strongSelf session] startRunning];
			});
		}]];
        
		[[self session] startRunning];
	});
    
#endif

    // Detect the user face in previous photo and get the face detect value.
    if (self.previousPhoto){
        
        // Scale and crop the previous image to the screen size
        [self cropPreviousImageToCurrentView];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.previewView.alpha = 0.0f;
    }];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationNone];
    
#if TARGET_IPHONE_SIMULATOR

#else
	dispatch_async([self sessionQueue], ^{
		[[self session] stopRunning];
		
		[[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVCaptureDeviceSubjectAreaDidChangeNotification
                                                      object:[[self videoDeviceInput] device]];
        
		[[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
		
		[self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized"
                     context:SessionRunningAndDeviceAuthorizedContext];
        
		[self removeObserver:self forKeyPath:@"stillImageOutput.capturingStillImage"
                     context:CapturingStillImageContext];
        
        [self removeObserver:self forKeyPath:@"torchMode"
                     context:CameraTorchModeObservationContext];

	});
#endif

}


- (void)moveLine:(UIPanGestureRecognizer *)gesture
{
    [self.tip6ImageView setHidden:YES];
    [self.tip6Close setHidden:YES];
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"tip7Name"] isEqualToString:@"passed"]) {
        [self.tip7ImageView setHidden:YES];
        [self.tip7Close setHidden:YES];
        [self viewTip8];
    }else{
        [self viewTip7];
    }
//    [self.tip7ImageView setHidden:YES];
//    [self.tip7Close setHidden:YES];
    // Get the touch object.
    UIView *view = gesture.view;
    CGPoint point = [gesture locationInView:view.superview];
    
    if(gesture.state == UIGestureRecognizerStateChanged) {
        
        // Move the view base on user move the finger
        CGFloat newPosY = view.center.y + point.y - self.priorPoint.y;
        
        view.center = CGPointMake(view.center.x, newPosY);
    }
    
    self.priorPoint = point;
}


- (void)moveStencil:(UIPanGestureRecognizer *)gesture
{
    // Get the touch object.
    UIView *view = gesture.view;
    CGPoint point = [gesture locationInView:view.superview];
    
    if(gesture.state == UIGestureRecognizerStateChanged) {
        
        // Move the view base on user move the finger
        CGFloat newPosX = view.center.x + point.x - self.priorPoint.x;
        CGFloat newPosY = view.center.y + point.y - self.priorPoint.y;

        view.center = CGPointMake(newPosX, newPosY);
        
        // Moving the line sticked line with the stencil
        UIImageView *stickedLine;
        if (view == self.faceStencilImageView) {
            stickedLine = self.faceLineImageView;
        }
        else {
            stickedLine = self.bellyBumpLineImageView;
        }
        stickedLine.center = CGPointMake(stickedLine.center.x, stickedLine.center.y + point.y - self.priorPoint.y);
    }
    
    self.priorPoint = point;
}


- (void)initLocalVarialble;
{
    self.takePhotoFlag = NO;
    self.showPreviousPhotoFlag = YES;
    self.showCameraGrid = NO;
    self.faceDetectEnable = NO;
    self.currentGuide = BEBDetectFaceSimilarNone;
}

// Enable the showPreviousImageButton and show the previous button if exist
- (void)displayPreviousImage;
{
    
    if (!self.previousPhoto) {
        self.showPreviousImageButton.enabled = NO;
        self.transparenceOverlaySlider.hidden = YES;
    }
}

#pragma mark: Stencil helper
- (void)removeGuideStencil;
{
    [self.faceStencilImageView removeFromSuperview];
    [self.faceLineImageView removeFromSuperview];
    [self.bellBumpStencilImageView removeFromSuperview];
    [self.bellyBumpLineImageView removeFromSuperview];
}

- (void)show180DegreeGuideView;
{

    if (self.story.storyType == StoryType180Degree) {
        
        NSInteger imagePerWeek = 0;
        
        switch (self.story.frequence) {
            case FrequencyTypeDaily:
                imagePerWeek = 7;
                break;
            case FrequencyTypeBiweekly:
                imagePerWeek = 2;
                break;
            case FrequencyTypeWeekly:
                imagePerWeek = 1;
            default:
                break;
        }
        
        self.guideWeekLabel.hidden = NO;
        self.guideAngleLabel.hidden = NO;
        
        // Just show the arrow when user take next image
        if (self.story.photos.count > 0) {
            self.leftArrow180ImageView.hidden = NO;
        }
        
        // Calculator degree of week
        if (self.story.isPregnancy) {
            NSTimeInterval timeInterval = [self.story.birthDate timeIntervalSinceNow];
            NSInteger numberOfWeek = (int)(timeInterval/(dayTime * 7.0f));
            NSInteger remainWeek = 40 - numberOfWeek;
            if (remainWeek < 0) remainWeek = 0;
            
            self.guideWeekLabel.text = [NSString stringWithFormat:@"  week %ld     ", (long)remainWeek];
            
            // Total number of story
            NSTimeInterval totalTimeInterval = [self.story.birthDate timeIntervalSinceDate:self.story.startDate];

            NSInteger totalNumberOfImage = (int)((totalTimeInterval * imagePerWeek)/( dayTime * 7.0f));
            NSInteger currentImageNumber = (int)((timeInterval * imagePerWeek)/(dayTime * 7.0f));
            
            if (currentImageNumber > totalNumberOfImage) {
                currentImageNumber = totalNumberOfImage;
            }
            if (totalNumberOfImage == 0) {
                totalNumberOfImage = 1;
            }
            self.guideAngleLabel.text = [NSString stringWithFormat:@"  %ld\u00B0 angle     ", 180 - (long)(180 * currentImageNumber / totalNumberOfImage)];

        }
        else {
            
            NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.story.startDate];
            if (timeInterval < 0) {
                timeInterval = 0;
            }
            
            NSInteger currentWeek = (int)((timeInterval * imagePerWeek)/(dayTime * 7.0f));
            self.guideWeekLabel.text = [NSString stringWithFormat:@"  week %ld     ", (long)currentWeek];
            
            NSTimeInterval totalTimeInterval = 365 * dayTime;  // 1Year

            NSInteger totalNumberOfImage = (int)((totalTimeInterval * imagePerWeek)/(dayTime * 7.0f));
            NSInteger currentImageNumber = (int)((timeInterval * imagePerWeek)/(dayTime * 7.0f));
            
            if (currentImageNumber > totalNumberOfImage) {
                currentImageNumber = totalNumberOfImage;
            }
            if (totalNumberOfImage == 0) {
                totalNumberOfImage = 1;
            }
            self.guideAngleLabel.text = [NSString stringWithFormat:@"  %ld\u00B0 angle     ", (long)(180 * currentImageNumber / totalNumberOfImage)];
        }
    }
}

- (void)addGuideStencil;
{
    [self addFaceStencilView];
    
    [self addBellyBumpStencilView];
    
    [self.view bringSubviewToFront:self.bottomView];
    [self.view bringSubviewToFront:self.topView];
    
}

- (void)addFaceStencilView;
{
    [self addFaceCircleView];
    
    [self addEyeLineView];
}

- (void)addFaceCircleView;
{
    // Add view for face stencil
    if ([self faceStencilImage]) {
        
        UIImage *image = [self faceStencilImage];
        
        self.faceStencilImageView = [[UIImageView alloc] initWithImage:image];
        
        if (self.story.storyType != StoryType180Degree) {
            CGPoint faceCenter = [self faceCenter];
            self.faceStencilImageView.center = faceCenter;
            
            // Keep the rect for align with stencil facing
            self.faceRect = CGRectMake(faceCenter.x - image.size.width/2,
                                       faceCenter.y - image.size.height/2,
                                       image.size.width,
                                       image.size.height);
            
            self.faceDetectEnable = YES;
            
            [self.viewTest addSubview:self.faceStencilImageView];
            
            // Adding single tap for user out of the edit mode
//0425            if (self.firstImage)
            {
                [self.faceStencilImageView setUserInteractionEnabled:YES];
                [self.faceStencilImageView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                                        action:@selector(moveStencil:)]];
            }
        }
        else {
            CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);

            CGPoint faceCenter = [self point:[self faceCenter]
                                  scaleValue:1];
            self.faceStencilImageView.center = CGPointMake(width/2,faceCenter.y);
            [self.viewTest addSubview:self.faceStencilImageView];
            
            // Adding single tap for user out of the edit mode
//0425            if (self.firstImage)
            {
                [self.faceStencilImageView setUserInteractionEnabled:YES];
                [self.faceStencilImageView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                                     action:@selector(moveLine:)]];
            }
        }
 
    }
}

- (void)addEyeLineView;
{
    if ([self eyeLineImage]) {
        CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
        
        UIImage *image = [self eyeLineImage];

        // Add line for face stencil
        self.faceLineImageView = [[UIImageView alloc] initWithImage:image];
        self.faceLineImageView.center = CGPointMake(width/2,[self eyeLinePositionY]);
        [self.viewTest addSubview:self.faceLineImageView];
        
        // Adding single tap for user out of the edit mode
        if (self.firstImage && self.story.storyType == StoryType180Degree){
            [self.faceLineImageView setUserInteractionEnabled:YES];
            [self.faceLineImageView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                                    action:@selector(moveLine:)]];
        }
    }
}

- (void)addBellyBumpStencilView;
{
    [self addBellyBumpCircleView];
    
    [self addBellyBumpLineView];
}

- (void)addBellyBumpCircleView;
{
    // Add view for belly bump stencil
    if ([self bellyBumpStencilImage]) {
        UIImage *image = [self bellyBumpStencilImage];
        
        self.bellBumpStencilImageView = [[UIImageView alloc] initWithImage:image];
        
        self.bellBumpStencilImageView.center = [self point:[self bellyBumpCenter]
                                                scaleValue:1];
        ;
        [self.viewTest addSubview:self.bellBumpStencilImageView];
        
        
        // Adding single tap for user out of the edit mode
//0425        if (self.firstImage)
        {
            UIPanGestureRecognizer *panGestureRecognize1 = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                                   action:@selector(moveStencil:)];
            [self.bellBumpStencilImageView setUserInteractionEnabled:YES];
            [self.bellBumpStencilImageView addGestureRecognizer:panGestureRecognize1];
        }
    }
}

- (void)addBellyBumpLineView;
{
    if ([self bellyBumpLineImage]) {
        CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
        
        // Add line for belly bump
        UIImage *image = [self bellyBumpLineImage];

        self.bellyBumpLineImageView = [[UIImageView alloc] initWithImage:image];
        self.bellyBumpLineImageView.center = CGPointMake(width/2, [self bellyBumpLinePositionY]);
        [self.viewTest addSubview:self.bellyBumpLineImageView];
        
        // Adding single tap for user out of the edit mode
        if (self.firstImage && self.story.storyType == StoryType180Degree){
            [self.bellyBumpLineImageView setUserInteractionEnabled:YES];
            [self.bellyBumpLineImageView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                                 action:@selector(moveLine:)]];
        }
    }
}

- (UIImage *)faceStencilImage
{
    // For MOM
    if (self.story.isPregnancy) {
        switch (self.story.storyType) {
            case StoryTypeFullShot:
                if (IS_IPHONE_6) {
                    return [UIImage imageNamed: @"fullshot_mom_face_stencial_ip6"];
                }
                return [UIImage imageNamed: @"fullshot_mom_face_stencial"];
            case StoryTypeMediumShot:
                if (IS_IPHONE_6) {
                    return [UIImage imageNamed: @"mediumshot_mom_face_stencial_ip6"];
                }
                return [UIImage imageNamed:@"mediumshot_mom_face_stencial"];
            case StoryTypeDetailShot:
                if (IS_IPHONE_6) {
                    return [UIImage imageNamed: @"selfie_mom_face_stencial_ip6"];
                }
                return [UIImage imageNamed:@"selfie_mom_face_stencial"];

            case StoryType180Degree:
                if (IS_IPHONE_6) {
                    return [UIImage imageNamed: @"degree_mom_eye_line_ip6"];
                }
                return [UIImage imageNamed:@"degree_mom_eye_line"];
        }
    }
    else {
        
        // For KID
        switch (self.story.storyType) {
            case StoryTypeFullShot:
                if (IS_IPHONE_6) {
                    return [UIImage imageNamed: @"fullshot_kid_face_stencial_ip6"];
                }
                return [UIImage imageNamed:@"fullshot_kid_face_stencial"];
            case StoryTypeMediumShot:
                if (IS_IPHONE_6) {
                    return [UIImage imageNamed: @"mediumshot_kid_face_stencial_ip6"];
                }
                return [UIImage imageNamed:@"mediumshot_kid_face_stencial"];
            case StoryTypeDetailShot:
                return nil;
            case StoryType180Degree:
                return nil;
        }
    }
}

- (CGPoint)faceCenter;
{
    // For MOM
    if (!CGPointEqualToPoint(self.story.faceCenter, CGPointMake(0, 0))) {
        return self.story.faceCenter;
    }
    
    if (self.story.isPregnancy) {
        switch (self.story.storyType) {
            case StoryTypeFullShot:
                return CGPointMake(168 * [self scaleScreenValue], 45 * [self scaleScreenValue]);
            case StoryTypeMediumShot:
                return CGPointMake(204 * [self scaleScreenValue], 88 * [self scaleScreenValue]);
            case StoryTypeDetailShot:
                return CGPointMake(76 * [self scaleScreenValue], 96 * [self scaleScreenValue]);
            case StoryType180Degree:
                return CGPointMake(168 * [self scaleScreenValue], 132 * [self scaleScreenValue]);
        }
    }
    else {
        
        // For KID
        switch (self.story.storyType) {
            case StoryTypeFullShot:
                return CGPointMake(115 * [self scaleScreenValue], 124 * [self scaleScreenValue]);
            case StoryTypeMediumShot:
                return CGPointMake(157 * [self scaleScreenValue], 155 * [self scaleScreenValue]);
            case StoryTypeDetailShot:
                return CGPointMake(0, 0);
            case StoryType180Degree:
                return CGPointMake(0, 0);
        }
    }
}

- (UIImage *)eyeLineImage
{
    
    // For MOM
    if (self.story.isPregnancy) {
        switch (self.story.storyType) {
            case StoryTypeFullShot:
                if (IS_IPHONE_6) {
                    return [UIImage imageNamed: @"fullshot_mom_eye_line_ip6"];
                }
                return [UIImage imageNamed:@"fullshot_mom_eye_line"];
            case StoryTypeMediumShot:
                if (IS_IPHONE_6) {
                    return [UIImage imageNamed: @"mediumshot_mom_eye_line_ip6"];
                }
                return [UIImage imageNamed:@"mediumshot_mom_eye_line"];
            case StoryTypeDetailShot:
                if (IS_IPHONE_6) {
                    return [UIImage imageNamed: @"selfie_mom_eye_line_ip6"];
                }
                return [UIImage imageNamed:@"selfie_mom_eye_line"];
            case StoryType180Degree:
                return nil;
        }
    }
    else {
        
        // For KID
        switch (self.story.storyType) {
            case StoryTypeFullShot:
                if (IS_IPHONE_6) {
                    return [UIImage imageNamed: @"fullshot_kid_eye_line_ip6"];
                }
                return [UIImage imageNamed:@"fullshot_kid_eye_line"];
            case StoryTypeMediumShot:
                if (IS_IPHONE_6) {
                    return [UIImage imageNamed: @"mediumshot_kid_eye_line_ip6"];
                }
                return [UIImage imageNamed:@"mediumshot_kid_eye_line"];
            case StoryTypeDetailShot:
                return nil;
            case StoryType180Degree:
                if (IS_IPHONE_6) {
                    return [UIImage imageNamed: @"degree_kid_eye_line_ip6"];
                }
                return [UIImage imageNamed:@"degree_kid_eye_line"];
        }
    }
}

- (NSUInteger)eyeLinePositionY;
{
    // For MOM
    if (self.story.eyeLinePositionY != 0) {
        return self.story.eyeLinePositionY;
    }
    
    if (self.story.isPregnancy) {
        switch (self.story.storyType) {
            case StoryTypeFullShot:
                return 53 * [self scaleScreenValue];
            case StoryTypeMediumShot:
                return 82 * [self scaleScreenValue];
            case StoryTypeDetailShot:
                return 100 * [self scaleScreenValue];
            case StoryType180Degree:
                return 175 * [self scaleScreenValue];
        }
    }
    else {
        
        // For KID
        switch (self.story.storyType) {
            case StoryTypeFullShot:
                return 103;
            case StoryTypeMediumShot:
                return 135;
            case StoryTypeDetailShot:
                return 0;
            case StoryType180Degree:
                return 190;
        }
    }
}

- (UIImage *)bellyBumpStencilImage
{

    // For MOM
    if (self.story.isPregnancy) {
        switch (self.story.storyType) {
            case StoryTypeFullShot:
                if (IS_IPHONE_6) {
                    return [UIImage imageNamed: @"fullshot_mom_bellybump_stencial_ip6"];
                }
                return [UIImage imageNamed:@"fullshot_mom_bellybump_stencial"];
            case StoryTypeMediumShot:
                if (IS_IPHONE_6) {
                    return [UIImage imageNamed: @"mediumshot_mom_bellybump_stencial_ip6"];
                }
                return [UIImage imageNamed:@"mediumshot_mom_bellybump_stencial"];
            case StoryTypeDetailShot:
                if (IS_IPHONE_6) {
                    return [UIImage imageNamed: @"selfie_mom_bellybump_stencial_ip6"];
                }

                return [UIImage imageNamed:@"selfie_mom_bellybump_stencial"];
            case StoryType180Degree:
                return nil;
        }
    }
    else {
        // For KID
        switch (self.story.storyType) {
            case StoryTypeFullShot:
                if (IS_IPHONE_6) {
                    return [UIImage imageNamed: @"fullshot_kid_bellybump_stencial_ip6"];
                }
                return [UIImage imageNamed:@"fullshot_kid_bellybump_stencial"];
            case StoryTypeMediumShot:
                return nil;
            case StoryTypeDetailShot:
                return nil;
            case StoryType180Degree:
                return nil;
        }
    }
}

- (CGPoint)bellyBumpCenter;
{
    
    if (!CGPointEqualToPoint(self.story.bellyBumpCenter, CGPointMake(0, 0))) {
        return self.story.bellyBumpCenter;
    }
    
    // For MOM
    if (self.story.isPregnancy) {
        switch (self.story.storyType) {
            case StoryTypeFullShot:
                return CGPointMake(230 * [self scaleScreenValue], 166 * [self scaleScreenValue]);
            case StoryTypeMediumShot:
                return CGPointMake(162 * [self scaleScreenValue], 325 * [self scaleScreenValue]);
            case StoryTypeDetailShot:
                return CGPointMake(224 * [self scaleScreenValue], 318 * [self scaleScreenValue]);
            case StoryType180Degree:
                return CGPointMake(0, 0);
        }
    }
    else {
        
        // For KID
        switch (self.story.storyType) {
            case StoryTypeFullShot:
                return CGPointMake(151* [self scaleScreenValue], 268* [self scaleScreenValue]);
            case StoryTypeMediumShot:
                return CGPointMake(0, 0);
            case StoryTypeDetailShot:
                return CGPointMake(0, 0);
            case StoryType180Degree:
                return CGPointMake(0, 0);
        }
    }
}

- (UIImage *)bellyBumpLineImage
{
    // For MOM
    if (self.story.isPregnancy) {
        switch (self.story.storyType) {
            case StoryTypeFullShot:
                if (IS_IPHONE_6) {
                    return [UIImage imageNamed: @"fullshot_mom_bellybump_line_ip6"];
                }
                return [UIImage imageNamed:@"fullshot_mom_bellybump_line"];
            case StoryTypeMediumShot:
            case StoryTypeDetailShot:
                return nil;
            case StoryType180Degree:
                if (IS_IPHONE_6) {
                    return [UIImage imageNamed: @"degree_mom_bellybump_line_ip6"];
                }
                return [UIImage imageNamed:@"degree_mom_bellybump_line"];
                return nil;
        }
    }
    else {
        
        // For KID
        switch (self.story.storyType) {
            case StoryTypeFullShot:
                if (IS_IPHONE_6) {
                    return [UIImage imageNamed: @"fullshot_kid_bellybump_line_ip6"];
                }
                return [UIImage imageNamed:@"fullshot_kid_bellybump_line"];
            case StoryTypeMediumShot:
                return nil;
            case StoryTypeDetailShot:
                return nil;
            case StoryType180Degree:
                if (IS_IPHONE_6) {
                    return [UIImage imageNamed: @"degree_kid_mouth_line_ip6"];
                }
                return [UIImage imageNamed:@"degree_kid_mouth_line"];
        }
    }
}

- (NSUInteger)bellyBumpLinePositionY;
{
    if (self.story.bellyBumpLinePositionY != 0) {
        return self.story.bellyBumpLinePositionY;
    }
    
    // For MOM
    if (self.story.isPregnancy) {
        switch (self.story.storyType) {
            case StoryTypeFullShot:
                return 134 * [self scaleScreenValue];
            case StoryTypeMediumShot:
                return 239 * [self scaleScreenValue];
            case StoryTypeDetailShot:
                return 0;
            case StoryType180Degree:
                return 278 * [self scaleScreenValue];
        }
    }
    else {
        
        // For KID
        switch (self.story.storyType) {
            case StoryTypeFullShot:
                return 284 * [self scaleScreenValue];
            case StoryTypeMediumShot:
                return 0;
            case StoryTypeDetailShot:
                return 0;
            case StoryType180Degree:
                return 270 * [self scaleScreenValue];
        }
    }
}

- (CGFloat)scaleScreenValue;
{
    // It belong to the size of the stencil image with the size of screen
//    if (IS_IPHONE_6PLUS) {
//        return 414.0f/320.0f;
//    }
//    else if (IS_IPHONE_6) {
//        return 375.0f/320.0f;
//    }
//    else {
//        return 1.0f;
//    }
    return 1.0f;
}


- (CGPoint)point:(CGPoint)point scaleValue:(CGFloat)scale {
    return CGPointMake(point.x * scale, point.y * scale);
}

- (void)cropPreviousImageToCurrentView;
{
    // Crop and scale the previous as the current image view frame
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if(screenSize.height > screenSize.width){
        screenSize.height = screenSize.width;
    }else{
        screenSize.width = screenSize.height;
    }
    
    float scaleX = screenSize.width/self.previousPhoto.size.width;
    
    // Scale the image extractly the size of preview view
    self.previousPhoto = [BEBUtilities scaleImage:self.previousPhoto scaleFactor:scaleX];
//    self.previousPhoto:CGR
    
    // Setting image for view
    if ((self.story.storyType == StoryTypeDetailShot && self.story.isPregnancy)||
        (self.story.storyType == StoryType180Degree && self.story.isPregnancy)) {
        
//        UIImage* flippedImage = [UIImage imageWithCGImage:self.previousPhoto.CGImage
//                                                    scale:self.previousPhoto.scale
//                                              orientation:UIImageOrientationUpMirrored];
        self.previousPhotoView.image = self.previousPhoto;
    }
    else {
        
        self.previousPhotoView.image = self.previousPhoto;
    }
    
    self.previousPhotoView.contentMode = UIViewContentModeCenter;
    self.showPreviousImageButton.alpha = 0.7f;
    self.transparenceOverlaySlider.hidden = NO;

}

- (void)configureTransparenceOverlaySlider;
{
    // Configure the apperance for slider
    UIImage *maximumTrackImage = [[UIImage imageNamed:@"img_overlay_slider_min"]
                                  resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    
    [self.transparenceOverlaySlider setMaximumTrackImage:maximumTrackImage
                                  forState:UIControlStateNormal];
    
    UIImage *minimumTrackImage = [[UIImage imageNamed:@"img_overlay_slider_min"]
                                  resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    
    [self.transparenceOverlaySlider setMinimumTrackImage:minimumTrackImage
                                  forState:UIControlStateNormal];
    
    [self.transparenceOverlaySlider setThumbImage:[UIImage imageNamed:@"img_video_slider_thumb"]
                           forState:UIControlStateNormal];
    
    // Setup volume slider
    [self.transparenceOverlaySlider setMaximumTrackImage:maximumTrackImage
                                   forState:UIControlStateNormal];
    
    [self.transparenceOverlaySlider setMinimumTrackImage:minimumTrackImage
                                   forState:UIControlStateNormal];
    
    [self.transparenceOverlaySlider setThumbImage:[UIImage imageNamed:@"img_video_slider_thumb"]
                            forState:UIControlStateNormal];
}

- (BOOL)prefersStatusBarHidden
{
	return YES;
}

- (BOOL)shouldAutorotate
{
	// Disable autorotation of the interface when recording is in progress.
	return ![self lockInterfaceRotation];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskPortrait;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
	[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection]
     setVideoOrientation:(AVCaptureVideoOrientation)toInterfaceOrientation];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
	if (context == CapturingStillImageContext) {
        
		BOOL isCapturingStillImage = [change[NSKeyValueChangeNewKey] boolValue];
		
		if (isCapturingStillImage) {
			[self runStillImageCaptureAnimation];
		}
	}
	else if (context == SessionRunningAndDeviceAuthorizedContext) {
        
		BOOL isRunning = [change[NSKeyValueChangeNewKey] boolValue];
		
		dispatch_async(dispatch_get_main_queue(), ^{
            
			if (isRunning) {
                
				[[self switchCameraButton] setEnabled:YES];
				[[self captureButton] setEnabled:YES];
                [[self flashButton] setEnabled:YES];
			}
			else {
                
				[[self switchCameraButton] setEnabled:NO];
				[[self captureButton] setEnabled:NO];
                [[self flashButton] setEnabled:NO];
			}
		});
	}
    else if (context == CameraTorchModeObservationContext) {
        
        [self updateFlashButtonByTochMode:(AVCaptureTorchMode)[change[@"new"] intValue]];
    }
    else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}


#pragma mark Actions

- (IBAction)gridCameraButtonClick:(id)sender;
{
    [[NSUserDefaults standardUserDefaults] setObject:@"passed" forKey:@"tip8Name"];
    [self.tip8ImageView setHidden:YES];
    [self.tip8Close setHidden:YES];
    
    self.showCameraGrid = !self.showCameraGrid;
    
    if (self.showCameraGrid) {
        self.gridPhotoView.image = [UIImage imageNamed:@"grid_camera"];
        self.gridCameraButton.alpha = 0.7f;
    }
    else {
        self.gridPhotoView.image = nil;
        self.gridCameraButton.alpha = 1.0f;

    }
}

// Change camera back-front
- (IBAction)switchCameraButtonClick:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:@"passed" forKey:@"tip9Name"];
    [self.tip9ImageView setHidden:YES];
    [self.tip9Close setHidden:YES];
    
    if (self.story.storyType == StoryType180Degree) {
        // If capture image as 180 degree, allow use switch camera without asking anything.
        [self switchCamera];
    }
    else {
        
        // Show Aler keep the same camera angle
        [self showAlertView];
    }
}

- (void)showAlertView;
{
    if (iOS_Version < kiOSVersion8) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reminder"
                                                        message:@"Remember to always use the same camera angle "
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Ok",nil];
        [alert show];
    }
    else {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Reminder"
                                     message:@"Remember to always use the same camera angle "
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [self switchCamera];
                             }];
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                 }];
        
        [alert addAction:ok];
        [alert addAction:cancel];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)switchCamera;
{
    [[self switchCameraButton] setEnabled:NO];
    [[self captureButton] setEnabled:NO];
    [[self flashButton] setEnabled:NO];
    
    dispatch_async([self sessionQueue], ^{
        AVCaptureDevice *currentVideoDevice = [[self videoDeviceInput] device];
        AVCaptureDevicePosition preferredPosition = AVCaptureDevicePositionUnspecified;
        AVCaptureDevicePosition currentPosition = [currentVideoDevice position];
        
        switch (currentPosition) {
            case AVCaptureDevicePositionUnspecified:
                preferredPosition = AVCaptureDevicePositionBack;
                break;
            case AVCaptureDevicePositionBack:
                preferredPosition = AVCaptureDevicePositionFront;
                break;
            case AVCaptureDevicePositionFront:
                preferredPosition = AVCaptureDevicePositionBack;
                break;
        }
        
        AVCaptureDevice *videoDevice = [BEBCamViewController deviceWithMediaType:AVMediaTypeVideo
                                                              preferringPosition:preferredPosition];
        
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice
                                                                                       error:nil];
        
        [[self session] beginConfiguration];
        
        [[self session] removeInput:[self videoDeviceInput]];
        
        if (!videoDeviceInput) {
            NSLog(@"Fail");
            return;
            
        }
        if ([[self session] canAddInput:videoDeviceInput]) {
            
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:AVCaptureDeviceSubjectAreaDidChangeNotification
                                                          object:currentVideoDevice];
            
            [BEBCamViewController setFlashMode:AVCaptureFlashModeAuto
                                     forDevice:videoDevice];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(subjectAreaDidChange:)
                                                         name:AVCaptureDeviceSubjectAreaDidChangeNotification
                                                       object:videoDevice];
            
            [[self session] addInput:videoDeviceInput];
            [self setVideoDeviceInput:videoDeviceInput];
        }
        else {
            
            [[self session] addInput:[self videoDeviceInput]];
        }
        
        [[self session] commitConfiguration];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[self switchCameraButton] setEnabled:YES];
            [[self captureButton] setEnabled:YES];
            
            // If the camera is the main camera, enable the flash, if not, disable this function.
            if (preferredPosition == AVCaptureDevicePositionBack) {
                [[self flashButton] setEnabled:YES];
                self.flashButton.alpha = 1.0f;
                
                if (self.showPreviousPhotoFlag) {
                    self.previousPhotoView.image = self.previousPhoto;
                }
                self.isUsingFrontFacingCamera = NO;
                
                // Change the stencial
                if (self.story.storyType == StoryTypeDetailShot) {
                    self.story.storyType = StoryTypeMediumShot;
                }
                
                [self removeGuideStencil];
                [self addGuideStencil];
                
            }
            else {
                
                [self.flashButton setImage:[UIImage imageNamed:@"SwitchFlash_off"]
                                  forState:UIControlStateNormal];
                
                // Flip horizontal the previous if had.
                if (self.showPreviousPhotoFlag) {
                    
//                    UIImage* flippedImage = [UIImage imageWithCGImage:self.previousPhoto.CGImage
//                                                                scale:self.previousPhoto.scale
//                                                          orientation:UIImageOrientationUpMirrored];
                    self.previousPhotoView.image = self.previousPhoto;
                }
                self.flashButton.alpha = 0.7f;
                self.isUsingFrontFacingCamera = YES;
                
                // Change the stencial
                if (self.story.storyType != StoryType180Degree) {
                    self.story.storyType = StoryTypeDetailShot;
                }
                
                [self removeGuideStencil];
                [self addGuideStencil];
            }
        });
    });
}

#pragma mark -
#pragma mark - ** UIAlertViewDelegate methods **
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if (buttonIndex == 1) {
        [self switchCamera];
    }
}


// Change the status of the Flash Mode (On-Off-Auto)
- (IBAction)changeFlashButtonClick:(id)sender;
{
    switch (self.torchMode) {
        case AVCaptureTorchModeOff:
        {
            self.torchMode = AVCaptureTorchModeOn;
            UIImage *img = [UIImage imageNamed:@"SwitchFlash_on"];
            [self.bttFlashOnOff setImage:img forState:UIControlStateNormal];
        }
            break;
            
        case AVCaptureTorchModeOn:
        {
            self.torchMode = AVCaptureTorchModeAuto;
            UIImage *img1 = [UIImage imageNamed:@"SwitchFlash_auto"];
            [self.bttFlashOnOff setImage:img1 forState:UIControlStateNormal];
        }
            break;
            
        case AVCaptureTorchModeAuto:
        {
            self.torchMode = AVCaptureTorchModeOff;
            UIImage *img2 = [UIImage imageNamed:@"SwitchFlash_off"];
            [self.bttFlashOnOff setImage:img2 forState:UIControlStateNormal];
        }
            break;
            
        default:
            break;
    }
}

// Take the photo from camera
- (IBAction)captureImageButtonClick:(id)sender
{
    // Set flag for take photo value 
    self.takePhotoFlag = true;
    [self.videoDataOutput setSampleBufferDelegate:nil queue:nil];

	dispatch_async([self sessionQueue], ^{
        
		// Update the orientation on the still image output video connection before capturing.
		[[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] videoOrientation]];
		
		// Flash set to Auto for Still Capture
		[BEBCamViewController setFlashMode:(AVCaptureFlashMode)self.torchMode forDevice:[[self videoDeviceInput] device]];
		
		// Capture a still image.
		[[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
			
            // Get the image from buffer
			if (imageDataSampleBuffer) {
                
				NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
				self.image = [[UIImage alloc] initWithData:imageData];
                
                self.image = [BEBUtilities fixedRotation:self.image];
                CGFloat aaa = self.image.size.height;
                CGFloat aaa1 = self.image.size.width;

                AVCaptureDevice *currentVideoDevice = [[self videoDeviceInput] device];
                AVCaptureDevicePosition currentPosition = [currentVideoDevice position];
                
                if (currentPosition == AVCaptureDevicePositionFront) {
                    self.image = [UIImage imageWithCGImage:self.image.CGImage
                                                     scale: 1
                                               orientation:UIImageOrientationUpMirrored];
                    
                }

                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [self doneButtonClick:nil];
                });
            }
		}];
	});
}

- (IBAction)showPreviousButtonClick:(id)sender {
    NSLog(@"showPreviousButtonClick");
    // If still not take the photo: turn on/off the Previuos image of story.
    
    // Change the value of the button show previous
    self.showPreviousPhotoFlag = !self.showPreviousPhotoFlag;
    
    // Update the UI for the button.
    if (self.showPreviousPhotoFlag) {
        
        self.showPreviousImageButton.alpha = 0.7f;
        self.transparenceOverlaySlider.hidden = NO;
        
        AVCaptureDevice *currentVideoDevice = [[self videoDeviceInput] device];
        AVCaptureDevicePosition currentPosition = [currentVideoDevice position];
        
        switch (currentPosition) {
            case AVCaptureDevicePositionBack:
                self.previousPhotoView.image = self.previousPhoto;
                break;
            case AVCaptureDevicePositionUnspecified:
            case AVCaptureDevicePositionFront:
            {
//                UIImage* flippedImage = [UIImage imageWithCGImage:self.previousPhoto.CGImage
//                                                            scale:self.previousPhoto.scale
//                                                      orientation:UIImageOrientationUpMirrored];
                self.previousPhotoView.image = self.previousPhoto;

            }
                break;
        }
    }
    else {
        
        self.showPreviousImageButton.alpha = 1.0f;
        self.previousPhotoView.image = nil;
        
        self.transparenceOverlaySlider.hidden = YES;
    }
}

- (IBAction)doneButtonClick:(id)sender;
{
    // When user take the photo already, change previous to Done button.
    if (self.firstImage) {
    
        // Save the stencil position
        [self saveStencilPosition];
        
    }
    // Make the delegate pull the image out.
    if ([self.delegate respondsToSelector:@selector(bebCamViewController:finishedWithImage:)]) {
        
        [self.delegate bebCamViewController:self
                          finishedWithImage:self.image];
    }
    
    // Close the capture image view
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)closeButtonClick:(id)sender;
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)transparenceOverlaySliderValueChanged:(id)sender;
{
    self.previousPhotoView.alpha = self.transparenceOverlaySlider.value;
}

- (IBAction)guideButtonClick:(id)sender;
{
    NSLog(@"guideButtonClick");
}

- (IBAction)tip6ButtonClick:(id)sender {
    [self.tip6Close setHidden:YES];
    [self.tip6ImageView setHidden:YES];
    [[NSUserDefaults standardUserDefaults] setObject:@"passed" forKey:@"tip6Name"];
    [self viewTip7];
}

- (IBAction)tip7ButtonClick:(id)sender {
    [self.tip7Close setHidden:YES];
    [self.tip7ImageView setHidden:YES];
    [[NSUserDefaults standardUserDefaults] setObject:@"passed" forKey:@"tip7Name"];
    [self viewTip8];
}

- (IBAction)tip8ButtonClick:(id)sender {
    [self.tip8Close setHidden:YES];
    [self.tip8ImageView setHidden:YES];
    [[NSUserDefaults standardUserDefaults] setObject:@"passed" forKey:@"tip8Name"];
    [self viewTip9];
}


- (void)saveStencilPosition
{
    // Save the position of stencil to data
    
    self.story.faceCenter = self.faceStencilImageView.center;
    self.story.eyeLinePositionY = self.faceLineImageView.center.y;
    
    self.story.bellyBumpCenter = self.bellBumpStencilImageView.center;
    self.story.bellyBumpLinePositionY = self.bellyBumpLineImageView.center.y;
    
    BEBDataManager *dataManager = [BEBDataManager sharedManager];
    int count = 0;
    for (BEBStory *story in dataManager.stories) {
        
        if (story.title == self.story.title &&
            [story.startDate isEqualToDate:self.story.startDate]) {
            break;
        }
        count++;
    }
    
    if (count < dataManager.stories.count) {
        [dataManager.stories replaceObjectAtIndex:count withObject:self.story];
    }
}

#pragma mark Helper method

- (void)overlayTopAndBottomHidden:(BOOL)value;
{
    [UIView animateWithDuration:0.2 animations:^{
        
        // Set the height of top and bottom layout to zero to make the close effect.
        self.constraintTopViewHeight.constant = value?0:topViewHeight;
        self.constraintBottomViewHeight.constant = value?0:bottomViewHeight;

        // Call layoutIfNeeded method to show the animation
        [self.topView layoutIfNeeded];
        [self.subBottomView layoutIfNeeded];
    }];
}

#pragma mark File Output Delegate

- (IBAction)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer
{
    
#if TARGET_IPHONE_SIMULATOR
    
#else
	CGPoint devicePoint = [(AVCaptureVideoPreviewLayer *)[[self previewView] layer]
                           captureDevicePointOfInterestForPoint:[gestureRecognizer locationInView:[gestureRecognizer view]]];
    
	[self focusWithMode:AVCaptureFocusModeAutoFocus
         exposeWithMode:AVCaptureExposureModeAutoExpose
          atDevicePoint:devicePoint
monitorSubjectAreaChange:YES];
#endif

}

- (void)subjectAreaDidChange:(NSNotification *)notification
{
	CGPoint devicePoint = CGPointMake(.5, .5);
    
	[self focusWithMode:AVCaptureFocusModeContinuousAutoFocus
         exposeWithMode:AVCaptureExposureModeContinuousAutoExposure
          atDevicePoint:devicePoint
monitorSubjectAreaChange:NO];
    
}
#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    
    // Only do not detect in case baby - detail capture type
    if (!self.faceDetectEnable) return;
    
    // get the image
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer
                                                      options:(__bridge NSDictionary *)attachments];
    if (attachments) {
        CFRelease(attachments);
    }
    
    // make sure your device orientation is not locked.
    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];

    // Dectect the face of realtime image
    NSDictionary *imageOptions = nil;
    imageOptions = [NSDictionary dictionaryWithObject:[self exifOrientation:curDeviceOrientation]
                                               forKey:CIDetectorImageOrientation];
    
    if (!self.faceDetector) {
        if (!self.faceDetector) {
            NSDictionary *options = [NSDictionary dictionaryWithObject:CIDetectorAccuracyLow forKey:CIDetectorAccuracy];
            self.faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:options];
        }
    }
    
    NSArray *features = [self.faceDetector featuresInImage:ciImage
                                                   options:imageOptions];
    
    if (!features || features.count == 0) {
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            // Hidden the guide face align
            self.leftGuideLabel.hidden = YES;
            self.leftGuideIcon.hidden = YES;

            if (!(IS_IPHONE_4 || IS_IPHONE_5)) {
                self.rightGuideLabel.hidden = YES;
                self.rightGuideIcon.hidden = YES;
            }

        });

        return;
    };
    
    // get the clean aperture
    // the clean aperture is a rectangle that defines the portion of the encoded pixel dimensions
    // that represents image data valid for display.
    CMFormatDescriptionRef fdesc = CMSampleBufferGetFormatDescription(sampleBuffer);
    CGRect cleanAperture = CMVideoFormatDescriptionGetCleanAperture(fdesc, false /*originIsTopLeft == false*/);
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        
        // Check the use face is similar with previous face
        [self detectSimilarFaces:features
                     forVideoBox:cleanAperture
                     orientation:curDeviceOrientation];

    });
}

#pragma mark Device Configuration

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode
        atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
    
	dispatch_async([self sessionQueue], ^{
		AVCaptureDevice *device = [[self videoDeviceInput] device];
		NSError *error = nil;
		if ([device lockForConfiguration:&error]) {
            
			if ([device isFocusPointOfInterestSupported] &&
                [device isFocusModeSupported:focusMode]) {
                
				[device setFocusMode:focusMode];
				[device setFocusPointOfInterest:point];
			}
            
			if ([device isExposurePointOfInterestSupported] &&
                [device isExposureModeSupported:exposureMode]) {
				[device setExposureMode:exposureMode];
				[device setExposurePointOfInterest:point];
			}
            
			[device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
			[device unlockForConfiguration];
		}
		else {
			NSLog(@"%@", error);
		}
	});
}

- (AVCaptureDevice *)activeCamera {
    
    return self.videoDeviceInput.device;
}

- (AVCaptureFlashMode)flashMode {
    
    return [[self activeCamera] flashMode];
}

+ (void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device
{
	if ([device hasFlash] && [device isFlashModeSupported:flashMode]) {
        
		NSError *error = nil;
		if ([device lockForConfiguration:&error]) {
            
			[device setFlashMode:flashMode];
			[device unlockForConfiguration];
		}
		else {
			NSLog(@"%@", error);
		}
	}
}

- (BOOL)cameraHasTorch {
    return [[self activeCamera] hasTorch];
}

- (AVCaptureTorchMode)torchMode {
    return [[self activeCamera] torchMode];
}

- (void)setTorchMode:(AVCaptureTorchMode)torchMode {
    AVCaptureDevice *device = [self activeCamera];
    
    if (device.torchMode != torchMode &&
        [device isTorchModeSupported:torchMode]) {
        
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            
            device.torchMode = torchMode;
            [device unlockForConfiguration];
        }
        else {
//            [self.delegate deviBEBonfigurationFailedWithError:error];
        }
    }
}


+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
	AVCaptureDevice *captureDevice = [devices firstObject];
	
	for (AVCaptureDevice *device in devices) {
		if ([device position] == position) {
			captureDevice = device;
			break;
		}
	}
	
	return captureDevice;
}

#pragma mark UI

- (void)runStillImageCaptureAnimation
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[[[self previewView] layer] setOpacity:0.0];
		[UIView animateWithDuration:.25 animations:^{
			[[[self previewView] layer] setOpacity:1.0];
		}];
	});
}

- (void)checkDeviceAuthorizationStatus
{
	NSString *mediaType = AVMediaTypeVideo;
	
	[AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
		if (granted) {
			//Granted access to mediaType
			[self setDeviceAuthorized:YES];
		}
		else {
			//Not granted access to mediaType
			dispatch_async(dispatch_get_main_queue(), ^{
                
                NSString *title = @"AVCam!";
                NSString *message = @"AVCam doesn't have permission to use Camera, please change privacy settings";
                
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
                
				[self setDeviceAuthorized:NO];
			});
		}
	}];
}

#pragma mark- update View Status

- (void)updateFlashButtonByTochMode:(AVCaptureTorchMode)touchMode {
    switch (touchMode) {
        case AVCaptureTorchModeOff:
            [self.flashButton setImage:[UIImage imageNamed:@"SwitchFlash_off"] forState:UIControlStateNormal];
            break;
            
        case AVCaptureTorchModeOn:
            [self.flashButton setImage:[UIImage imageNamed:@"SwitchFlash_on"] forState:UIControlStateNormal];
            break;
            
        case AVCaptureTorchModeAuto:
            [self.flashButton setImage:[UIImage imageNamed:@"SwitchFlash_auto"] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
}

- (UIImageOrientation)convertDeviceOrientation2ImageOrientation:(UIDeviceOrientation)deviceOrientation;
{
    switch (deviceOrientation) {
            
        case UIDeviceOrientationUnknown:
        case UIDeviceOrientationPortrait:
            return UIImageOrientationRight;
            
        case UIDeviceOrientationPortraitUpsideDown:
            return UIImageOrientationLeft;
            
        case UIDeviceOrientationLandscapeLeft:
            if (self.isUsingFrontFacingCamera)
                return UIImageOrientationDown;
            else
                return UIImageOrientationUp;
            break;
            
        case UIDeviceOrientationLandscapeRight:
            if (self.isUsingFrontFacingCamera)
                return UIImageOrientationUp;
            else
                return UIImageOrientationDown;
            break;
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
        default:
            return UIImageOrientationRight;
            break;
    }
}



- (NSNumber *) exifOrientation: (UIDeviceOrientation) orientation
{
    int exifOrientation;
    /* kCGImagePropertyOrientation values
     The intended display orientation of the image. If present, this key is a CFNumber value with the same value as defined
     by the TIFF and EXIF specifications -- see enumeration of integer constants.
     The value specified where the origin (0,0) of the image is located. If not present, a value of 1 is assumed.
     
     used when calling featuresInImage: options: The value for this key is an integer NSNumber from 1..8 as found in kCGImagePropertyOrientation.
     If present, the detection will be done based on that orientation but the coordinates in the returned features will still be based on those of the image. */
    
    enum {
        PHOTOS_EXIF_0ROW_TOP_0COL_LEFT			= 1, //   1  =  0th row is at the top, and 0th column is on the left (THE DEFAULT).
        PHOTOS_EXIF_0ROW_TOP_0COL_RIGHT			= 2, //   2  =  0th row is at the top, and 0th column is on the right.
        PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT      = 3, //   3  =  0th row is at the bottom, and 0th column is on the right.
        PHOTOS_EXIF_0ROW_BOTTOM_0COL_LEFT       = 4, //   4  =  0th row is at the bottom, and 0th column is on the left.
        PHOTOS_EXIF_0ROW_LEFT_0COL_TOP          = 5, //   5  =  0th row is on the left, and 0th column is the top.
        PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP         = 6, //   6  =  0th row is on the right, and 0th column is the top.
        PHOTOS_EXIF_0ROW_RIGHT_0COL_BOTTOM      = 7, //   7  =  0th row is on the right, and 0th column is the bottom.
        PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM       = 8  //   8  =  0th row is on the left, and 0th column is the bottom.
    };
    
    switch (orientation) {
        case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
            exifOrientation = PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM;
            break;
        case UIDeviceOrientationLandscapeLeft:       // Device oriented horizontally, home button on the right
            if (self.isUsingFrontFacingCamera)
                exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
            else
                exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
            break;
        case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
            if (self.isUsingFrontFacingCamera)
                exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
            else
                exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
            break;
        case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
        default:
            exifOrientation = PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP;
            break;
    }
    return [NSNumber numberWithInt:exifOrientation];
}

- (void)convertFaces:(NSArray *)features
       fromImageSize:(CGSize)imageSize
       toPreviewSize:(CGSize)previewSize
         orientation:(UIDeviceOrientation)orientation
{
    if (orientation == UIDeviceOrientationLandscapeLeft ||
        orientation == UIDeviceOrientationLandscapeRight) {
        
    }
        
        
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    float scaleX = screenSize.width/self.previousPhoto.size.width;
    float scaleY = screenSize.height/self.previousPhoto.size.height;
    
    self.previousPhoto = [BEBUtilities scaleImage:self.previousPhoto scaleFactor:MAX(scaleX, scaleY)];
    
}
// called asynchronously as the capture output is capturing sample buffers, this method asks the face detector
// to detect features and for each draw the green border in a layer and set appropriate orientation
- (BEBDetectFaceSimilarType)detectSimilarFaces:(NSArray *)features
                                   forVideoBox:(CGRect)clearAperture
                                   orientation:(UIDeviceOrientation)orientation
{
    
    CGSize parentFrameSize = [self.previewView frame].size;
    NSString *gravity = [((AVCaptureVideoPreviewLayer *)[[self previewView] layer]) videoGravity];
    BOOL isMirrored = [((AVCaptureVideoPreviewLayer *)[[self previewView] layer]).connection isVideoMirrored];
    CGRect previewBox = [BEBCamViewController videoPreviewBoxForGravity:gravity
                                                        frameSize:parentFrameSize
                                                     apertureSize:clearAperture.size];
    
    int i = 0;
    
    if (!features || features.count == 0) return FALSE;
    
    CIFeature *ff = [self getBiggestFaceFromDetectList:features];
//    for ( CIFaceFeature *ff in features ) {
    
    if (ff) {
        // find the correct position for the square layer within the previewLayer
        // the feature box originates in the bottom left of the video frame.
        // (Bottom right if mirroring is turned on)
        CGRect faceRect = [ff bounds];
        
        // flip preview width and height
        CGFloat temp = faceRect.size.width;
        faceRect.size.width = faceRect.size.height;
        faceRect.size.height = temp;
        temp = faceRect.origin.x;
        faceRect.origin.x = faceRect.origin.y;
        faceRect.origin.y = temp;
        
        // scale coordinates so they fit in the preview box, which may be scaled
        CGFloat widthScaleBy = previewBox.size.width / clearAperture.size.height;
        CGFloat heightScaleBy = previewBox.size.height / clearAperture.size.width;
        faceRect.size.width *= widthScaleBy;
        faceRect.size.height *= heightScaleBy;
        faceRect.origin.x *= widthScaleBy;
        faceRect.origin.y *= heightScaleBy;
        
        if ( isMirrored )
            faceRect = CGRectOffset(faceRect, previewBox.origin.x + previewBox.size.width - faceRect.size.width - (faceRect.origin.x * 2), previewBox.origin.y);
        else
            faceRect = CGRectOffset(faceRect, previewBox.origin.x, previewBox.origin.y);
        
        CGRect displayRect = CGRectMake(faceRect.origin.x + faceRect.size.height/30,
                                        faceRect.origin.y - faceRect.size.height / 4,
                                        faceRect.size.width - faceRect.size.height/15,
                                        faceRect.size.height * 1.33);

        // Set frame for the first face detect
        
        i++;
        
        // Check the similar of the current face with previous face image
        BEBDetectFaceSimilarType checkingValue = [self checkSimilarFrame:self.faceRect withFrame:displayRect];
        
        // Only change the image in case have change of similar value
        if (checkingValue!=self.currentGuide) {
            
            // Set the text base on the postion of the face detect
            
            if (checkingValue == BEBDetectFaceSimilar) {

                if (!(IS_IPHONE_4 || IS_IPHONE_5)) {
                    self.rightGuideLabel.hidden = YES;
                    self.rightGuideIcon.hidden = YES;
                }
                
                self.leftGuideLabel.hidden = YES;
                self.leftGuideIcon.hidden = YES;
                
                [self.captureButton setImage:[UIImage imageNamed:@"icon_take_photo_align"] forState:UIControlStateNormal];
            }
            else {
                [self.captureButton setImage:[UIImage imageNamed:@"icon_take_photo"] forState:UIControlStateNormal];
                [self showGuideArrowWithDirection:checkingValue];
            }
            
            [self.bottomView layoutIfNeeded];
        }
        
        // Set the value to self value.
        self.currentGuide = checkingValue;
        
        return checkingValue;
        
    }
    else {

        [self.captureButton setImage:[UIImage imageNamed:@"icon_take_photo"] forState:UIControlStateNormal];

        if (!(IS_IPHONE_4 || IS_IPHONE_5)) {
            self.rightGuideLabel.hidden = YES;
            self.rightGuideIcon.hidden = YES;
        }
        self.leftGuideLabel.hidden = YES;
        self.leftGuideIcon.hidden = YES;
    }
    
    return BEBDetectFaceSimilarNone;
}

- (BEBDetectFaceSimilarType)checkSimilarFrame:(CGRect)rect1
                                    withFrame:(CGRect)rect2
{
    
//    float radius1 = [self radiousOfViewWithSize: rect1.size];
//    float radius2 = [self radiousOfViewWithSize: rect2.size];
//    
//    if (radius1 * (1.0f + limitValue) < radius2) {
//        return BEBDetectFaceSimilarMoveOut;
//    }
    
    BEBDetectFaceSimilarType result = BEBDetectFaceSimilar;
    CGPoint center1 = CGPointMake(CGRectGetMidX(rect1), CGRectGetMidY(rect1));
    CGPoint center2 = CGPointMake(CGRectGetMidX(rect2), CGRectGetMidY(rect2));

    // Check position of 2 object diffence
    if (center1.x - limitValue * CGRectGetWidth(rect1) > center2.x) {
        result += BEBDetectFaceSimilarMoveRight;
    }
    
    if (center1.x + limitValue * CGRectGetWidth(rect1) < center2.x) {
        result += BEBDetectFaceSimilarMoveLeft;
    }
    
    if (center1.y - limitValue * CGRectGetHeight(rect1) > center2.y) {
        result += BEBDetectFaceSimilarMoveUp;
    }
    
    if (center1.y + limitValue * CGRectGetHeight(rect1) < center2.y) {
        result += BEBDetectFaceSimilarMoveDown;
    }
    
    // Priority check the direction first
    if (result != BEBDetectFaceSimilar) {
        return result;
    }
    
//    // Check size of 2 object diffence
//    if (radius1 * (1.0f - limitValue) > radius2) {
//        return BEBDetectFaceSimilarMoveIn;
//    }
    
    return BEBDetectFaceSimilar;
}

- (CGFloat)radiousOfViewWithSize:(CGSize)size;
{
    return sqrt(size.width * size.width + size.height * size.height);
}

// Get the biggest face in the list of image.
- (CIFaceFeature *)getBiggestFaceFromDetectList:(NSArray *)faces;
{
    CIFaceFeature *result = faces[0];
    
    for (int i = 1; i < faces.count; i++) {
        
        // Get the next face in image
        CIFaceFeature *faceFeature = faces[i];
        
        if ([self radiousOfViewWithSize:result.bounds.size] < [self radiousOfViewWithSize:faceFeature.bounds.size]) {
            result = faceFeature;
        }
    }
    return result;
}

// find where the video box is positioned within the preview layer based on the video size and gravity
+ (CGRect)videoPreviewBoxForGravity:(NSString *)gravity
                          frameSize:(CGSize)frameSize
                       apertureSize:(CGSize)apertureSize
{
    CGFloat apertureRatio = apertureSize.height / apertureSize.width;
    CGFloat viewRatio = frameSize.width / frameSize.height;
    
    CGSize size = CGSizeZero;
    if ([gravity isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
        if (viewRatio > apertureRatio) {
            size.width = frameSize.width;
            size.height = apertureSize.width * (frameSize.width / apertureSize.height);
        } else {
            size.width = apertureSize.height * (frameSize.height / apertureSize.width);
            size.height = frameSize.height;
        }
    } else if ([gravity isEqualToString:AVLayerVideoGravityResizeAspect]) {
        if (viewRatio > apertureRatio) {
            size.width = apertureSize.height * (frameSize.height / apertureSize.width);
            size.height = frameSize.height;
        } else {
            size.width = frameSize.width;
            size.height = apertureSize.width * (frameSize.width / apertureSize.height);
        }
    } else if ([gravity isEqualToString:AVLayerVideoGravityResize]) {
        size.width = frameSize.width;
        size.height = frameSize.height;
    }
    
    CGRect videoBox;
    videoBox.size = size;
    if (size.width < frameSize.width)
        videoBox.origin.x = (frameSize.width - size.width) / 2;
    else
        videoBox.origin.x = (size.width - frameSize.width) / 2;
    
    if ( size.height < frameSize.height )
        videoBox.origin.y = (frameSize.height - size.height) / 2;
    else
        videoBox.origin.y = (size.height - frameSize.height) / 2;
    
    if ([gravity isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
        videoBox.origin.x *=-1;
        videoBox.origin.y *=-1;
        
    }
    return videoBox;
}

- (NSString *)detectFaceSimilarTipWithSimilarValue:(BEBDetectFaceSimilarType)value
{

    switch (value) {
        case BEBDetectFaceSimilar:
            return kKeepCurrentStatue;
            break;
        case BEBDetectFaceSimilarMoveLeft:
            return kMoveLeft;
            break;
        case BEBDetectFaceSimilarMoveRight:
            return kMoveRight;
            break;
        case BEBDetectFaceSimilarMoveUp:
            return kMoveUp;
            break;
        case BEBDetectFaceSimilarMoveDown:
            return kMoveDown;
            break;
        case BEBDetectFaceSimilarMoveUpLeft:
            return kMoveUpLeft;
            break;
        case BEBDetectFaceSimilarMoveUpRight:
            return kMoveUppRight;
            break;
        case BEBDetectFaceSimilarMoveDownLeft:
            return kMoveDownLeft;
            break;
        case BEBDetectFaceSimilarMoveDownRight:
            return kMoveDownRight;
            break;
        case BEBDetectFaceSimilarMoveIn:
            return kMoveIn;
            break;
        case BEBDetectFaceSimilarMoveOut:
            return kMoveOut;
            break;
        default:
            return @"";
            break;
    }
    self.leftGuideLabel.layer.cornerRadius = 7;
    
    
}

- (void)showGuideArrowWithDirection:(BEBDetectFaceSimilarType)value
{
    
    switch (value) {
        case BEBDetectFaceSimilar:
        {
            // Do nothing
        }
            break;
        case BEBDetectFaceSimilarMoveLeft:
        {
            self.leftGuideLabel.text = [NSString stringWithFormat:@"%@", [self detectFaceSimilarTipWithSimilarValue:value]];
            self.leftGuideIcon.image = [UIImage imageNamed:@"arrow_left"];
            
            self.leftGuideIcon.hidden = NO;
            self.leftGuideLabel.hidden = NO;
            
            if (!(IS_IPHONE_4 || IS_IPHONE_5)) {
                self.rightGuideLabel.hidden = YES;
                self.rightGuideIcon.hidden = YES;
            }

        }
            break;
        case BEBDetectFaceSimilarMoveRight:
        {
            if (IS_IPHONE_4 || IS_IPHONE_5) {
                
                self.leftGuideLabel.text = [NSString stringWithFormat:@"%@", [self detectFaceSimilarTipWithSimilarValue:value]];
                self.leftGuideIcon.image = [UIImage imageNamed:@"arrow_right"];
                
                self.leftGuideIcon.hidden = NO;
                self.leftGuideLabel.hidden = NO;
                
                self.rightGuideIcon.hidden = YES;
                self.rightGuideLabel.hidden = YES;

            }
            else {
                
                self.rightGuideLabel.text = [NSString stringWithFormat:@"%@", [self detectFaceSimilarTipWithSimilarValue:value]];
                self.rightGuideIcon.image = [UIImage imageNamed:@"arrow_right"];

                self.rightGuideIcon.hidden = NO;
                self.rightGuideLabel.hidden = NO;
                
                self.leftGuideIcon.hidden = YES;
                self.leftGuideLabel.hidden = YES;
            }
        }
            break;
        case BEBDetectFaceSimilarMoveUp:
        {
            self.leftGuideLabel.text = [NSString stringWithFormat:@"%@", [self detectFaceSimilarTipWithSimilarValue:value]];
            self.leftGuideIcon.image = [UIImage imageNamed:@"arrow_up"];
            
            self.leftGuideIcon.hidden = NO;
            self.leftGuideLabel.hidden = NO;
            
            if (!(IS_IPHONE_4 || IS_IPHONE_5)) {
                self.rightGuideIcon.hidden = YES;
                self.rightGuideLabel.hidden = YES;
            }

        }
            break;
        case BEBDetectFaceSimilarMoveDown:
        {
            self.leftGuideLabel.text = [NSString stringWithFormat:@"%@", [self detectFaceSimilarTipWithSimilarValue:value]];
            self.leftGuideIcon.image = [UIImage imageNamed:@"arrow_down"];
            
            self.leftGuideIcon.hidden = NO;
            self.leftGuideLabel.hidden = NO;
            
            if (!(IS_IPHONE_4 || IS_IPHONE_5)) {
                self.rightGuideIcon.hidden = YES;
                self.rightGuideLabel.hidden = YES;
            }

        }
            break;
        case BEBDetectFaceSimilarMoveUpLeft:
        {
            self.leftGuideLabel.text = [NSString stringWithFormat:@"%@", [self detectFaceSimilarTipWithSimilarValue:value]];
            self.leftGuideIcon.image = [UIImage imageNamed:@"arrow_up_left"];
            
            self.leftGuideIcon.hidden = NO;
            self.leftGuideLabel.hidden = NO;
            
            if (!(IS_IPHONE_4 || IS_IPHONE_5)) {
                self.rightGuideIcon.hidden = YES;
                self.rightGuideLabel.hidden = YES;
            }

        }
            break;
        case BEBDetectFaceSimilarMoveUpRight:
        {
            if (IS_IPHONE_4 || IS_IPHONE_5) {
                
                self.leftGuideLabel.text = [NSString stringWithFormat:@"%@", [self detectFaceSimilarTipWithSimilarValue:value]];
                self.leftGuideIcon.image = [UIImage imageNamed:@"arrow_up_right"];
                
                self.leftGuideIcon.hidden = NO;
                self.leftGuideLabel.hidden = NO;
            }
            else {
                
                self.rightGuideLabel.text = [NSString stringWithFormat:@"%@", [self detectFaceSimilarTipWithSimilarValue:value]];
                self.rightGuideIcon.image = [UIImage imageNamed:@"arrow_up_right"];
                
                self.rightGuideIcon.hidden = NO;
                self.rightGuideLabel.hidden = NO;
                
                self.leftGuideIcon.hidden = YES;
                self.leftGuideLabel.hidden = YES;
            }
        }
            break;
        case BEBDetectFaceSimilarMoveDownLeft:
        {
            self.leftGuideLabel.text = [NSString stringWithFormat:@"%@", [self detectFaceSimilarTipWithSimilarValue:value]];
            self.leftGuideIcon.image = [UIImage imageNamed:@"arrow_down_left"];
            
            self.leftGuideIcon.hidden = NO;
            self.leftGuideLabel.hidden = NO;
            
            if (!(IS_IPHONE_4 || IS_IPHONE_5)) {
                
                self.rightGuideIcon.hidden = YES;
                self.rightGuideLabel.hidden = YES;
            }

        }
            break;
        case BEBDetectFaceSimilarMoveDownRight:
        {
            if (IS_IPHONE_4 || IS_IPHONE_5) {
                self.leftGuideLabel.text = [NSString stringWithFormat:@"%@", [self detectFaceSimilarTipWithSimilarValue:value]];
                self.leftGuideIcon.image = [UIImage imageNamed:@"arrow_down_right"];
                
                self.leftGuideIcon.hidden = NO;
                self.leftGuideLabel.hidden = NO;
            }
            else {
                
                self.rightGuideLabel.text = [NSString stringWithFormat:@"%@", [self detectFaceSimilarTipWithSimilarValue:value]];
                self.rightGuideIcon.image = [UIImage imageNamed:@"arrow_down_right"];
                
                self.rightGuideIcon.hidden = NO;
                self.rightGuideLabel.hidden = NO;
                
                self.leftGuideIcon.hidden = YES;
                self.leftGuideLabel.hidden = YES;
            }


        }
            break;
        case BEBDetectFaceSimilarMoveIn:
        {
            self.leftGuideLabel.text = [NSString stringWithFormat:@"%@", [self detectFaceSimilarTipWithSimilarValue:value]];
            
            self.leftGuideIcon.hidden = NO;
            self.leftGuideLabel.hidden = NO;
            
            if (!(IS_IPHONE_4 || IS_IPHONE_5)) {
                
                self.rightGuideIcon.hidden = YES;
                self.rightGuideLabel.hidden = YES;
            }
        }
            break;
        case BEBDetectFaceSimilarMoveOut:
        {
            self.leftGuideLabel.text = [NSString stringWithFormat:@"%@", [self detectFaceSimilarTipWithSimilarValue:value]];
            
            self.leftGuideIcon.hidden = NO;
            self.leftGuideLabel.hidden = NO;

            if (!(IS_IPHONE_4 || IS_IPHONE_5)) {
                
                self.rightGuideIcon.hidden = YES;
                self.rightGuideLabel.hidden = YES;
            }

        }
            break;
        case BEBDetectFaceSimilarNone:
        {
            self.leftGuideIcon.hidden = YES;
            self.leftGuideLabel.hidden = YES;
            
            if (!(IS_IPHONE_4 || IS_IPHONE_5)) {
                
                self.rightGuideIcon.hidden = YES;
                self.rightGuideLabel.hidden = YES;
            }

        }
            break;
        default:
            break;
    }
}


- (IBAction)tip9ButtonClick:(id)sender {
    [self.tip9ImageView setHidden:YES];
    [self.tip9Close setHidden:YES];
    [[NSUserDefaults standardUserDefaults] setObject:@"passed" forKey:@"tip9Name"];
}
@end

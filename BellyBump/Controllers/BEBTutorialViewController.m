#import "BEBTutorialViewController.h"
#import "DVSwitch.h"
#import "BEBStory.h"
#import "BEBDataManager.h"
#import "LGSublimationView.h"
#import "JHChainableAnimations.h"
#import <QuartzCore/QuartzCore.h>
#import "BEBAppDelegate.h"
#import "BEBStoryboard.h"
#import "BEBNewStoryViewController.h"
#import "UIViewController+Popup.h"

@interface BEBTutorialViewController () <UITextFieldDelegate, LGSublimationViewDelegate>

@property (nonatomic, strong) LGSublimationView *sublimationView;

@end

@implementation BEBTutorialViewController

#pragma mark Intialize and life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Personal Profile";
    
    // Add the tutorial view in the main screen
    [self addTutorialView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startButtonClick:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(bebTutorialViewController:dismissWithStory:)]){
        [self.delegate bebTutorialViewController:self dismissWithStory:nil];
    }
}

#pragma mark LGSublimationView
// Add the tutorial view scroll view.
- (void)addTutorialView;
{
    // Init the LGSublimationView
    self.sublimationView  = [[LGSublimationView alloc] initWithFrame:self.view.bounds];
    
    // Setting the background image for the tutorial
    NSMutableArray *views = [NSMutableArray new];
    
    CGFloat width = CGRectGetWidth(self.view.frame);
    // Add image for earch element of the carouse
    
    CGFloat positionY;
    CGFloat imageSize;
    
    if (IS_IPHONE_4) {
        
        positionY = 30;
        imageSize = 190;
    }
    else if (IS_IPHONE_5) {
        
        positionY = 65;
        imageSize = 230;
        
    }
    else {
        
        positionY = 80;
        imageSize = 278;
    }
    
    for (int i = 1; i <= 3; i++) {
        UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake((width - imageSize)/2,
                                                                          positionY,
                                                                          imageSize,
                                                                          imageSize)];
        
        view.image = [UIImage imageNamed:[NSString stringWithFormat:@"%i", i]];
        view.contentMode = UIViewContentModeScaleAspectFit;
        view.backgroundColor = [UIColor clearColor];
        view.clipsToBounds = YES;
        [views addObject:view];
    }
    
    // Configure text color and font for view
    self.sublimationView.titleLabelTextColor = RGB(53, 53, 53, 1);
    self.sublimationView.descriptionLabelTextColor = RGB(86, 86, 86, 1);
    self.sublimationView.delegate = self;
    self.sublimationView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_tutorial"]];
    
    if (IS_IPHONE_4) {
        self.sublimationView.titleLabelY = 210;
        self.sublimationView.descriptionLabelY = 240;
    }
    else if (IS_IPHONE_5){
        
        self.sublimationView.titleLabelY = 285;
        self.sublimationView.descriptionLabelY = 315;
    }
    else  {
        
        self.sublimationView.titleLabelY = 345;
        self.sublimationView.descriptionLabelY = 385;
    }
    
    int fontSizeAdding = 0;
    if (IS_IPHONE_6 || IS_IPHONE_6PLUS) {
        fontSizeAdding = 2;
    }
    
    self.sublimationView.titleLabelFont = [UIFont fontWithName:kFontNameLight size:20 + fontSizeAdding];
    self.sublimationView.descriptionLabelFont = [UIFont fontWithName:kFontNameLight size:12 + fontSizeAdding];
    // Set title for earch tutorial page
    self.sublimationView.titleStrings = @[@"Welcome to Belly Bump!",
                                          @"Capture Your Stories",
                                          @"Share your Story"];
    
    // Set description for earch tutorial page
    self.sublimationView.descriptionStrings = @[@"\nThe easiest and most fun way\nto capture & share\nthe greatest blessing ever: a child.",
                                                @"\nSo here's how it works:\n\n1. Pick your pose.\n\n2. Take your photo using our\nsuper easy photo outlines.\n\n3. Save it or Share it.\n\n4. Do it again tomorrow!",
                                                @"\nSharing your photos and time lapse movies\nis so easy your soon to be born baby could do it!\n\nJust press the video button,\nand watch as we use magic\nto turn your photos into a movie.\n\nThen share anywhere you want."];
    
    // Setting view for LGSublimationView
    self.sublimationView.viewsToSublime = views;
    
    // Add sublimationView in main view
    [self.view insertSubview:self.sublimationView atIndex:0];
}

- (void)lgSublimationViewDidEndScrollingLastPage:(LGSublimationView*)view
{
    BEBAppDelegate *appDelegate = (BEBAppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.window.rootViewController = appDelegate.tabBarController;
    
//    UIStoryboard *storyboard = [BEBStoryboard storyboard];
//    //BEBNewStoryViewController *newStoryVC = [storyboard instantiateViewControllerWithIdentifier:@"BEBHomeViewControllerIdentifier"];
//    
//    BEBNewStoryViewController *newStoryVC = [storyboard instantiateViewControllerWithIdentifier:@"BEBNewStoryViewControllerIdentifier"];
//    newStoryVC.delegate = appDelegate;
//    
//    // Pop up view controller
//    [appDelegate.tabBarController popupViewController:newStoryVC
//                                             animated:YES
//                               dimissedWhenTapOverlay:NO];
}

@end

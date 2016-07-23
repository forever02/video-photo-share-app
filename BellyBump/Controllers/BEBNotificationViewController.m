#import "BEBNotificationViewController.h"

@interface BEBNotificationViewController()

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet UIView *overlayView;

- (IBAction)closeButtonDidTouch:(id)sender;

@end

@implementation BEBNotificationViewController

- (void)viewDidLoad;
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([self isHideOverlay]) {
        [self.overlayView setHidden:YES];
    }
    
    if (IS_IPHONE_4) {
        self.topConstraint.constant = 78.0f;
        [self.containerView layoutIfNeeded];
    }
    
    self.contentLabel.text = self.message;
}

- (void)didReceiveMemoryWarning;
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeButtonDidTouch:(id)sender;
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end

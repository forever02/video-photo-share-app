#import "BEBHomeViewController.h"
#import "BEBMyStoriesViewController.h"
#import "BEBAppDelegate.h"
#import "BEBDataManager.h"

@interface BEBHomeViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *pregnancyImageView;
@property (weak, nonatomic) IBOutlet UILabel *pregnancyLabel;
@property (weak, nonatomic) IBOutlet UIImageView *newbornImageView;
@property (weak, nonatomic) IBOutlet UILabel *newbornLabel;

@end

@implementation BEBHomeViewController

- (void)viewDidLoad;
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.pregnancyLabel.layer.cornerRadius = CGRectGetHeight(self.pregnancyLabel.frame)/2;
    self.newbornLabel.layer.cornerRadius = CGRectGetHeight(self.newbornLabel.frame)/2;
    self.pregnancyLabel.clipsToBounds = YES;
    self.newbornLabel.clipsToBounds = YES;
    
    [self.pregnancyImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(tapPregnancy)]];
    [self.pregnancyLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(tapPregnancy)]];
    
    [self.newbornImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(tapNewborn)]];
    [self.newbornLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(tapNewborn)]];

    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:@(YES) forKey:kSkipShowTutorial];
}
- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    
    // Update local story number from app delegate
    BEBAppDelegate *appDelegate = (BEBAppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.localNotification) {
        
        NSArray *stories = [BEBDataManager sharedManager].stories;
        NSNumber *storyId = appDelegate.localNotification.userInfo[kStoryIdKey];
        for (NSInteger index = 0; index < stories.count; index++) {
            BEBStory *story = stories[index];
            if (story.storyId == [storyId integerValue]) {
                BEBMyStoriesViewController *myStoriesVC = [self.storyboard instantiateViewControllerWithIdentifier:kMyStoriesViewControllerIdentifier];
                if ([story isPregnancy]) {
                    myStoriesVC.pregnancyStories = YES;
                }
                else {
                    myStoriesVC.pregnancyStories = NO;
                }
                [self.navigationController pushViewController:myStoriesVC animated:NO];
                break;
            }
        }
    }
    [self viewTip3];

}

-(void)viewTip2
{
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"tip2Name"] isEqualToString:@"passed"]) {
        [self.tip2ImageView setHidden:YES];
        [self.tip2Close setHidden:YES];
    } else {
        [self.tip2ImageView setHidden:NO];
        [self.tip2Close setHidden:NO];
        CABasicAnimation *fadeInAnimate   = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeInAnimate.duration            = 3;
        fadeInAnimate.repeatCount         = 1;
        fadeInAnimate.autoreverses        = NO;
        fadeInAnimate.fromValue           = [NSNumber numberWithFloat:0.0];
        fadeInAnimate.toValue             = [NSNumber numberWithFloat:1.0];
        fadeInAnimate.removedOnCompletion = YES;
        [self.tip2ImageView.layer addAnimation:fadeInAnimate forKey:@"animateOpacity"];
        [self.tip2Close.layer addAnimation:fadeInAnimate forKey:@"animateOpacity"];
        [[NSUserDefaults standardUserDefaults] setObject:@"passed" forKey:@"tip2Name"];
    }
}
-(void)viewTip3{
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"tip3Name"] isEqualToString:@"passed"]) {
        [self.tip3ImageView setHidden:YES];
        [self.tip3Close setHidden:YES];
        
        [self viewTip2];
    } else {
        [self.tip3ImageView setHidden:NO];
        [self.tip3Close setHidden:NO];
        CABasicAnimation *fadeInAnimate   = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeInAnimate.duration            = 3;
        fadeInAnimate.repeatCount         = 1;
        fadeInAnimate.autoreverses        = NO;
        fadeInAnimate.fromValue           = [NSNumber numberWithFloat:0.0];
        fadeInAnimate.toValue             = [NSNumber numberWithFloat:1.0];
        fadeInAnimate.removedOnCompletion = YES;
        [self.tip3ImageView.layer addAnimation:fadeInAnimate forKey:@"animateOpacity"];
        [self.tip3Close.layer addAnimation:fadeInAnimate forKey:@"animateOpacity"];
        [[NSUserDefaults standardUserDefaults] setObject:@"passed" forKey:@"tip3Name"];
    }
    
}


- (void)didReceiveMemoryWarning;
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tapPregnancy;
{
    BEBMyStoriesViewController *myStoriesVC = [self.storyboard instantiateViewControllerWithIdentifier:kMyStoriesViewControllerIdentifier];
    myStoriesVC.pregnancyStories = YES;
    
    [self.navigationController pushViewController:myStoriesVC animated:YES];
    
    [[NSUserDefaults standardUserDefaults]  setObject:@"passed" forKey:@"tip3Name"];
}

- (void)tapNewborn;
{
    BEBMyStoriesViewController *myStoriesVC = [self.storyboard instantiateViewControllerWithIdentifier:kMyStoriesViewControllerIdentifier];
    myStoriesVC.pregnancyStories = NO;
    
    [self.navigationController pushViewController:myStoriesVC animated:YES];
    
    [[NSUserDefaults standardUserDefaults]  setObject:@"passed" forKey:@"tip3Name"];
}
- (IBAction)tip2ButtonClick:(id)sender {
    [self.tip2ImageView setHidden:YES];
    [self.tip2Close setHidden:YES];
    [[NSUserDefaults standardUserDefaults]  setObject:@"passed" forKey:@"tip2Name"];
}
- (IBAction)tip3ButtonClick:(id)sender {
    [self.tip3ImageView setHidden:YES];
    [self.tip3Close setHidden:YES];
    [[NSUserDefaults standardUserDefaults]  setObject:@"passed" forKey:@"tip3Name"];
    [self viewTip2];
}

@end

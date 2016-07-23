#import "BEBNewStoryViewController.h"
#import "DVSwitch.h"
#import "BEBStory.h"
#import "BEBDataManager.h"
#import "BEBCamViewController.h"
#import "UIViewController+Popup.h"

@interface BEBNewStoryViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *deliveryDayTextField;
@property (weak, nonatomic) IBOutlet UILabel *deliveryDayLabel;
@property (weak, nonatomic) IBOutlet UIView *notificationView;
@property (weak, nonatomic) IBOutlet UIButton *pregnancyButton;
@property (weak, nonatomic) IBOutlet UIButton *newbornButton;
@property (weak, nonatomic) IBOutlet UILabel *pregnancyLabel;
@property (weak, nonatomic) IBOutlet UILabel *newbornLabel;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@property (weak, nonatomic) IBOutlet UIButton *girlButton;
@property (weak, nonatomic) IBOutlet UIButton *boyButton;
@property (weak, nonatomic) IBOutlet UIButton *supriseButton;
@property (weak, nonatomic) IBOutlet UILabel *girlLabel;
@property (weak, nonatomic) IBOutlet UILabel *boyLabel;
@property (weak, nonatomic) IBOutlet UILabel *supriseLabel;

@property (weak, nonatomic) IBOutlet UIView *chooseStoryTypeView;
@property (weak, nonatomic) IBOutlet UIImageView *fullShotImageView;
@property (weak, nonatomic) IBOutlet UIImageView *mediumShotImageView;
@property (weak, nonatomic) IBOutlet UIImageView *detailShotImageView;
@property (weak, nonatomic) IBOutlet UIImageView *degreeImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fullShotLayoutConstraintHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mediumLayoutConstraintHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailLayoutConstraintHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *degree180LayoutConstraintHeight;

@property (weak, nonatomic) IBOutlet UIButton *tip4Close;
@property (weak, nonatomic) IBOutlet UIImageView *tip4ImageView;
@property (weak, nonatomic) IBOutlet UIButton *tip5Close;
@property (weak, nonatomic) IBOutlet UIImageView *tip5ImageView;

@property (strong, nonatomic) DVSwitch *frequentlySwitch;
@property (strong, nonatomic) NSDate *dueDay;
@property (strong, nonatomic) BEBStory *createdStory;
@property (nonatomic) BOOL isPregnancy;
@property (nonatomic) BEBGenderType gender;

@property (nonatomic) BEBFrequencyType frequencyNotification;

- (IBAction)beginEditDate:(id)sender;


@property (nonatomic) CGPoint priorPoint;

- (IBAction)startButtonClick:(id)sender;
- (IBAction)pregnancyButtonClick:(id)sender;
- (IBAction)newbornButtonClick:(id)sender;
- (IBAction)boyButtonClick:(id)sender;
- (IBAction)girlButtonClick:(id)sender;
- (IBAction)supriseButtonClick:(id)sender;
- (IBAction)tip5ButtonClick:(id)sender;
- (IBAction)tip4ButtonClick:(id)sender;

@end

@implementation BEBNewStoryViewController

#pragma mark Intialize and life cycle
- (void)viewDidLoad;
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addBottomView];
    
    // Setting default
    self.isPregnancy = YES;
    self.frequencyNotification = FrequencyTypeDaily;
    self.startButton.enabled = YES;
    self.gender = GenderBoy;

    // Init date Picker and set to input view for delivery day text field.
    // Allow user input textfield by the picker
    UIDatePicker *datePicker = [[UIDatePicker alloc]init];
    
    // Set the current init value.
    [datePicker setDate:[NSDate date]];
    
    // Setting picker mode is Date.
    datePicker.datePickerMode = UIDatePickerModeDate;
    
    // Add target for date picker change value -> update text of text field.
    [datePicker addTarget:self
                   action:@selector(dateTextField:)
         forControlEvents:UIControlEventValueChanged];
    
    // Attach to delivery text field by input view propety.
    [self.deliveryDayTextField setInputView:datePicker];
    
    // Add UITapGestureRecognizer allow user touch outside to close the add view story
    [self.topView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                               action:@selector(touchOutside:)]];
    
    // Add UITapGestureRecognizer allow user touch outside (in the new story view) to hidden the keyboard.
    [self.bottomView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(hiddenKeyboard)]];
    
    [self.boyLabel setUserInteractionEnabled:YES];
    [self.boyLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(boyButtonClick:)]];
    
    [self.girlLabel setUserInteractionEnabled:YES];
    [self.girlLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(girlButtonClick:)]];
    
    [self.supriseLabel setUserInteractionEnabled:YES];
    [self.supriseLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(supriseButtonClick:)]];
    // Allow User touch in text (next to the button) to change status of button
    [self.pregnancyLabel setUserInteractionEnabled:YES];
    [self.pregnancyLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(pregnancyButtonClick:)]];

    [self.newbornLabel setUserInteractionEnabled:YES];
    [self.newbornLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(newbornButtonClick:)]];

    // Add touch for select story type
    [self.fullShotImageView setUserInteractionEnabled:YES];
    [self.fullShotImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(selectedStoryType:)]];
    
    [self.mediumShotImageView setUserInteractionEnabled:YES];
    [self.mediumShotImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                         action:@selector(selectedStoryType:)]];

    [self.detailShotImageView setUserInteractionEnabled:YES];
    [self.detailShotImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                         action:@selector(selectedStoryType:)]];
    
    [self.degreeImageView setUserInteractionEnabled:YES];
    [self.degreeImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                         action:@selector(selectedStoryType:)]];

    // Add the toolbar with Done button for date select keyboard
    float toolBarHeight = 35;
    
    if (IS_IPHONE_4) {
        self.degreeImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.degree180LayoutConstraintHeight.constant -= 25;
        
        self.fullShotImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.fullShotLayoutConstraintHeight.constant -= 25;
        
        self.mediumShotImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.mediumLayoutConstraintHeight.constant -= 25;
        
        self.detailShotImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.detailLayoutConstraintHeight.constant -= 25;

        [self.view layoutIfNeeded];
    }
    
    if (IS_IPHONE_6PLUS) toolBarHeight = 40;
    
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, toolBarHeight);
    UIToolbar* numberToolbar = [[UIToolbar alloc] initWithFrame:frame];
    numberToolbar.barStyle = UIBarStyleBlack;
    
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(hiddenKeyboard)],
                           nil];
    self.deliveryDayTextField.inputAccessoryView = numberToolbar;
    
    // Add notification listen the keyboard event.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"tip4Name"] isEqualToString:@"passed"]) {
        [self.tip4ImageView setHidden:YES];
        [self.tip4Close setHidden:YES];
    } else {
        [self.tip4ImageView setHidden:NO];
        [self.tip4Close setHidden:NO];
        CABasicAnimation *fadeInAnimate   = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeInAnimate.duration            = 3;
        fadeInAnimate.repeatCount         = 1;
        fadeInAnimate.autoreverses        = NO;
        fadeInAnimate.fromValue           = [NSNumber numberWithFloat:0.0];
        fadeInAnimate.toValue             = [NSNumber numberWithFloat:1.0];
        fadeInAnimate.removedOnCompletion = YES;
        [self.tip4ImageView.layer addAnimation:fadeInAnimate forKey:@"animateOpacity"];
        [self.tip4Close.layer addAnimation:fadeInAnimate forKey:@"animateOpacity"];
        [[NSUserDefaults standardUserDefaults] setObject:@"passed" forKey:@"tip4Name"];
    }
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // Remove the listener notification.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Keyboard Notification.

- (void)hiddenKeyboard;
{
    [self.view endEditing:YES];
}

// Void keyboard did show
- (void)keyboardWillShow: (NSNotification *) notification {

    // Moving the new story in the top of screen
    [UIView animateWithDuration:0.25 animations:^{
        
        if (IS_IPHONE_4) {
            self.bottomViewLayoutConstraint.constant = CGRectGetHeight(self.view.frame);
        }
        else if (IS_IPHONE_5) {
            self.bottomViewLayoutConstraint.constant = CGRectGetHeight(self.view.frame) - 20;
        }
        else if (IS_IPHONE_6) {
            self.bottomViewLayoutConstraint.constant = 400 + 216;
        }
        else { //IS_IPHONE_6PLUS
            self.bottomViewLayoutConstraint.constant = 430 + 226;
        }
        [self.view layoutIfNeeded];
    }];
}

// Void keyboard did hide
- (void)keyboardWillHide: (NSNotification *) notif {
    
    // Moving the new story view to the orginal position.
    [UIView animateWithDuration:0.25 animations:^{
        self.bottomViewLayoutConstraint.constant = IS_IPHONE_6PLUS ? 430 : 400;
        [self.view layoutIfNeeded];
    }];
}

#pragma mark UI Initalize
- (void)addBottomView;
{
    // Configure the view apperance
    self.bottomView.backgroundColor = [UIColor clearColor];
    
    CGRect rect = CGRectMake(5,
                             0,
                             CGRectGetWidth([UIScreen mainScreen].bounds) - 10,
                             CGRectGetHeight(self.bottomView.frame));
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:rect];
    bgImageView.backgroundColor = [UIColor clearColor];
    bgImageView.contentMode = UIViewContentModeScaleToFill;
    bgImageView.image = [UIImage imageNamed:@"background_addstory"];
    [self.bottomView insertSubview:bgImageView atIndex:0];
    
    self.titleTextField.backgroundColor = RGB(230, 231, 232, 1);
    self.deliveryDayTextField.backgroundColor = RGB(230, 231, 232, 1);
    self.notificationView.backgroundColor = RGB(230, 231, 232, 1);

    // Setting the switch view for select the notification frequently value.
    self.frequentlySwitch = [DVSwitch switchWithStringsArray:@[@"Daily", @"Bi-weekly", @"Weekly"]];
    if (IS_IPHONE_6PLUS) {
        self.frequentlySwitch.frame = CGRectMake(4, 0, 192, 26);
    }
    else {
        self.frequentlySwitch.frame = CGRectMake(3, 0, 180, 26);
    }
    self.frequentlySwitch.layer.cornerRadius = 13;
    self.frequentlySwitch.clipsToBounds = YES;
    self.frequentlySwitch.font = [UIFont fontWithName:@"OpenSans-Light" size:11];
    self.frequentlySwitch.backgroundColor = RGB(230, 231, 232, 1);
    self.frequentlySwitch.sliderColor = RGB(161, 211, 223, 1);
    self.frequentlySwitch.labelTextColorInsideSlider = RGB(15, 15, 15, 1);
    self.frequentlySwitch.labelTextColorOutsideSlider = RGB(15, 15, 15, 1);
    
    __weak BEBNewStoryViewController *weakSelf = self;
    [self.frequentlySwitch setPressedHandler:^(NSUInteger index) {
        
        // Set the selected value of notification.
        weakSelf.frequencyNotification = (BEBFrequencyType)index;
        
        // Hidden the keyboard (if show already.)
        [weakSelf hiddenKeyboard];

    }];
    
    // Add object to the contain view
    [self.notificationView addSubview:self.frequentlySwitch];
    
}

#pragma mark UITapGestureRecognizer Method
- (void)touchOutside:(UITapGestureRecognizer *)gestureRecognizer;
{
    // Call method before dismiss the add new story view controller.
    if ([self.delegate respondsToSelector:@selector(bebNewStoryViewController:dismissWithStory:)]) {
        [self.delegate bebNewStoryViewController:self dismissWithStory:nil];
    }
}

#pragma mark UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
    if ([textField isEqual:self.titleTextField]) {
        
        // Change to due day field
        [self.deliveryDayTextField becomeFirstResponder];
    }
    else if ([textField isEqual:self.deliveryDayTextField]) {
        
        // Finish input. Hidden the keyboard
        [self.deliveryDayTextField resignFirstResponder];
    }
    return NO;
}


- (void)dateTextField:(id)sender
{
    // Set picker view
    UIDatePicker *picker = (UIDatePicker*)self.deliveryDayTextField.inputView;
    
    // Maximun is 1 year from now.
    [picker setMaximumDate:[NSDate dateWithTimeIntervalSinceNow:400*24*60*60]];
    
    // Init the date formater
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSDate *eventDate = picker.date;
    [dateFormat setDateFormat:@"dd/MM/yyyy"];
    
    // Convert date to string
    NSString *dateString = [dateFormat stringFromDate:eventDate];
    
    // Display the selected value in textfield.
    self.deliveryDayTextField.text = [NSString stringWithFormat:@"%@",dateString];
    self.dueDay = eventDate;
    
    //[self textField:self.titleTextField shouldChangeCharactersInRange:NSMakeRange(0, 0) replacementString:@""];
}

#pragma mark IBAction Method

- (IBAction)beginEditDate:(id)sender;
{
    [self dateTextField: nil];
}

- (IBAction)pregnancyButtonClick:(id)sender;
{
    if (!self.isPregnancy) {
        
        self.isPregnancy = !self.isPregnancy;
        
        self.deliveryDayLabel.text = @"Due Date";
        
        // Change status of 2 button.
        [self.pregnancyButton setImage:[UIImage imageNamed:@"icon_check"] forState:UIControlStateNormal];
        [self.pregnancyButton setImage:[UIImage imageNamed:@"icon_check"] forState:UIControlStateHighlighted];
        [self.pregnancyButton setImage:[UIImage imageNamed:@"icon_check"] forState:UIControlStateSelected];
        
        [self.newbornButton setImage:[UIImage imageNamed:@"icon_uncheck"] forState:UIControlStateNormal];
        [self.newbornButton setImage:[UIImage imageNamed:@"icon_uncheck"] forState:UIControlStateHighlighted];
        [self.newbornButton setImage:[UIImage imageNamed:@"icon_uncheck"] forState:UIControlStateSelected];
    }
}

- (IBAction)newbornButtonClick:(id)sender;
{
    if (self.isPregnancy) {
        
        self.isPregnancy = !self.isPregnancy;
        self.deliveryDayLabel.text = @"Birthdate";

        // Change status of 2 button.
        [self.pregnancyButton setImage:[UIImage imageNamed:@"icon_uncheck"] forState:UIControlStateNormal];
        [self.pregnancyButton setImage:[UIImage imageNamed:@"icon_uncheck"] forState:UIControlStateHighlighted];
        [self.pregnancyButton setImage:[UIImage imageNamed:@"icon_uncheck"] forState:UIControlStateSelected];
        
        [self.newbornButton setImage:[UIImage imageNamed:@"icon_check"] forState:UIControlStateNormal];
        [self.newbornButton setImage:[UIImage imageNamed:@"icon_check"] forState:UIControlStateHighlighted];
        [self.newbornButton setImage:[UIImage imageNamed:@"icon_check"] forState:UIControlStateSelected];
    }
}

- (IBAction)selectedStoryType:(UITapGestureRecognizer *)sender;
{
    
    BEBDataManager *dataManager = [BEBDataManager sharedManager];
    
    // Get the information of the new story
    BEBStory *story = [[BEBStory alloc] init];
    story.title = self.titleTextField.text;
    [story setPregnancy: self.isPregnancy];
    story.frequence = self.frequencyNotification;
    story.startDate = [[NSDate date] dateByAddingTimeInterval:-1]; // Adjust time to skip local notification after created story.
    story.storyType = sender.view.tag;
    story.gender = self.gender;
    story.birthDate = self.dueDay;
    [dataManager.stories insertObject:story atIndex:0];
//    BEBStory *aaa = [[BEBStory alloc] init];
//    aaa = [dataManager.stories objectAtIndex:dataManager.stories.count - 1];
//    aaa.gender = GenderGirl;
    // Update local notification for story
    [dataManager updateLocalNotificationForStory:story];
    self.createdStory = story;
    
    // Cache data and sync to S3
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Save story data to file to cache local
        [[BEBDataManager sharedManager] saveStoryDataToFile];
        [[BEBDataManager sharedManager] saveDataToS3:nil];
    });
    
    
    if (story.storyType == StoryType180Degree) {
        
        // Show the tips how to take the image
        [self showTipsTake180Degree];
    }
    else {
        // Call method before dismiss the add new story view controller.
        if ([self.delegate respondsToSelector:@selector(bebNewStoryViewController:dismissWithStory:)]) {
            [self.delegate bebNewStoryViewController:self dismissWithStory:story];
        }
    }
}

- (void)showTipsTake180Degree;
{
    // Init the view show tips how to take the 180 degree image
    CGRect rect = self.chooseStoryTypeView.frame;
    rect.origin.y = CGRectGetHeight(self.chooseStoryTypeView.frame);

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
    imageView.contentMode = UIViewContentModeCenter;
    if (self.createdStory.isPregnancy) {
        if (IS_IPHONE_6) {
            imageView.image = [UIImage imageNamed:@"degree_tip_mom_ip6"];
        }
        else {
            imageView.image = [UIImage imageNamed:@"degree_tip_mom"];
        }
    }
    else {
        if (IS_IPHONE_6) {
            imageView.image = [UIImage imageNamed:@"degree_tip_kid_ip6"];
        }
        else {
            imageView.image = [UIImage imageNamed:@"degree_tip_kid"];
        }
    }
    
    if (IS_IPHONE_4) {
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"degree_select_bg"]];
    }
    
    [self.chooseStoryTypeView addSubview:imageView];
    imageView.clipsToBounds = YES;
    [imageView setUserInteractionEnabled:YES];
    
    // Animation view the guide view
    [UIView animateWithDuration:0.2 animations:^{
        
        CGRect frame = imageView.frame;
        frame.origin.y = 0.0f;
        imageView.frame = frame;
        
    } completion:^(BOOL finished) {
        
        // Add touch swipe to left to capture image
        UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                                     action:@selector(swipeToCaptureImage)];
        swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        [imageView addGestureRecognizer:swipeGestureRecognizer];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                               action:@selector(swipeToCaptureImage)];
        
        tapGestureRecognizer.numberOfTapsRequired = 1;
        [imageView addGestureRecognizer:tapGestureRecognizer];

    }];
}

- (void)swipeToCaptureImage;
{
    // Call method before dismiss the add new story view controller.
    if ([self.delegate respondsToSelector:@selector(bebNewStoryViewController:dismissWithStory:)]) {
        [self.delegate bebNewStoryViewController:self dismissWithStory:self.createdStory];
    }
}

- (IBAction)startButtonClick:(id)sender;
{
    if (self.titleTextField.text.length > 0 &&
        self.deliveryDayTextField.text.length > 0)
    {
        [self hiddenKeyboard];
        
        // Change the image of select type
        if (IS_IPHONE_6) {
            if (self.isPregnancy) {
                self.fullShotImageView.image = [UIImage imageNamed:@"img_mom_fullshot_iP6"];
                self.mediumShotImageView.image = [UIImage imageNamed:@"img_mom_mediumshot_iP6"];
                self.detailShotImageView.image = [UIImage imageNamed:@"img_mom_detailshot_iP6"];
                self.degreeImageView.image = [UIImage imageNamed:@"img_mom_180_iP6"];
            }
        }
        else {
            if (self.isPregnancy) {
                self.fullShotImageView.image = [UIImage imageNamed:@"img_mom_fullshot"];
                self.mediumShotImageView.image = [UIImage imageNamed:@"img_mom_mediumshot"];
                self.detailShotImageView.image = [UIImage imageNamed:@"img_mom_detailshot"];
                self.degreeImageView.image = [UIImage imageNamed:@"img_mom_180"];
            }
        }
        
        // Show the Selection type
        self.chooseStoryTypeView.hidden = NO;
        [UIView animateWithDuration:0.25 animations:^{
            self.chooseStoryTypeView.alpha = 1.0f;
        }];
        
        if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"tip5Name"] isEqualToString:@"passed"]) {
            [self.tip5ImageView setHidden:YES];
            [self.tip5Close setHidden:YES];
        } else {
            [self.tip5ImageView setHidden:NO];
            [self.tip5Close setHidden:NO];
            CABasicAnimation *fadeInAnimate   = [CABasicAnimation animationWithKeyPath:@"opacity"];
            fadeInAnimate.duration            = 3;
            fadeInAnimate.repeatCount         = 1;
            fadeInAnimate.autoreverses        = NO;
            fadeInAnimate.fromValue           = [NSNumber numberWithFloat:0.0];
            fadeInAnimate.toValue             = [NSNumber numberWithFloat:1.0];
            fadeInAnimate.removedOnCompletion = YES;
            [self.tip5ImageView.layer addAnimation:fadeInAnimate forKey:@"animateOpacity"];
            [self.tip5Close.layer addAnimation:fadeInAnimate forKey:@"animateOpacity"];
            [[NSUserDefaults standardUserDefaults] setObject:@"passed" forKey:@"tip5Name"];
        }
        
    }
}

- (IBAction)boyButtonClick:(id)sender;
{
    
    if (self.gender != GenderBoy) {
        // Change status of 2 button.
        [self.boyButton setImage:[UIImage imageNamed:@"icon_check"] forState:UIControlStateNormal];
        [self.boyButton setImage:[UIImage imageNamed:@"icon_check"] forState:UIControlStateHighlighted];
        [self.boyButton setImage:[UIImage imageNamed:@"icon_check"] forState:UIControlStateSelected];
        
        [self.girlButton setImage:[UIImage imageNamed:@"icon_uncheck"] forState:UIControlStateNormal];
        [self.girlButton setImage:[UIImage imageNamed:@"icon_uncheck"] forState:UIControlStateHighlighted];
        [self.girlButton setImage:[UIImage imageNamed:@"icon_uncheck"] forState:UIControlStateSelected];
        
        [self.supriseButton setImage:[UIImage imageNamed:@"icon_uncheck"] forState:UIControlStateNormal];
        [self.supriseButton setImage:[UIImage imageNamed:@"icon_uncheck"] forState:UIControlStateHighlighted];
        [self.supriseButton setImage:[UIImage imageNamed:@"icon_uncheck"] forState:UIControlStateSelected];
        
        self.gender = GenderBoy;
    }
}

- (IBAction)girlButtonClick:(id)sender;
{
    if (self.gender != GenderGirl) {
        // Change status of 2 button.
        [self.girlButton setImage:[UIImage imageNamed:@"icon_check"] forState:UIControlStateNormal];
        [self.girlButton setImage:[UIImage imageNamed:@"icon_check"] forState:UIControlStateHighlighted];
        [self.girlButton setImage:[UIImage imageNamed:@"icon_check"] forState:UIControlStateSelected];
        
        [self.boyButton setImage:[UIImage imageNamed:@"icon_uncheck"] forState:UIControlStateNormal];
        [self.boyButton setImage:[UIImage imageNamed:@"icon_uncheck"] forState:UIControlStateHighlighted];
        [self.boyButton setImage:[UIImage imageNamed:@"icon_uncheck"] forState:UIControlStateSelected];
        
        [self.supriseButton setImage:[UIImage imageNamed:@"icon_uncheck"] forState:UIControlStateNormal];
        [self.supriseButton setImage:[UIImage imageNamed:@"icon_uncheck"] forState:UIControlStateHighlighted];
        [self.supriseButton setImage:[UIImage imageNamed:@"icon_uncheck"] forState:UIControlStateSelected];
        
        self.gender = GenderGirl;
    }
}

- (IBAction)supriseButtonClick:(id)sender;
{
    if (self.gender != GenderSuprise) {
        // Change status of 2 button.
        [self.supriseButton setImage:[UIImage imageNamed:@"icon_check"] forState:UIControlStateNormal];
        [self.supriseButton setImage:[UIImage imageNamed:@"icon_check"] forState:UIControlStateHighlighted];
        [self.supriseButton setImage:[UIImage imageNamed:@"icon_check"] forState:UIControlStateSelected];
        
        [self.girlButton setImage:[UIImage imageNamed:@"icon_uncheck"] forState:UIControlStateNormal];
        [self.girlButton setImage:[UIImage imageNamed:@"icon_uncheck"] forState:UIControlStateHighlighted];
        [self.girlButton setImage:[UIImage imageNamed:@"icon_uncheck"] forState:UIControlStateSelected];
        
        [self.boyButton setImage:[UIImage imageNamed:@"icon_uncheck"] forState:UIControlStateNormal];
        [self.boyButton setImage:[UIImage imageNamed:@"icon_uncheck"] forState:UIControlStateHighlighted];
        [self.boyButton setImage:[UIImage imageNamed:@"icon_uncheck"] forState:UIControlStateSelected];
        
        self.gender = GenderSuprise;
    }
}

- (IBAction)tip5ButtonClick:(id)sender {
    [self.tip5ImageView setHidden:YES];
    [self.tip5Close setHidden:YES];
    [[NSUserDefaults standardUserDefaults] setObject:@"passed" forKey:@"tip5Name"];
}

- (IBAction)tip4ButtonClick:(id)sender {
    [self.tip4ImageView setHidden:YES];
    [self.tip4Close setHidden:YES];
    [[NSUserDefaults standardUserDefaults] setObject:@"passed" forKey:@"tip4Name"];
}

@end

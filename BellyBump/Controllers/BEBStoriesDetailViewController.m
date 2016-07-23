#import "BEBStoriesDetailViewController.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import "BEBStoriesDetailCell.h"
#import "BEBStory.h"
#import "BEBStoryDetailHeaderView.h"
#import "BEBPhotoDetailViewController.h"
#import "BEBCamViewController.h"
#import "BEBImage.h"
#import "BEBImageEditorViewController.h"
#import "BEBSharingImageViewController.h"
#import "BEBDataManager.h"
#import "BEBCreateVideoViewController.h"
#import "BEBTextEditorViewController.h"
#import "BEBAppDelegate.h"

@interface BEBStoriesDetailViewController () <UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
BEBStoriesDetailCellDelegate,
UITextFieldDelegate,
BEBCamViewControllerDelegate,
BEBSharingImageViewControllerDelegate,
HFImageEditorViewControllerDelegate>

@property (nonatomic, strong) BEBStoryDetailHeaderView *headerView;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *createVideoButton;
@property (nonatomic, strong) UIImagePickerController *picker;
@property (nonatomic, strong) UIImage *captureImage;
@property (nonatomic, strong) UINavigationController *presentVC;

//Gender Editor
@property (strong, nonatomic) IBOutlet UIView *genderEditView;
@property (weak, nonatomic) IBOutlet UIButton *girlButton;
@property (weak, nonatomic) IBOutlet UIButton *boyButton;
@property (weak, nonatomic) IBOutlet UIButton *supriseButton;
@property (weak, nonatomic) IBOutlet UILabel *girlLabel;
@property (weak, nonatomic) IBOutlet UILabel *boyLabel;
@property (weak, nonatomic) IBOutlet UILabel *supriseLabel;
@property (strong, nonatomic) IBOutlet UITextField *dueDatetextField;
@property (strong, nonatomic) NSDate *dueDay;
@property (weak, nonatomic) IBOutlet UIButton *tip12Close;

@property (weak, nonatomic) IBOutlet UIImageView *tip12ImageView;

- (IBAction)boyButtonClick:(id)sender;
- (IBAction)girlButtonClick:(id)sender;
- (IBAction)surpriseButtonClick:(id)sender;
- (IBAction)createVideoButtonDidTouch:(id)sender;
- (IBAction)tip12ButtonClick:(id)sender;

@end

@implementation BEBStoriesDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGFloat bottomInset = IS_IPHONE_6PLUS ? 129.0f : (IS_IPHONE_6 ? 116.0f : 58.0f);
    [self.collectionView setContentInset:UIEdgeInsetsMake(0, 0, bottomInset, 0)];
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"tip12Name"] isEqualToString:@"passed"]) {
        [self.tip12ImageView setHidden:YES];
        [self.tip12Close setHidden:YES];
    } else {
        [self.tip12ImageView setHidden:NO];
        [self.tip12Close setHidden:NO];
        CABasicAnimation *fadeInAnimate   = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeInAnimate.duration            = 3;
        fadeInAnimate.repeatCount         = 1;
        fadeInAnimate.autoreverses        = NO;
        fadeInAnimate.fromValue           = [NSNumber numberWithFloat:0.0];
        fadeInAnimate.toValue             = [NSNumber numberWithFloat:1.0];
        fadeInAnimate.removedOnCompletion = YES;
        [self.tip12ImageView.layer addAnimation:fadeInAnimate forKey:@"animateOpacity"];
        [self.tip12Close.layer addAnimation:fadeInAnimate forKey:@"animateOpacity"];
        [[NSUserDefaults standardUserDefaults] setObject:@"passed" forKey:@"tip12Name"];
    }

    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideTip12:) name: @"tip12Passed" object:nil];
}
-(void)hideTip12:(id)sender{
    [self.tip12ImageView setHidden:YES];
    [self.tip12Close setHidden:YES];
    [[NSUserDefaults standardUserDefaults] setObject:@"passed" forKey:@"tip12Name"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.collectionView reloadData];
    
    if (self.story.photos.count == 0) {
        [self.createVideoButton setEnabled:NO];
    }
    else {
        [self.createVideoButton setEnabled:YES];
    }
    
    // Gender editor
    [self.genderEditView setHidden:YES];
    [self.boyLabel setUserInteractionEnabled:YES];
    [self.boyLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(boyButtonClick:)]];
    
     [self.girlLabel setUserInteractionEnabled:YES];
     [self.girlLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(girlButtonClick:)]];
    
     [self.supriseLabel setUserInteractionEnabled:YES];
     [self.supriseLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(surpriseButtonClick:)]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Update local story number from app delegate
    BEBAppDelegate *appDelegate = (BEBAppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.localNotification) {
        appDelegate.localNotification = nil;
        
        NSArray *stories = [BEBDataManager sharedManager].stories;
        NSNumber *storyId = appDelegate.localNotification.userInfo[kStoryIdKey];
        for (NSInteger index = 0; index < stories.count; index++) {
            BEBStory *story = stories[index];
            if (story.storyId == [storyId integerValue]) {
                [self bebStoriesDetailCellClickOpenCamera:nil];
                self.needTakeImage = NO;
                break;
            }
        }
    }
    
    // Show camera after create story
    if (self.needTakeImage) {
        [self bebStoriesDetailCellClickOpenCamera:nil];
        self.needTakeImage = NO;
    }
    
    // gendereditview's position
    CGRect frame = self.genderEditView.frame;
    frame.origin.y = self.headerView.reminderLabel.frame.origin.y;
}

- (void)genderEditViewRefresh:(BEBGenderType) genderParam
{
    if (self.story.gender == GenderBoy) {
        self.headerView.genderLabel.text = @"Boy";
    }
    else if (self.story.gender == GenderGirl) {
        self.headerView.genderLabel.text = @"Girl";
    }
    else {
        self.headerView.genderLabel.text = @"Suprise";
    }

    if (genderParam == GenderBoy) {
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
    }
    
    if (genderParam == GenderGirl) {
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
    }

    if (genderParam == GenderSuprise) {
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
        
    }
}

- (void)dateTextField1:(id)sender
{
    // Set picker view
    if(self.datepicker == nil){
        CGRect rect = [[UIScreen mainScreen] bounds];
        self.datepicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 300, rect.size.width, 200)];
    }
    self.datepicker.datePickerMode = UIDatePickerModeDate;
    [self.datepicker setHidden:NO];
    
    // Maximun is 1 year from now.
    [self.datepicker setMaximumDate:[NSDate dateWithTimeIntervalSinceNow:400*24*60*60]];
    
    [ self.view addSubview:self.datepicker ];
    [ self.datepicker addTarget:self action:@selector(dateChange:) forControlEvents:UIControlEventValueChanged ] ;
    // Init the date formater
}
- ( void ) dateChange : ( UIDatePicker * ) sender {
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate  * date = self.datepicker.date;
//    NSString *_aString = [formatter stringFromDate:date];
//    
//    self.headerView.duedateLabel.text = [NSString stringWithFormat:@"due date: %@", _aString];
//    ;
    
    if (self.story.birthDate) {
        self.story.birthDate = date;
    }
    else {
        self.story.startDate = date;
    }
    
    NSString *dueDate;
    if (self.story.birthDate) {
        dueDate = [BEBUtilities dateStringFromDate:self.story.birthDate];
    }
    else if (self.story.startDate) {
        dueDate = [BEBUtilities dateStringFromDate:self.story.startDate];
    }
    //NSString *dueDate = [BEBUtilities dateStringFromDate:self.story.birthDate];
    self.headerView.duedateLabel.text = [NSString stringWithFormat:@"due date: %@", dueDate];
    
    
    [self.datepicker setHidden:YES];
    
    // Cache data and sync to S3
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Save story data to file to cache local
        [[BEBDataManager sharedManager] saveStoryDataToFile];
        [[BEBDataManager sharedManager] saveDataToS3:nil];
    });
}

- (void)duedateEditButtonClicked:(id)sender {
    NSLog(@"duedateEditButtonClicked button clicked!");
    [self dateTextField1:nil];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"passed" forKey:@"tip12Name"];
    [self.tip12ImageView setHidden:YES];
    [self.tip12Close setHidden:YES];

}

- (void)genderEditButtonClick:(id)sender {
    NSLog(@"gendereditbutton button clicked!");
    [[NSUserDefaults standardUserDefaults] setObject:@"passed" forKey:@"tip12Name"];
    [self.tip12ImageView setHidden:YES];
    [self.tip12Close setHidden:YES];

    [self.genderEditView setHidden:NO];
    
    [self genderEditViewRefresh:self.story.gender];
}

- (IBAction)boyButtonClick:(id)sender {
    NSLog(@"boy button clicked!");
    
    if (self.story.gender != GenderBoy) {
        self.story.gender = GenderBoy;
        [self genderEditViewRefresh:self.story.gender];
        // Cache data and sync to S3
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            // Save story data to file to cache local
            [[BEBDataManager sharedManager] saveStoryDataToFile];
            [[BEBDataManager sharedManager] saveDataToS3:nil];
        });
    }
    
    [self.genderEditView setHidden:YES];
}

- (IBAction)girlButtonClick:(id)sender {
    NSLog(@"girlButtonClick button clicked!");
    if (self.story.gender != GenderGirl) {
        self.story.gender = GenderGirl;
        [self genderEditViewRefresh:self.story.gender];
        // Cache data and sync to S3
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            // Save story data to file to cache local
            [[BEBDataManager sharedManager] saveStoryDataToFile];
            [[BEBDataManager sharedManager] saveDataToS3:nil];
        });

    }
    [self.genderEditView setHidden:YES];
}

- (IBAction)surpriseButtonClick:(id)sender {
    NSLog(@"surpriseButtonClick button clicked!");
    if (self.story.gender != GenderSuprise) {
        self.story.gender = GenderSuprise;
        [self genderEditViewRefresh:self.story.gender];
        // Cache data and sync to S3
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            // Save story data to file to cache local
            [[BEBDataManager sharedManager] saveStoryDataToFile];
            [[BEBDataManager sharedManager] saveDataToS3:nil];
        });

    }
    [self.genderEditView setHidden:YES];
}

- (IBAction)editDateClick:(id)sender {
    
    [self dateTextField1:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc;
{
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
}

- (void)hideTextField
{
    if ([self.headerView.storyNameTextField isFirstResponder]) {
        
        self.headerView.storyNameTextField.text = self.story.title;
        [self.headerView.storyNameTextField setHidden:YES];
        [self.headerView.storyNameLabel setHidden:NO];
        [self.headerView.editButton setHidden:NO];
        
        [self.headerView.storyNameTextField resignFirstResponder];
    }
}

//*****************************************************************************
#pragma mark -
#pragma mark - ** UICollectionViewDataSource methods **

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
{
    return self.story.photos.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BEBStoriesDetailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BEBStoriesDetailCellIdentifier" forIndexPath:indexPath];
    
    if (indexPath.row == self.story.photos.count) {
        [cell setThumbnailImage:nil];
    }
    else {
        [cell setThumbnailImage:self.story.photos[indexPath.row]];
    }
    
    cell.indexPath = indexPath;
    cell.delegate = self;
    
    return cell;
}

//*****************************************************************************
#pragma mark -
#pragma mark - ** UICollectionViewFlowLayoutDelegate methods **

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPHONE_4 || IS_IPHONE_5) {
        return CGSizeMake(147.0f, 147.0f);
    }
    else if (IS_IPHONE_6) {
        return CGSizeMake(172.0f, 172.0f);
    }
    else { // IS_IPHONE_6PLUS
        return CGSizeMake(190.0f, 190.0f);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section;
{
    if (IS_IPHONE_4 || IS_IPHONE_5) {
        return 8.0f;
    }
    else if (IS_IPHONE_6) {
        return 10.0f;
    }
    else { // IS_IPHONE_6PLUS
        return 11.0f;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        
        BEBStoryDetailHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"BEBStoryDetailHeaderViewIdentifier" forIndexPath:indexPath];
        
        headerView.storyNameLabel.text = self.story.title;
        headerView.storyNameTextField.text = self.story.title;
        headerView.storyNameTextField.delegate = self;
        
        headerView.duedateLabelTextField.delegate = self;
        
        if (self.story.gender == GenderBoy) {
            headerView.genderLabel.text = @"Boy";
        }
        else if (self.story.gender == GenderGirl) {
            headerView.genderLabel.text = @"Girl";
        }
        else {
            headerView.genderLabel.text = @"Suprise";
        }
        
        NSString *dueDate;
        if (self.story.birthDate) {
            dueDate = [BEBUtilities dateStringFromDate:self.story.birthDate];
        }
        else if (self.story.startDate) {
            dueDate = [BEBUtilities dateStringFromDate:self.story.startDate];
        }
        //NSString *dueDate = [BEBUtilities dateStringFromDate:self.story.birthDate];
        headerView.duedateLabel.text = [NSString stringWithFormat:@"due date: %@", dueDate];
        headerView.reminderLabel.text = [NSString stringWithFormat:@"your next picture is in %@!", [self.story timeForNextPhoto]];
        
        reusableview = headerView;
        
        [headerView.genderEditButton addTarget:self action:@selector(genderEditButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [headerView.duedateEditButton addTarget:self action:@selector(duedateEditButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

        self.headerView = headerView;
    }
    
    return reusableview;
}

//*****************************************************************************
#pragma mark -
#pragma mark - ** UITextFieldDelegate **

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
        NSString *text = [textField.text stringByReplacingOccurrencesOfString:@"\\s" withString:@""
                                                                      options:NSRegularExpressionSearch
                                                                        range:NSMakeRange(0, [textField.text length])];
        
        if (![text isEqualToString:@""] &&
            ![textField.text isEqualToString:self.story.title]) {
            
            self.headerView.storyNameLabel.text = textField.text;
            self.story.title = textField.text;
            
            // Cache data and sync to S3
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                // Save story data to file to cache local
                [[BEBDataManager sharedManager] saveStoryDataToFile];
                [[BEBDataManager sharedManager] saveDataToS3:nil];
            });
        }
        
        [self.headerView.storyNameTextField setHidden:YES];
        [self.headerView.storyNameLabel setHidden:NO];
        [self.headerView.editButton setHidden:NO];
        
        [textField resignFirstResponder];
        
        return YES;
}

//*****************************************************************************
#pragma mark -
#pragma mark - ** UIScrollViewDelegate methods **

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    [self hideTextField];
}

//*****************************************************************************
#pragma mark -
#pragma mark - ** BEBStoriesDetailCellDelegate methods **

- (void)bebStoriesDetailCell:(id)storiesDetailCell didTouchOnPhotoAtIndex:(NSInteger)index;
{
    [self hideTextField];
    
    BEBPhotoDetailViewController *photoDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"BEBPhotoDetailViewControllerIdentifier"];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:photoDetailVC];
    photoDetailVC.title = @"MY STORIES";
    photoDetailVC.story = self.story;
    photoDetailVC.currentPage = index;
    
    [self presentViewController:nc animated:YES completion:nil];
}

- (void)bebStoriesDetailCellClickOpenCamera:(id)storiesDetailCell;
{
    // View the capture image
    BEBCamViewController *cameraViewController = [self.storyboard instantiateViewControllerWithIdentifier:kCameraCaptureViewControllerIdentifier];
    cameraViewController.delegate = self;
    cameraViewController.story = self.story;
    
    if (self.story.photos && self.story.photos.count > 0) {
        
        // Get the last image of story
        BEBImage *lastImage = [self.story.photos lastObject];
        
        // Set the photo as the previous photo
        cameraViewController.previousPhoto = lastImage.image;
    }
    
    // Present the capture image
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:cameraViewController];
    nc.navigationBarHidden = YES;
    [self presentViewController:nc animated:YES completion:nil];
}

- (void)bebStoriesDetailCellClickOpenLibrary:(id)storiesDetailCell;
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
#pragma mark - ** IBAction methods **

- (IBAction)createVideoButtonDidTouch:(id)sender;
{
    // Show create video view controller
    BEBCreateVideoViewController *createvideoVC = [self.storyboard instantiateViewControllerWithIdentifier:kCreateVideoViewControllerIdentifier];
    createvideoVC.story = self.story;
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:createvideoVC];
    [self presentViewController:nc animated:YES completion:nil];
}

- (IBAction)tip12ButtonClick:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:@"passed" forKey:@"tip12Name"];
    [self.tip12ImageView setHidden:YES];
    [self.tip12Close setHidden:YES];

}

//*****************************************************************************
#pragma mark -
#pragma mark ** UIImagePickerViewControllerDelegate **

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // Show device's status bar
    [[UIApplication sharedApplication] setStatusBarHidden:NO];

    // Check media type to ensure that the user has chosen an image (not a camera)
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        
        // Get the image chosen by the user
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        if(!image){
            [BEBUtilities loadImageFromAssertByUrl:[info objectForKey:@"UIImagePickerControllerReferenceURL"]
                                         completion:^(UIImage* img){
                                             if (img) {
                                                 [self showImageEditorViewControllerWithImage:img];
                                             }

                                         }];
        }else{

            [self showImageEditorViewControllerWithImage:image];

        }
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
#pragma mark - ** BEBCamViewControllerDelegate methods **
- (void)bebCamViewController:(BEBCamViewController *)camViewController
           finishedWithImage:(UIImage *)image;
{
    
    // Init the image editor view controller
    BEBImageEditorViewController *imageEditorViewController = (BEBImageEditorViewController*)[self.storyboard instantiateViewControllerWithIdentifier:kImageEditorViewControllerIdentifier];
    
    imageEditorViewController.checkBounds = YES;
    imageEditorViewController.rotateEnabled = NO;
    imageEditorViewController.scaleEnabled = YES;
    imageEditorViewController.sourceImage = image;
    
    imageEditorViewController.previousImage = camViewController.previousPhoto;
    imageEditorViewController.previousImageAlpha = camViewController.previousPhotoView.alpha;
    imageEditorViewController.previousImageHidden = (camViewController.previousPhotoView.image == nil);
    imageEditorViewController.delegate = self;
    
    // Hidden the camera view and show the image editor view
    [self dismissViewControllerAnimated:NO completion:^{
        self.presentVC = [[UINavigationController alloc] initWithRootViewController:imageEditorViewController];
        [self presentViewController:self.presentVC animated:YES completion:nil];
    }];
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
            
            if (captionImage) { // capition image just NULL image
                [self showTextEditorViewControllerWithImage:editedImage];
            }
            else {
                
                // Add image to story
                [self addImageToStory:editedImage];
                
                // Show sharing view controller.
                [self showSharingViewControllerWithImage:editedImage];
            }
        }
        else {
            // BEBTextEditorViewController
            // Add image to story
            [self addImageToStory:editedImage];
            
            // Show sharing view controller.
            [self showSharingViewControllerWithImage:captionImage];

        }
    }
}

- (void)showSharingViewControllerWithImage:(UIImage *)image;
{
    BEBSharingImageViewController *sharingImageViewController;
    sharingImageViewController = (BEBSharingImageViewController*)[self.storyboard                                                                                               instantiateViewControllerWithIdentifier:kSharingImageViewControllerIdentifier];
    
    sharingImageViewController.image = image;
    sharingImageViewController.delegate = self;
    
    [self.presentVC pushViewController:sharingImageViewController animated:YES];
}

- (void)showImageEditorViewControllerWithImage:(UIImage *)image
{
    // Init the image view without previous image
    BEBImageEditorViewController *imageEditorViewController = (BEBImageEditorViewController*)[self.storyboard instantiateViewControllerWithIdentifier:kImageEditorViewControllerIdentifier];
    
    imageEditorViewController.checkBounds =YES;
    imageEditorViewController.rotateEnabled = NO;
    imageEditorViewController.scaleEnabled = YES;
    imageEditorViewController.sourceImage = image;
    imageEditorViewController.delegate = self;
    
    BEBImage *lastImage = [self.story.photos firstObject];
    imageEditorViewController.previousImage = lastImage.image;
    imageEditorViewController.previousImageAlpha = 0.4;
    imageEditorViewController.previousImageHidden = YES;

    self.presentVC = [[UINavigationController alloc] initWithRootViewController:imageEditorViewController];
    [self presentViewController:self.presentVC animated:YES completion:nil];

}

- (void)addImageToStory:(UIImage *)croppedImage
{
    self.captureImage = croppedImage;
    
    // Crop the image to small size
//    CGSize imageSize = self.captureImage.size;
//    CGSize videoSize = [BEBUtilities videoSizeByIndex:1];
//    CGFloat scale = MIN(videoSize.width / imageSize.width, videoSize.height / imageSize.height);
    CGFloat scale = 1.0;
    self.captureImage = [BEBUtilities scaleImage:self.captureImage scaleFactor:scale];
    
    BEBImage *addingImage = [[BEBImage alloc] init];
    
    // General uiid for image name
    addingImage.uuid = [BEBUtilities getUUID];
    
    addingImage.image = self.captureImage;
    
    // Save the image to local cache directory
    [addingImage saveImageToLocal];
    
    // Change the order of the new image
    [self.story.photos addObject:addingImage];
    
    // Reload table to show the new image.
    [self.collectionView reloadData];
    
    // Upload image to s3
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Save story data to file to cache local
        [[BEBDataManager sharedManager] saveStoryDataToFile];
        
        // Save image to S3
        [addingImage saveImageToS3:^(BOOL result) {
            if (result) {
                // Save story data to file to update image saved on S3
                [[BEBDataManager sharedManager] saveStoryDataToFile];
                
                // Save data to S3
                [[BEBDataManager sharedManager] saveDataToS3:nil];
            }
        }];
    });
}

- (void)showTextEditorViewControllerWithImage:(UIImage *)image
{
    // Show text edit view controller
    BEBTextEditorViewController *textEditorViewController = (BEBTextEditorViewController*)[self.storyboard instantiateViewControllerWithIdentifier:kBEBTextEditorViewControllerIdentifier];
    
    textEditorViewController.checkBounds = NO;
    textEditorViewController.rotateEnabled = YES;
    textEditorViewController.scaleEnabled = YES;
    
    // Get the lastest object
    textEditorViewController.sourceImage = image;
    textEditorViewController.delegate = self;
    
    if (self.presentVC) {
        [self.presentVC pushViewController:textEditorViewController animated:YES];
    }

}
//*****************************************************************************
#pragma mark -
#pragma mark ** BEBSharingImageViewControllerDelegate **
- (void)bebSharingImageViewController:(BEBSharingImageViewController *)camViewController
                 dismissWithAnimation:(BOOL)animation;
{
    [self.navigationController popToViewController:self animated:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

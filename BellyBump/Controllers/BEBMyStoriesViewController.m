#import "BEBMyStoriesViewController.h"
#import "BEBNewStoryViewController.h"
#import "BEBMyStoriesCell.h"
#import "BEBDataManager.h"
#import "BEBStory.h"
#import "BEBStoriesDetailViewController.h"
#import "BEBCamViewController.h"
#import "BEBImage.h"
#import "BEBCreateVideoViewController.h"
#import "BEBSharingImageViewController.h"
#import "BEBNotificationViewController.h"
#import "BEBImageEditorViewController.h"
#import "BEBMyStoriesHeaderView.h"
#import "BEBAppDelegate.h"
#import "MBProgressHUD.h"

@interface BEBMyStoriesViewController ()<BEBMyStoriesCellDelegate, UIActionSheetDelegate>

#pragma mark - Properties
@property (nonatomic, strong) NSMutableArray *stories;
@property (nonatomic) NSInteger deletedStoryIdx;

@property (strong, nonatomic) IBOutlet UIButton *btnDeleteStory;
@property (strong, nonatomic) IBOutlet UIButton *btnFullScreen;
@property (weak, nonatomic) IBOutlet UIImageView *tip13ImageView;
@property (weak, nonatomic) IBOutlet UIButton *tip13Close;
@property (weak, nonatomic) IBOutlet UIImageView *tip11ImageView;
@property (weak, nonatomic) IBOutlet UIButton *tip11Close;


#pragma mark - IBOutlets
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

#pragma mark - IBActions
- (IBAction)btnFullScreenClicked:(id)sender;
- (IBAction)btnDeleteStoryClicked:(id)sender;
- (IBAction)tip13ButtonClick:(id)sender;
- (IBAction)tip11ButtonClick:(id)sender;

@end

@implementation BEBMyStoriesViewController

- (void)viewDidLoad;
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self filterStories];
    
    // Add notification reload data network turn on
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityDidChange:)
                                                 name:AFNetworkingReachabilityDidChangeNotification
                                               object:nil];
    
    CGFloat bottomInset = IS_IPHONE_6PLUS ? 56.0f : (IS_IPHONE_6 ? 52.0f : 0.0f);
    [self.collectionView setContentInset:UIEdgeInsetsMake(0, 0, bottomInset, 0)];
}

- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    
    BEBAppDelegate *appDelegate = (BEBAppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.localNotification) {
        
        NSNumber *storyId = ((BEBAppDelegate *)appDelegate).localNotification.userInfo[kStoryIdKey];
        for (NSInteger index = 0; index < self.stories.count; index++) {
            BEBStory *story = self.stories[index];
            if (story.storyId == [storyId integerValue]) {
                
                [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]
                                            atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                                    animated:NO];
                
                BEBStoriesDetailViewController *storiesDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:kStoriesDetailViewControllerIdentifier];
                storiesDetailVC.story = self.stories[index];
                
                [self.navigationController pushViewController:storiesDetailVC animated:NO];
                break;
            }
        }
    }
    else {
        [self.collectionView reloadData];
    }
}

- (void)viewDidAppear:(BOOL)animated;
{
    [super viewDidAppear:animated];
    
    // Load data from S3 if needed
    [self loadDataFromS3];
    
    
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"tip13Name"] isEqualToString:@"passed"]) {
        [self.tip13ImageView setHidden:YES];
        [self.tip13Close setHidden:YES];
    } else {
        [self.tip13ImageView setHidden:NO];
        [self.tip13Close setHidden:NO];
        CABasicAnimation *fadeInAnimate   = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeInAnimate.duration            = 3;
        fadeInAnimate.repeatCount         = 1;
        fadeInAnimate.autoreverses        = NO;
        fadeInAnimate.fromValue           = [NSNumber numberWithFloat:0.0];
        fadeInAnimate.toValue             = [NSNumber numberWithFloat:1.0];
        fadeInAnimate.removedOnCompletion = YES;
        [self.tip13ImageView.layer addAnimation:fadeInAnimate forKey:@"animateOpacity"];
        [self.tip13Close.layer addAnimation:fadeInAnimate forKey:@"animateOpacity"];
        [[NSUserDefaults standardUserDefaults] setObject:@"passed" forKey:@"tip13Name"];
    }
}

-(void)viewTip13
{
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"tip13Name"] isEqualToString:@"passed"]) {
        [self.tip13ImageView setHidden:YES];
        [self.tip13Close setHidden:YES];
        [self viewTip11];
    } else {
        [self.tip13ImageView setHidden:NO];
        [self.tip13Close setHidden:NO];
        CABasicAnimation *fadeInAnimate   = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeInAnimate.duration            = 3;
        fadeInAnimate.repeatCount         = 1;
        fadeInAnimate.autoreverses        = NO;
        fadeInAnimate.fromValue           = [NSNumber numberWithFloat:0.0];
        fadeInAnimate.toValue             = [NSNumber numberWithFloat:1.0];
        fadeInAnimate.removedOnCompletion = YES;
        [self.tip13ImageView.layer addAnimation:fadeInAnimate forKey:@"animateOpacity"];
        [self.tip13Close.layer addAnimation:fadeInAnimate forKey:@"animateOpacity"];
        [[NSUserDefaults standardUserDefaults] setObject:@"passed" forKey:@"tip13Name"];
    }
}

-(void)viewTip11{
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"tip11Name"] isEqualToString:@"passed"]) {
        [self.tip11ImageView setHidden:YES];
        [self.tip11Close setHidden:YES];
    } else {
        [self.tip11ImageView setHidden:NO];
        [self.tip11Close setHidden:NO];
        CABasicAnimation *fadeInAnimate   = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeInAnimate.duration            = 3;
        fadeInAnimate.repeatCount         = 1;
        fadeInAnimate.autoreverses        = NO;
        fadeInAnimate.fromValue           = [NSNumber numberWithFloat:0.0];
        fadeInAnimate.toValue             = [NSNumber numberWithFloat:1.0];
        fadeInAnimate.removedOnCompletion = YES;
        [self.tip11ImageView.layer addAnimation:fadeInAnimate forKey:@"animateOpacity"];
        [self.tip11Close.layer addAnimation:fadeInAnimate forKey:@"animateOpacity"];
        [[NSUserDefaults standardUserDefaults] setObject:@"passed" forKey:@"tip11Name"];
    }
    
}


- (void)didReceiveMemoryWarning;
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//*****************************************************************************
#pragma mark -
#pragma mark - ** Helper methods **
- (void)filterStories;
{
    self.stories = [NSMutableArray array];
    for (BEBStory *story in [BEBDataManager sharedManager].stories) {
        if ([self isPregnancyStories] != [story isPregnancy]) continue;
        [self.stories addObject:story];
    }
}

- (void)loadDataFromS3;
{
    BEBDataManager *dataManager = [BEBDataManager sharedManager];
    
    // Load data from S3
    if (![dataManager isExistedData]) {
        
        // Show indicator loading data
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
        hud.labelText = @"Loading...";
        
        __weak typeof(self) weakSelf = self;
        [dataManager getDataFromS3:^(BOOL result) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                BEBMyStoriesViewController *strongSelf = weakSelf;
                
                // Hide indicator
                [MBProgressHUD hideHUDForView:strongSelf.view.window animated:YES];
                
                // Reload data
                if (result) {
                    [strongSelf filterStories];
                    [strongSelf.collectionView reloadData];
                }
            });
        }];
    }
}

//*****************************************************************************
#pragma mark -
#pragma mark - ** UICollectionViewDataSource methods **

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
{
    return self.stories.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BEBMyStoriesCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kMyStoriesCellIdentifier forIndexPath:indexPath];
    
    cell.story = self.stories[indexPath.row];
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
        return CGSizeMake(148.0f, 171.0f);
    }
    else if (IS_IPHONE_6) {
        return CGSizeMake(172.0f, 198.0f);
    }
    else { // IS_IPHONE_6PLUS
        return CGSizeMake(190.0f, 220.0f);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section;
{
    if (IS_IPHONE_4 || IS_IPHONE_5) {
        return 20.0f;
    }
    else if (IS_IPHONE_6) {
        return 22.0f;
    }
    else { // IS_IPHONE_6PLUS
        return 25.0f;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        
        BEBMyStoriesHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kMyStoriesHeaderViewIdentifier forIndexPath:indexPath];
        
        if ([self isPregnancyStories]) {
            headerView.headerLabel.text = @"pregnancy pictures";
            [headerView.headerLabel setBackgroundColor:RGB(251, 236, 205, 1)];
        }
        else {
            headerView.headerLabel.text = @"newborn pictures";
            [headerView.headerLabel setBackgroundColor:RGB(223, 239, 246, 1)];
        }
        
        headerView.headerLabel.layer.cornerRadius = CGRectGetHeight(headerView.headerLabel.frame)/2;
        headerView.headerLabel.clipsToBounds = YES;
        
        reusableview = headerView;
    }
    
    return reusableview;
}

//*****************************************************************************
#pragma mark -
#pragma mark - ** BEBMyStoriesCellDelegate methods **
- (void)bebMyStoriesCell:(id)myStoriesCell didTouchOnDetailStoryAtIndex:(NSInteger)index;
{
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"tip13Name"] isEqualToString:@"passed"]) {
    }else{
        
        [self.tip13ImageView setHidden:YES];
        [self.tip13Close setHidden:YES];
        [[NSUserDefaults standardUserDefaults] setObject:@"passed" forKey:@"tip13Name"];

    }
    BEBStoriesDetailViewController *storiesDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:kStoriesDetailViewControllerIdentifier];
    storiesDetailVC.story = self.stories[index];
    
    [self.navigationController pushViewController:storiesDetailVC animated:YES];
}

- (void)bebMyStoriesCell:(id)myStoriesCell didDeleteStoryAtIndex:(NSInteger)index;
{
    // Cache story index for delete
    self.deletedStoryIdx = index;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.deletedStoryIdx inSection:0];
    BEBMyStoriesCell *cell = (BEBMyStoriesCell *)[self.collectionView cellForItemAtIndexPath:indexPath];

    CGRect frame = cell.frame;
    CGRect pFrame = self.collectionView.frame;
    frame.origin.x = pFrame.origin.x + frame.origin.x + frame.size.width - self.btnDeleteStory.frame.size.width;
    
    if (IS_IPHONE_4 || IS_IPHONE_5) {
        frame.origin.y = pFrame.origin.y + frame.origin.y + 70;
    }
    else if (IS_IPHONE_6) {
        frame.origin.y = pFrame.origin.y + frame.origin.y + 75;
    }
    else { // IS_IPHONE_6PLUS
        frame.origin.y = pFrame.origin.y + frame.origin.y + 75;
    }
    frame.size = self.btnDeleteStory.frame.size;
    
    self.btnDeleteStory.frame = frame;
    [self.btnDeleteStory setHidden:NO];
    [self.btnFullScreen setHidden:NO];
    
    return;
    
    // Show alert message to confirm delete
    if (iOS_Version >= 8) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:kConfirmDeleteStoryMessage
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action) {
                                                           [self alertView:nil clickedButtonAtIndex:1];
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

//*****************************************************************************
#pragma mark -
#pragma mark - ** UIAlertViewDelegate methods **
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    // Reset delete story animation
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.deletedStoryIdx inSection:0];
    BEBMyStoriesCell *cell = (BEBMyStoriesCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    [cell resetDeleteStoryAnimation];
    
    // Delete selected story
    if (buttonIndex == 0) {
        
        [self.collectionView performBatchUpdates:^{
            
            BEBStory *deleteStory = self.stories[self.deletedStoryIdx];
            
            // Update local data model
            [self.stories removeObjectAtIndex:self.deletedStoryIdx];
            [[BEBDataManager sharedManager].stories removeObject:deleteStory];
            [[BEBDataManager sharedManager].deletedImages addObjectsFromArray:deleteStory.photos];
            
            // Cancel local notification for deleted story
            [[BEBDataManager sharedManager] cancelLocalNotificationForStory:deleteStory];
            
            // Delete item on collection view
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.deletedStoryIdx inSection:0];
            [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
            
            // Delete images for story from S3
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                // Save story data to file to cache local
                [[BEBDataManager sharedManager] saveStoryDataToFile];
                [[BEBDataManager sharedManager] saveDeletedImagesToFile];
                [deleteStory deleteImagesLocal];
                
                // Save data to S3
                [[BEBDataManager sharedManager] saveDataToS3:nil];
                [[BEBDataManager sharedManager] syncDeletedImagesToS3];
            });
            
        } completion:^(BOOL finished) {
            
            [self.collectionView reloadData];
        }];
    }
}

//*****************************************************************************
#pragma mark -
#pragma mark - ** Notification Reachability Did Change **
- (void)reachabilityDidChange:(NSNotification *)notification;
{
    AFNetworkReachabilityStatus status = [notification.userInfo[AFNetworkingReachabilityNotificationStatusItem] integerValue];
    if (status == AFNetworkReachabilityStatusReachableViaWWAN ||
        status == AFNetworkReachabilityStatusReachableViaWiFi) {
        
        [self loadDataFromS3];
    }
}

- (IBAction)btnFullScreenClicked:(id)sender {
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"tip13Name"] isEqualToString:@"passed"]) {
        [self.tip13ImageView setHidden:YES];
        [self.tip13Close setHidden:YES];
    } else {
        [self.tip13ImageView setHidden:NO];
        [self.tip13Close setHidden:NO];
    }
    
    [self.btnFullScreen setHidden:YES];
    [self.btnDeleteStory setHidden:YES];
}
- (IBAction)btnDeleteStoryClicked:(id)sender {
    [self.btnDeleteStory setHidden:YES];
    [self.btnFullScreen setHidden:YES];
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"tip13Name"] isEqualToString:@"passed"]) {
        [self.tip13ImageView setHidden:YES];
        [self.tip13Close setHidden:YES];
    } else {
        [self.tip13ImageView setHidden:NO];
        [self.tip13Close setHidden:NO];
        CABasicAnimation *fadeInAnimate   = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeInAnimate.duration            = 3;
        fadeInAnimate.repeatCount         = 1;
        fadeInAnimate.autoreverses        = NO;
        fadeInAnimate.fromValue           = [NSNumber numberWithFloat:0.0];
        fadeInAnimate.toValue             = [NSNumber numberWithFloat:1.0];
        fadeInAnimate.removedOnCompletion = YES;
        [self.tip13ImageView.layer addAnimation:fadeInAnimate forKey:@"animateOpacity"];
        [self.tip13Close.layer addAnimation:fadeInAnimate forKey:@"animateOpacity"];
    }
    
    if (iOS_Version >= 8) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:kConfirmDeleteStoryMessage
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action) {
                                                           [self alertView:nil clickedButtonAtIndex:1];
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

- (IBAction)tip13ButtonClick:(id)sender {
    [self.tip13ImageView setHidden:YES];
    [self.tip13Close setHidden:YES];
    [[NSUserDefaults standardUserDefaults] setObject:@"passed" forKey:@"tip13Name"];
    [self viewTip11];
}

- (IBAction)tip11ButtonClick:(id)sender {
    [self.tip11ImageView setHidden:YES];
    [self.tip11Close setHidden:YES];
    [[NSUserDefaults standardUserDefaults] setObject:@"passed" forKey:@"tip11Name"];
}
@end

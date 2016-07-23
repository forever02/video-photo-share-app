#import "BEBMyStoriesCell.h"
#import "BEBDataManager.h"
#import "BEBStory.h"
#import "BEBImage.h"
#import "BEBUtilities.h"

@interface BEBMyStoriesCell()

#pragma mark - Properties
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, copy) NSString *thumbnailURL;

#pragma mark - IBOutlets
@property (weak, nonatomic) IBOutlet UIImageView *thumbImageView;
@property (weak, nonatomic) IBOutlet UILabel *storyNameLabel;


#pragma mark - IB Actions

@end

@implementation BEBMyStoriesCell

- (void)awakeFromNib;
{
    // Initialization code
    [self.thumbImageView setBackgroundColor:RGB(199, 224, 228, 1)];
    self.thumbImageView.layer.cornerRadius = CGRectGetHeight(self.thumbImageView.frame) / 2;
    self.thumbImageView.clipsToBounds = YES;
    
    self.storyNameLabel.layer.cornerRadius = CGRectGetHeight(self.storyNameLabel.frame) / 2;
    self.storyNameLabel.clipsToBounds = YES;
    
    // Add UITapGestureRecognizer allow user touch content view and go to detail page
    [self.contentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                   action:@selector(touchDetailStory:)]];
    
    // Add long press guesture recognize
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                               initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [self.contentView addGestureRecognizer:longPress];
    
    // Add loading indicator for imageview
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.loadingIndicator.center = CGPointMake(CGRectGetWidth(self.thumbImageView.frame)/2, CGRectGetHeight(self.thumbImageView.frame)/2);
    self.loadingIndicator.hidesWhenStopped = YES;
    [self addSubview:self.loadingIndicator];
}

- (void)setStory:(BEBStory *)story;
{
    _story = story;
    
    self.thumbnailURL = nil;
    self.thumbImageView.image = nil;
    self.storyNameLabel.text = story.title;
    
    if ([story isPregnancy]) {
        [self.storyNameLabel setBackgroundColor:RGB(250, 218, 229, 1)];
    }
    else {
        [self.storyNameLabel setBackgroundColor:RGB(254, 247, 223, 1)];
    }
    
    [self.loadingIndicator stopAnimating];
    
    // Load lastest image
    if (story.photos.count > 0) {
        
        BEBImage *bebImage = [story.photos firstObject];
        
        // Set thumbnail image URL
        self.thumbnailURL = [NSString stringWithFormat:@"%@/%@", [BEBUtilities userCacheDirectory], bebImage.localPath];
        
        UIImage *image = bebImage.image;
        if (!image) {
            
            // Start loading indicator
            [self.loadingIndicator startAnimating];
            
            // Download image from S3
            __weak typeof(self) weakSelf = self;
            [bebImage getImageFromS3:^(NSString *url) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    BEBMyStoriesCell *strongSelf = weakSelf;
                    if ([strongSelf.thumbnailURL isEqualToString:url]) {
                        strongSelf.thumbImageView.image = bebImage.image;
                        [strongSelf.loadingIndicator stopAnimating];
                    }
                });
            }];
        }
        else {
            self.thumbImageView.image = image;
        }
    }
}

//*****************************************************************************
#pragma mark -
#pragma mark - ** UITapGestureRecognizer method **
- (void)touchDetailStory:(UITapGestureRecognizer *)gestureRecognizer;
{
    if ([self.delegate respondsToSelector:@selector(bebMyStoriesCell:didTouchOnDetailStoryAtIndex:)]) {
        [self.delegate bebMyStoriesCell:self didTouchOnDetailStoryAtIndex:self.indexPath.row];
    }
}

- (void)longPressGestureRecognized:(id)sender;
{
    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
    UIGestureRecognizerState state = longPress.state;
    
    if (state == UIGestureRecognizerStateBegan) {
        
        if ([self.delegate respondsToSelector:@selector(bebMyStoriesCell:didDeleteStoryAtIndex:)]) {
            
            // Perform action on delegate
            [self.delegate bebMyStoriesCell:self didDeleteStoryAtIndex:self.indexPath.row];
            
            // Make delete story animation
            CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
            [anim setToValue:[NSNumber numberWithFloat:0.0f]];
            [anim setFromValue:[NSNumber numberWithDouble:M_PI/36]]; // rotation angle
            [anim setDuration:0.1];
            [anim setRepeatCount:NSUIntegerMax];
            [anim setAutoreverses:YES];
            
            [[self.thumbImageView layer] addAnimation:anim forKey:kThumbnailImageViewAnimationKey];
        }
    }
}

- (void)resetDeleteStoryAnimation;
{
    [[self.thumbImageView layer] removeAnimationForKey:kThumbnailImageViewAnimationKey];
}

@end

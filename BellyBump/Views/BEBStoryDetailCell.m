#import "BEBStoryDetailCell.h"
#import "BEBImage.h"

@interface BEBStoryDetailCell()

@property (nonatomic, copy) NSString *thumbnailURL;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;

@property (weak, nonatomic) IBOutlet UIImageView *deleteImageView;

#pragma mark - IB Actions
- (IBAction)deleteButtonDidTouch:(id)sender;

@end

@implementation BEBStoryDetailCell

- (void)awakeFromNib;
{
    [super awakeFromNib];
    
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.loadingIndicator.center = CGPointMake(CGRectGetWidth(self.thumbImageView.frame)/2, CGRectGetHeight(self.thumbImageView.frame)/2);
    self.loadingIndicator.hidesWhenStopped = YES;
    [self addSubview:self.loadingIndicator];
}

- (void)setThumbnailImage:(BEBImage *)bebImage;
{
    UIImage *image = bebImage.image;
    if (!image) {
        
        // Start loading indicator
        [self.loadingIndicator startAnimating];
        
        // Set thumbnail image URL
        self.thumbnailURL = [NSString stringWithFormat:@"%@/%@", [BEBUtilities userCacheDirectory], bebImage.localPath];
        
        // Download image from S3
        __weak typeof(self) weakSelf = self;
        [bebImage getImageFromS3:^(NSString *url) {
            dispatch_async(dispatch_get_main_queue(), ^{
                BEBStoryDetailCell *strongSelf = weakSelf;
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

- (IBAction)deleteButtonDidTouch:(id)sender;
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(bebStoryDetailCell:didTouchOnDeleteButtonAtIndex:)]) {
        [self.delegate bebStoryDetailCell:self didTouchOnDeleteButtonAtIndex:self.indexPath.row];
    }
}

- (void)markThumbnailImageSelected:(BOOL)isSelected;
{
    if (isSelected) {
        
        self.deleteImageView.image = self.thumbImageView.image;
        CGRect thumbImageFrame = self.thumbImageView.frame;
        
        [UIView animateWithDuration:0.1 animations:^{
            
            self.thumbImageView.frame = self.deleteImageView.frame;
            
        } completion:^(BOOL finished) {
            
            [self.thumbImageView setHidden:YES];
            [self.deleteImageView setHidden:NO];
            self.thumbImageView.frame = thumbImageFrame;
        }];
        
        CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        [anim setToValue:[NSNumber numberWithFloat:0.0f]];
        [anim setFromValue:[NSNumber numberWithDouble:M_PI/36]]; // rotation angle
        [anim setDuration:0.1];
        [anim setRepeatCount:NSUIntegerMax];
        [anim setAutoreverses:YES];
        
        [[self.deleteImageView layer] addAnimation:anim forKey:kThumbnailImageViewAnimationKey];
    }
    else {
        [[self.deleteImageView layer] removeAnimationForKey:kThumbnailImageViewAnimationKey];
        
        [self.deleteImageView setHidden:YES];
        [self.thumbImageView setHidden:NO];
    }
}

@end

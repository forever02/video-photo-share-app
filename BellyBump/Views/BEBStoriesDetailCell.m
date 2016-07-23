#import "BEBStoriesDetailCell.h"
#import "BEBImage.h"

@interface BEBStoriesDetailCell()

@property (nonatomic, strong) BEBImage *image;
@property (nonatomic, copy) NSString *thumbnailURL;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *openCameraButton;
@property (weak, nonatomic) IBOutlet UIButton *openLibraryButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)openCameraButtonDidTouch:(id)sender;
- (IBAction)openLibraryButtonDidTouch:(id)sender;

@end

@implementation BEBStoriesDetailCell

- (void)awakeFromNib;
{
    [super awakeFromNib];
    
    self.imageView.layer.cornerRadius = CGRectGetHeight(self.imageView.frame) / 2;
    self.imageView.clipsToBounds = YES;
    
    // Add UITapGestureRecognizer allow user touch imageview to go to detail page
    [self.imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(imageViewDidTouch:)]];
    [self.imageView setUserInteractionEnabled:YES];
}

- (void)setThumbnailImage:(BEBImage *)bebImage;
{
    self.image = bebImage;
    [self.openCameraButton setHidden:YES];
    [self.openLibraryButton setHidden:YES];
    [self.activityIndicator stopAnimating];
    
    if (!bebImage) {
        [self.imageView setImage:[UIImage imageNamed:@"img_new_photo"]];
        [self.imageView setContentMode:UIViewContentModeCenter];
        self.thumbnailURL = nil;
    }
    else {
        // Set thumbnail image URL
        self.thumbnailURL = [NSString stringWithFormat:@"%@/%@", [BEBUtilities userCacheDirectory], bebImage.localPath];
        [self.imageView setContentMode:UIViewContentModeScaleAspectFill];
        UIImage *image = bebImage.image;
        if (!image) {
            
            self.imageView.image = nil;
            
            // Start loading indicator
            [self.activityIndicator startAnimating];
            
            // Download image from S3
            __weak typeof(self) weakSelf = self;
            [bebImage getImageFromS3:^(NSString *url) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    BEBStoriesDetailCell *strongSelf = weakSelf;
                    if ([strongSelf.thumbnailURL isEqualToString:url]) {
                        strongSelf.imageView.image = bebImage.image;
                        [strongSelf.activityIndicator stopAnimating];
                    }
                });
            }];
        }
        else {
            self.imageView.image = image;
        }
    }
}

//*****************************************************************************
#pragma mark -
#pragma mark - ** UITapGestureRecognizer method **
- (void)imageViewDidTouch:(UITapGestureRecognizer *)gestureRecognizer;
{
    if (!self.image) {
        self.imageView.image = nil;
        [self.openCameraButton setHidden:NO];
        [self.openLibraryButton setHidden:NO];
    }
    else if ([self.delegate respondsToSelector:@selector(bebStoriesDetailCell:didTouchOnPhotoAtIndex:)]) {
        [self.delegate bebStoriesDetailCell:self didTouchOnPhotoAtIndex:self.indexPath.row];
    }
}

- (IBAction)openCameraButtonDidTouch:(id)sender;
{
    if ([self.delegate respondsToSelector:@selector(bebStoriesDetailCellClickOpenCamera:)]) {
        [self.delegate bebStoriesDetailCellClickOpenCamera:self];
    }
}

- (IBAction)openLibraryButtonDidTouch:(id)sender;
{
    if ([self.delegate respondsToSelector:@selector(bebStoriesDetailCellClickOpenLibrary:)]) {
        [self.delegate bebStoriesDetailCellClickOpenLibrary:self];
    }
}

@end

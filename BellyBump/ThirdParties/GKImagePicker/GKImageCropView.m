
#import "GKImageCropView.h"
#import "GKImageCropOverlayView.h"
#import "GKResizeableCropOverlayView.h"

#import <QuartzCore/QuartzCore.h>

#define rad(angle) ((angle) / 180.0 * M_PI)

static CGRect GKScaleRect(CGRect rect, CGFloat scale)
{
	return CGRectMake(rect.origin.x * scale, rect.origin.y * scale, rect.size.width * scale, rect.size.height * scale);
}

@interface GKImageCropView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) GKImageCropOverlayView *cropOverlayView;

- (CGRect)_calcVisibleRectForResizeableCropArea;
- (CGAffineTransform)_orientationTransformedRectOfImage:(UIImage *)image;

@end

@implementation GKImageCropView

#pragma mark -
#pragma Getter/Setter

@synthesize scrollView, imageView, cropOverlayView;

- (void)setImageToCrop:(UIImage *)imageToCrop
{
    self.imageView.image = imageToCrop;
    
    UIEdgeInsets edgeInset = self.scrollView.contentInset;
    edgeInset.left = edgeInset.right = kBorderTopCorrectionValue;
    edgeInset.top = edgeInset.bottom = kBorderCorrectionValue;
    self.scrollView.contentInset = edgeInset;
    
    float imageW = imageToCrop.size.width;
    float imageH = imageToCrop.size.height;
    float scrollW = CGRectGetWidth(self.scrollView.frame) + 2;
    float scrollH = CGRectGetHeight(self.scrollView.frame) - kHandleDiameter;
    
    // Set minimum zoom scale to fit image with image view
    float hfactor = scrollW / imageW;
    float vfactor = scrollH / imageH;
    if (scrollW > imageW) hfactor = 1.0;
    if (scrollH > imageH) vfactor = 1.0;
    self.scrollView.minimumZoomScale = fmin(hfactor, vfactor);
    
    // Set content size for scrolling
    float scale = self.scrollView.zoomScale;
    self.scrollView.contentSize = CGSizeMake(scale * imageW, scale * imageH);
    
    // Set content offset to center image in scroll view
    CGPoint offset = CGPointZero;
    CGSize contentSize = self.scrollView.contentSize;
    if (contentSize.width > scrollW) {
        offset.x = (contentSize.width - scrollW) / 2;
    }
    if (contentSize.height > scrollH) {
        offset.y = (contentSize.height - scrollH) / 2;
    }
    self.scrollView.contentOffset = offset;
    
    // Set frame for image view to fit with image size
    CGRect frame = self.imageView.frame;
    frame.size = CGSizeMake(imageW, imageH);
    self.imageView.frame = frame;
    
    // Set current scale image to minimum
    [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:NO];
    
    // adjust center imageview
    [self adjustCenterImageView];
}

- (UIImage *)imageToCrop
{
    return self.imageView.image;
}

- (void)setCropSize:(CGSize)cropSize
{
    if (self.cropOverlayView == nil) {
        self.cropOverlayView = [[GKResizeableCropOverlayView alloc] initWithFrame:self.bounds
                                                            andInitialContentSize:CGSizeMake(cropSize.width, cropSize.height)];
        self.cropOverlayView.cropAvatar = self.isCropAvatar;
        [self addSubview:self.cropOverlayView];
    }
    self.cropOverlayView.cropSize = cropSize;
}

- (CGSize)cropSize
{
    return self.cropOverlayView.cropSize;
}

#pragma mark -
#pragma Public Methods

- (UIImage *)croppedImage
{
    //Calculate rect that needs to be cropped
    CGRect visibleRect = [self _calcVisibleRectForResizeableCropArea];
    
    //transform visible rect to image orientation
    CGAffineTransform rectTransform = [self _orientationTransformedRectOfImage:self.imageToCrop];
    visibleRect = CGRectApplyAffineTransform(visibleRect, rectTransform);
    
    //finally crop image
    CGImageRef imageRef = CGImageCreateWithImageInRect([self.imageToCrop CGImage], visibleRect);
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:self.imageToCrop.scale orientation:self.imageToCrop.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}

- (CGRect)_calcVisibleRectForResizeableCropArea
{
    GKResizeableCropOverlayView *resizeableView = (GKResizeableCropOverlayView*)self.cropOverlayView;
    
    //first of all, get the size scale by taking a look at the real image dimensions. Here it doesn't matter if you take
    //the width or the hight of the image, because it will always be scaled in the exact same proportion of the real image
    CGFloat sizeScale = self.imageView.image.size.width / self.imageView.frame.size.width;
    sizeScale *= self.scrollView.zoomScale;
    
    //then get the postion of the cropping rect inside the image
    CGRect visibleRect = [resizeableView.contentView convertRect:resizeableView.contentView.bounds toView:imageView];
    return visibleRect = GKScaleRect(visibleRect, sizeScale);
}

- (CGAffineTransform)_orientationTransformedRectOfImage:(UIImage *)img
{
	CGAffineTransform rectTransform;
	switch (img.imageOrientation)
	{
		case UIImageOrientationLeft:
			rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(90)), 0, -img.size.height);
			break;
		case UIImageOrientationRight:
			rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-90)), -img.size.width, 0);
			break;
		case UIImageOrientationDown:
			rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-180)), -img.size.width, -img.size.height);
			break;
		default:
			rectTransform = CGAffineTransformIdentity;
	};
	
	return CGAffineTransformScale(rectTransform, img.scale, img.scale);
}

#pragma mark -
#pragma Override Methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor whiteColor];
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.delegate = self;
        self.scrollView.clipsToBounds = NO;
        self.scrollView.decelerationRate = 0.0; 
        self.scrollView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.scrollView];
        
        self.imageView = [[UIImageView alloc] initWithFrame:self.scrollView.frame];
        self.imageView.contentMode = UIViewContentModeCenter;
        self.imageView.backgroundColor = [UIColor whiteColor];
        [self.scrollView addSubview:self.imageView];
        
        self.scrollView.maximumZoomScale = 5.0;
        [self.scrollView setZoomScale:1.0];
        
        self.scrollView.scrollIndicatorInsets = self.scrollView.contentInset;
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    GKResizeableCropOverlayView* resizeableCropView = (GKResizeableCropOverlayView*)self.cropOverlayView;
    CGRect outerFrame = CGRectInset(resizeableCropView.cropBorderView.frame, -15, -15);
    
    if (CGRectContainsPoint(outerFrame, point)) {
        
        CGRect innerTouchFrame = CGRectInset(resizeableCropView.cropBorderView.frame, 30, 30);
        if (CGRectContainsPoint(innerTouchFrame, point))
            return self.scrollView;
        
        return [super hitTest:point withEvent:event];
    }
    
    if (CGRectContainsPoint(self.bounds, point)) {
        return self.scrollView;
    } else {
        return [super hitTest:point withEvent:event];
    }
}

#pragma mark -
#pragma UIScrollViewDelegate Methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    // adjust center imageview
    [self adjustCenterImageView];
}

- (void)adjustCenterImageView
{
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect frameToCenter = self.imageView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width - kHandleDiameter)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width - kHandleDiameter) / 2.0;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height - kHandleDiameter)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height - kHandleDiameter) / 2.0;
    else
        frameToCenter.origin.y = 0;
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.imageView.frame = frameToCenter;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)dealloc;
{
    self.scrollView.delegate = nil;
}

@end

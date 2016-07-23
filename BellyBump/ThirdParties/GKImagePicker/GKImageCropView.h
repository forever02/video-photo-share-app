
#import <UIKit/UIKit.h>

@interface GKImageCropView : UIView

@property (nonatomic, strong) UIImage *imageToCrop;
@property (nonatomic, assign) CGSize cropSize;

@property (nonatomic, getter = isCropAvatar) BOOL cropAvatar;

- (UIImage *)croppedImage;

@end

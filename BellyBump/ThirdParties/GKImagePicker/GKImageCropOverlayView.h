
#import <UIKit/UIKit.h>

@interface GKImageCropOverlayView : UIView

@property (nonatomic, assign) CGSize cropSize; //size of the cropped image
@property (nonatomic, getter = isCropAvatar) BOOL cropAvatar;

@end

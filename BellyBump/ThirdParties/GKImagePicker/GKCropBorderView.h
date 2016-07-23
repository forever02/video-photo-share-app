
#import <UIKit/UIKit.h>

#define kBorderCorrectionValue 10
#define kBorderTopCorrectionValue 0

#define kHandleDiameter (kBorderCorrectionValue*2)

@interface GKCropBorderView : UIView

@property (nonatomic, getter = isCropAvatar) BOOL cropAvatar;

@end

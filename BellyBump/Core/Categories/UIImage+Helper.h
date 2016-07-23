
#import <UIKit/UIKit.h>

@interface UIImage (Helper)

typedef enum {
    ImageScalingModeFill = 0, // Scale the image to fill the given size by changing the aspect ratio of the image if necessary
    ImageScalingModeAspectFit, // Scale the image to fit the given size by maintaining the ratio aspect. The result image may be smaller than the given size
    ImageScalingModeAspectCenter, // Scale the image to wrap the rectangle coresponding to the given size without changing aspect ration and center the scaled image with the rectangle. Any portions of the image are outside the rectangle will be clipped
    ImageScalingModeAspectTopLeft, // The scaled image aligned in the top-left corner of the retangle
    ImageScalingModeAspectBottonRight, // The scaled image aligned in the bottom-right corner of the retangle
} ImageScalingMode;


/**
 * Returns a image scaled to a given size from the receiver image with a given scaling mode.
 * @param |size| The size to scale to
 * @param |scalingMode| The scaling mode to be used
 */
- (UIImage *)imageByScalingToSize:(CGSize)size scalingMode:(ImageScalingMode)scalingMode;

- (UIImage *)createImageWithMask:(UIImage *)maskImage;

+ (UIImage *)imageWithColor:(UIColor *)color;

@end

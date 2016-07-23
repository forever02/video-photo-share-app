#import "UIImage+Helper.h"

@implementation UIImage (Helper)

- (UIImage *)createImageWithMask:(UIImage *)maskImage;
{
    
	CGImageRef maskRef = maskImage.CGImage;
    
	CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
	CGImageRef masked = CGImageCreateWithMask([self CGImage], mask);
    
    UIImage *image = [UIImage imageWithCGImage:masked];
    
    CGImageRelease(mask);
    CGImageRelease(masked);
    
	return image;
}

- (UIImage *)imageByScalingToSize:(CGSize)size scalingMode:(ImageScalingMode)scalingMode;
{
    // If the size is zero size, return nil.
    if (size.width == 0 || size.height == 0 || !self) {
        return nil;
    }
    
    // Figure out the rectangle to projecting the image on
    CGFloat newWidth;
    CGFloat newHeight;
    CGPoint origin;
    
    CGSize newSize = size;
    // Calculate the size of projection rectangle
    if (scalingMode == ImageScalingModeFill) {
        newWidth = floorf(size.width);
        newHeight = floorf(size.height);
    }
    else if (scalingMode == ImageScalingModeAspectFit) {
        CGFloat r = MIN(size.width/self.size.width, size.height/self.size.height);
        newWidth = floorf(r * self.size.width);
        newHeight = floorf(r * self.size.height);
        newSize = CGSizeMake(newWidth, newHeight);
    }
    else {
        CGFloat r = MAX(size.width/self.size.width, size.height/self.size.height);
        newWidth = floorf(r * self.size.width);
        newHeight = floorf(r * self.size.height);
    }
    
    // Origin of the projection rectangle
    switch (scalingMode) {
        case ImageScalingModeAspectFit:
        case ImageScalingModeAspectCenter:
            origin.x = round(size.width - newWidth)/2;
            origin.y = round(size.height - newHeight)/2;
            break;
            
        case ImageScalingModeAspectBottonRight:
            origin.x = round(size.width - newWidth);
            origin.y = round(size.height - newHeight);
            break;
            
        case ImageScalingModeAspectTopLeft:
        case ImageScalingModeFill:
        default:
            origin.x = 0;
            origin.y = 0;
            break;
    }
    
    // Create a transparent bitmap context with a scaling factor
    // equal to that of the screen
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
    
    // Create a path that is a rectangle
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, size.width, size.height)
                                                    cornerRadius:0];
    
    // Make all subsequent drawing clip to this rectangle
    [path addClip];
    
    // Rectangle to draw the image on
    CGRect projectRect;
    projectRect.origin = origin;
    projectRect.size.width = newWidth;
    projectRect.size.height = newHeight;
    
    // Draw the image on the projection rectangle
    [self drawInRect:projectRect];
    
    // Get the image from the image context
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    
    // Close the image context
    UIGraphicsEndImageContext();
    
    return result;
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end

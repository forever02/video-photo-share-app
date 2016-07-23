#import <Foundation/Foundation.h>

@interface ImageFilter : NSObject

- (UIImage *)gpuImageFromImage:(UIImage *)sourceImage withType:(GPUImageShowcaseFilterType)filterType;


@end

#import <Foundation/Foundation.h>

// The BEBUtilities file contains helper methods.
@interface BEBUtilities : NSObject

#pragma mark ** Directory utilities helper functions **
// Get caching directory for caching data.
// Return cache directory string.
+ (NSString *)userCacheDirectory;

+ (const char*)getFileName:(char *)filePath;

+ (NSString *)getUUID;

+ (UIImage *)fixedRotation:(UIImage *)image;

+ (UIImage *)scaleImage:(UIImage *)image
            scaleFactor:(CGFloat)scaleBy;

+(UIImage*) drawText:(NSString*) text
             inImage:(UIImage*) image
             atPoint:(CGPoint) point
                font:(UIFont *) font
               color:(UIColor *)color;

+ (CGSize)videoSizeByIndex:(NSInteger)index;

+ (UIImage *)croppedImage:(UIImage *)image
              visibleRect:(CGRect)visibleRect;

+ (UIViewController *)topViewController:(UIViewController *)rootViewController;

+ (UIImage *)generateWatermarkForImage:(UIImage *)image;

+ (NSString *)dateStringFromDate:(NSDate *)date;

+ (NSNumber *)weekdayFromDate:(NSDate *)date;

+ (void)loadImageFromAssertByUrl:(NSURL *)url completion:(void (^)(UIImage*)) completion;

@end


#import "BEBUtilities.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation BEBUtilities

//*****************************************************************************
#pragma mark -
#pragma mark ** Directory utilities helper **

+ (NSString *)userCacheDirectory;
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}


//*****************************************************************************
#pragma mark -
#pragma mark ** Helper methods support for caching data **

+ (const char*)getFileName:(char *)filePath;
{
    NSString *fullFilePath = [[NSString alloc] initWithBytes:filePath length:strlen(filePath) encoding:NSUTF8StringEncoding];
    const char* fileName  = [[fullFilePath lastPathComponent] UTF8String];
    
    return fileName;
}

+ (NSString *)getUUID
{
    CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
    NSString * uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
    CFRelease(newUniqueId);
    
    return uuidString;
}


+ (UIImage *)fixedRotation:(UIImage *)image;
{
    if (image.imageOrientation == UIImageOrientationUp) return image;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

+ (UIImage *)scaleImage:(UIImage *)image
            scaleFactor:(CGFloat)scaleBy;
{
    CGSize size = CGSizeMake(image.size.width *scaleBy, image.size.height *scaleBy);
    
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    transform = CGAffineTransformScale(transform, scaleBy, scaleBy);
    CGContextConcatCTM(context, transform);
    
    // Draw the image into the transformed context and return the image
    [image drawAtPoint:CGPointMake(0.0f, 0.0f)];
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newimg;
}

+(UIImage*) drawText:(NSString*) text
             inImage:(UIImage*) image
             atPoint:(CGPoint) point
             font:(UIFont *) font
               color:(UIColor *)color
{
    
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    
    [[UIColor whiteColor] set];
    
    NSDictionary *attributes = @{NSFontAttributeName:font,
                                 NSForegroundColorAttributeName: color};
    [text drawAtPoint:point withAttributes:attributes];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)croppedImage:(UIImage *)image
              visibleRect:(CGRect)visibleRect
{
    
    //finally crop image
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], visibleRect);
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}

+ (CGSize)videoSizeByIndex:(NSInteger)index;
{
    
    CGRect rect =[UIScreen mainScreen].bounds;
    NSUInteger width = CGRectGetWidth(rect);
    NSUInteger height = CGRectGetHeight(rect);
    
    int scaleValue = [UIScreen mainScreen].scale;
    
    switch (index) {
        case 0:
        {
            return CGSizeMake(width, height);
        }
        case 1:
        {
            CGFloat w = round(width * scaleValue / 16.0f) * 16;
            CGFloat h = round(height * scaleValue / 16.0f) * 16;
            if (w <= 0) w = (width * scaleValue / 16) * 16;
            if (h <= 0) h = (height * scaleValue / 16) * 16;
            return CGSizeMake(w, h);
        }
            
        case 2:
            return CGSizeMake(1280.0f, 720.0f);
            
        default:
            return CGSizeMake(1920.0f, 1080.0f);
    }
}

+ (UIViewController *)topViewController:(UIViewController *)rootViewController;
{
    if (!rootViewController.presentedViewController) {
        return rootViewController;
    }
    
    if ([rootViewController.presentedViewController isMemberOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *topViewController = navigationController.topViewController;
        return [self topViewController:topViewController];
    }
    
    UIViewController *presentedViewController = rootViewController.presentedViewController;
    return [self topViewController:presentedViewController];
}

+ (UIImage *)generateWatermarkForImage:(UIImage *)image;
{
    UIImage *watermarkImage = [UIImage imageNamed:@"watermark"];
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -image.size.height);
//    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    CGContextDrawImage(ctx, CGRectMake(0, 0, image.size.width, image.size.height), image.CGImage);
//    CGContextSetAlpha(ctx, 0.7f);
    CGContextDrawImage(ctx, CGRectMake(image.size.width - watermarkImage.size.width - 20.0f, 0.0f, watermarkImage.size.width, watermarkImage.size.height), watermarkImage.CGImage);
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

+ (NSString *)dateStringFromDate:(NSDate *)date;
{
    static NSDateFormatter *df = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        df = [[NSDateFormatter alloc] init];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        [df setDateFormat:@"M.d.yyyy"];
        [df setLocale:locale];
    });
    
    return [df stringFromDate:date];
}

+ (NSNumber *)weekdayFromDate:(NSDate *)date;
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:date];
    NSInteger weekday = [comps weekday];
    return @(weekday);
}

+(void) loadImageFromAssertByUrl:(NSURL *)url completion:(void (^)(UIImage*)) completion{
    ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
    [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        Byte *buffer = (Byte*)malloc(rep.size);
        NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
        NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
        UIImage* img = [UIImage imageWithData:data];
        completion(img);
    } failureBlock:^(NSError *err) {
        NSLog(@"Error: %@",[err localizedDescription]);
    }];
}
@end

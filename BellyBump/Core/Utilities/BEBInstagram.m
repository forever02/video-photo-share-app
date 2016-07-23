#import "BEBInstagram.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface BEBInstagram () {
    UIDocumentInteractionController *documentInteractionController;
}

@property (nonatomic) NSString *photoFileName;

@end

@implementation BEBInstagram

NSString* const kInstagramAppURLString = @"instagram://app";
NSString* const kInstagramOnlyPhotoFileName = @"tempinstgramphoto.igo";

+ (instancetype)sharedInstance
{
    static BEBInstagram* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BEBInstagram alloc] init];
    });
    return sharedInstance;
}

- (id)init;
{
    if (self = [super init]) {
        self.photoFileName = kInstagramOnlyPhotoFileName;
    }
    return self;
}

+ (void)setPhotoFileName:(NSString*)fileName;
{
    [BEBInstagram sharedInstance].photoFileName = fileName;
}

+ (NSString*)photoFileName;
{
    return [BEBInstagram sharedInstance].photoFileName;
}

+ (BOOL)isAppInstalled;
{
    NSURL *appURL = [NSURL URLWithString:kInstagramAppURLString];
    return [[UIApplication sharedApplication] canOpenURL:appURL];
}

// Technically the instagram allows for photos to be published under the size of 612x612
// BUT if you want nice quality pictures, I recommend checking the image size.
+ (BOOL)isImageCorrectSize:(UIImage*)image;
{
    CGImageRef cgImage = [image CGImage];
    return (CGImageGetWidth(cgImage) >= 612 && CGImageGetHeight(cgImage) >= 612);
}

- (NSString*)photoFilePath;
{
    return [NSString stringWithFormat:@"%@/%@",[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], self.photoFileName];
}

+ (void)postImage:(UIImage*)image inView:(UIView*)view;
{
    [self postImage:image withCaption:nil inView:view];
}

+ (void)postImage:(UIImage*)image withCaption:(NSString*)caption inView:(UIView*)view;
{
    [self postImage:image withCaption:caption inView:view delegate:nil];
}

+ (void)postImage:(UIImage*)image withCaption:(NSString*)caption inView:(UIView*)view delegate:(id<UIDocumentInteractionControllerDelegate>)delegate;
{
    [[BEBInstagram sharedInstance] postImage:image withCaption:caption inView:view delegate:delegate];
}

- (void)postImage:(UIImage*)image withCaption:(NSString*)caption inView:(UIView*)view delegate:(id<UIDocumentInteractionControllerDelegate>)delegate
{
    if (!image) {
        [NSException raise:NSInternalInconsistencyException format:@"Image cannot be nil!"];
    }
    
    [UIImagePNGRepresentation(image) writeToFile:[self photoFilePath] atomically:YES]; // UIImageJPEGRepresentation(image, 1.0)
    
    NSURL *fileURL = [NSURL fileURLWithPath:[self photoFilePath]];
    documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    documentInteractionController.UTI = @"com.instagram.exclusivegram";
    documentInteractionController.delegate = delegate;
    if (caption) {
        documentInteractionController.annotation = [NSDictionary dictionaryWithObject:caption forKey:@"InstagramCaption"];
    }
    [documentInteractionController presentOpenInMenuFromRect:CGRectZero inView:view animated:YES];
}

+ (void)postVideo:(NSURL *)videoURL withCaption:(NSString*)caption;
{
    [[BEBInstagram sharedInstance] postVideo:videoURL withCaption:caption];
}

- (void)postVideo:(NSURL *)videoURL withCaption:(NSString*)caption
{
    if (!videoURL) {
        [NSException raise:NSInternalInconsistencyException format:@"Video url cannot be nil!"];
    }
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPathToSavedPhotosAlbum:videoURL completionBlock:^(NSURL *assetURL, NSError *error) {
        
        [[BEBInstagram sharedInstance] postVideoFromAssetURL:assetURL caption:caption];
    }];
}

+ (void)postVideoFromAssetURL:(NSURL *)assetURL caption:(NSString *)caption;
{
    [[BEBInstagram sharedInstance] postVideoFromAssetURL:assetURL caption:caption];
}

- (void)postVideoFromAssetURL:(NSURL *)assetURL caption:(NSString *)caption;
{
    NSString *escapedString = [assetURL.absoluteString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSString *escapedCaption = [caption stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSURL *instagramURL = [NSURL URLWithString:[NSString stringWithFormat:@"instagram://library?AssetPath=%@&InstagramCaption=%@", escapedString, escapedCaption]];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        [[UIApplication sharedApplication] openURL:instagramURL];
    }
}


@end

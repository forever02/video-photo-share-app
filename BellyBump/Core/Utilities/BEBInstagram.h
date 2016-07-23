@interface BEBInstagram : NSObject <UIDocumentInteractionControllerDelegate>

extern NSString* const kInstagramAppURLString;
extern NSString* const kInstagramOnlyPhotoFileName;

// DEFAULT file name is kInstagramDefualtPhotoFileName
// DEFAULT file name is restricted to only the instagram app
// Make sure your photoFileName has a valid photo extension.
+ (void)setPhotoFileName:(NSString*)fileName;
+ (NSString*)photoFileName;

// Checks to see if user has instagram installed on device
+ (BOOL)isAppInstalled;

// Checks to see if image is large enough to be posted by instagram
// Returns NO if image dimensions are under 612x612
//
// Technically the instagram allows for photos to be published under the size of 612x612
// BUT if you want nice quality pictures, I recommend checking the image size.
+ (BOOL)isImageCorrectSize:(UIImage*)image;

// Post image to instagram by passing in the target image and
// the view in which the user will be presented with the instagram model
+ (void)postImage:(UIImage*)image inView:(UIView*)view;
// Same as above method but with the option for a photo caption
+ (void)postImage:(UIImage*)image withCaption:(NSString*)caption inView:(UIView*)view;
+ (void)postImage:(UIImage*)image withCaption:(NSString*)caption inView:(UIView*)view delegate:(id<UIDocumentInteractionControllerDelegate>)delegate;

+ (void)postVideo:(NSURL *)videoURL withCaption:(NSString*)caption;

+ (void)postVideoFromAssetURL:(NSURL *)assetURL caption:(NSString *)caption;

@end

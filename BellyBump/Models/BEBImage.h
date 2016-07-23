
#import "UIImage+Helper.h"

@interface BEBImage : NSObject

@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *effectImage;
@property (nonatomic, strong) UIImage *captionImage;

@property (nonatomic) CGSize size;
@property (nonatomic, strong) NSDate *createDay;
@property (nonatomic) NSInteger storyId;    // Reference to the parent object to save and read the object from disk.

@property (nonatomic, copy) NSString *localPath;    // local path.
@property (nonatomic, copy) NSString *url;          // S3 URL.

@property (nonatomic, getter = isSavedS3) BOOL savedS3;

- (NSString *)fileName;
- (void)saveImageToLocal;
- (UIImage *)readImageFromLocal;
- (void)deleteImageLocal;

- (void)saveImageToS3:(void (^)(BOOL result))completedBlock;
- (void)getImageFromS3:(void (^)(NSString *url))completedBlock;
- (void)deleteImageFromS3:(void (^)(BOOL result))completedBlock;

@end

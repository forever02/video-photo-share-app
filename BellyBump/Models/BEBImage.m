#import "BEBImage.h"
#import "BEBUtilities.h"
#import <AWSS3/AWSS3.h>
#import "BEBConstant.h"
#import "BEBDataManager.h"

@interface BEBImage()

@property (nonatomic, getter = isDownloading) BOOL downloading;

@end

@implementation BEBImage

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.uuid forKey:@"uuid"];
    [coder encodeObject:self.createDay forKey:@"createDay"];
    [coder encodeObject:self.localPath forKey:@"localPath"];
    [coder encodeObject:self.url forKey:@"url"];
    [coder encodeObject:@(self.savedS3) forKey:@"savedS3"];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [self init];
    self.uuid = [coder decodeObjectForKey:@"uuid"];
    self.createDay = [coder decodeObjectForKey:@"createDay"];
    self.localPath = [coder decodeObjectForKey:@"localPath"];
    self.url = [coder decodeObjectForKey:@"url"];
    self.savedS3 = [[coder decodeObjectForKey:@"savedS3"] boolValue];

    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    BEBImage *newImage = [[self class] allocWithZone:zone];
    
    [newImage setUuid:self.uuid];
    [newImage setCreateDay:self.createDay];
    [newImage setLocalPath:self.localPath];
    [newImage setUrl: self.url];
    [newImage setSavedS3:self.savedS3];

    return newImage;
}

- (UIImage *)image
{
    if (_image) {
        return _image;
    }
    
    if (self.localPath) {
        
        DEBUG_LOG(@"Local Path: %@", self.localPath);
        UIImage *cacheImage = [[UIImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", [BEBUtilities userCacheDirectory], self.localPath]];
        self.image = cacheImage;
        
        return cacheImage;
    }
    
    return [UIImage imageNamed:self.uuid];
}

- (NSString *)storyPath
{
    // Get the path with name of the story id.
    // Check the folder is exist or not, if not, create the folder
    
    NSString *path = [NSString stringWithFormat:@"%ld", (long)self.storyId];
    
    NSString *fullpath = [NSString stringWithFormat:@"%@/%ld", [BEBUtilities userCacheDirectory], (long)self.storyId];

    [self createStoryDirectory:fullpath];
    
    return path;
}

- (void)saveImageToLocal;
{
    if (self.image && self.uuid && self.uuid.length > 0) {
        
        NSString *filePath = [NSString stringWithFormat:@"%@/%@/%@", [BEBUtilities userCacheDirectory], [self storyPath], self.uuid];
        
        DEBUG_LOG(@"file Path %@", filePath);
        [UIImageJPEGRepresentation(self.image, 1.0) writeToFile:filePath
                                                     atomically:YES];
        
        // Save the local position for image
        self.localPath = [NSString stringWithFormat:@"%@/%@", [self storyPath], self.uuid];
    }
}

- (UIImage *)readImageFromLocal;
{
    if (self.uuid && self.uuid.length > 0) {
        NSString *filePath = [NSString stringWithFormat:@"%@/%@/%@", [BEBUtilities userCacheDirectory], [self storyPath], self.uuid];
        self.image = [UIImage imageWithContentsOfFile:filePath];
        return self.image;
    }
    return nil;
}

- (void)deleteImageLocal;
{
    NSString *filePath = [NSString stringWithFormat:@"%@/%@/%@", [BEBUtilities userCacheDirectory], [self storyPath], self.uuid];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        if (error) {
            DEBUG_LOG(@"Remove file error: %@", error);
        }
        else {
            DEBUG_LOG(@"Removed file at path: %@", filePath);
        }
    }
}

- (NSString *)fileName;
{
    NSString *fileName = [NSString stringWithFormat:@"%@-%@.png", [BEBDataManager sharedManager].deviceID, self.uuid];
    return fileName;
}

- (void)saveImageToS3:(void (^)(BOOL result))completedBlock;
{
    AWSS3TransferManagerUploadRequest *uploadRequest = [[AWSS3TransferManagerUploadRequest alloc] init];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@/%@", [BEBUtilities userCacheDirectory], [self storyPath], self.uuid];
    uploadRequest.body = [NSURL fileURLWithPath:filePath];
    uploadRequest.bucket = S3BucketName;
    uploadRequest.key = [self fileName];
    
    __weak BEBImage *weakSelf = self;
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    [[transferManager upload:uploadRequest] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                switch (task.error.code) {
                    case AWSS3TransferManagerErrorCancelled:
                    case AWSS3TransferManagerErrorPaused:
                        break;
                        
                    default:
                        DEBUG_LOG(@"Upload failed: [%@]", task.error);
                        break;
                }
            }
            else {
                DEBUG_LOG(@"Upload failed: [%@]", task.error);
            }
            
            if (completedBlock) {
                completedBlock(FALSE);
            }
        }
        
        if (task.result) {
            
            // Update url image
            weakSelf.url = filePath;
            weakSelf.savedS3 = YES;
            
            if (completedBlock) {
                completedBlock(TRUE);
            }
        }
        
        return nil;
    }];
}

- (void)getImageFromS3:(void (^)(NSString *url))completedBlock;
{
    if ([self isDownloading]) return;
    
    self.downloading = YES;
    NSString *filePath = [NSString stringWithFormat:@"%@/%@/%@", [BEBUtilities userCacheDirectory], [self storyPath], self.uuid];
    
    AWSS3TransferManagerDownloadRequest *downloadRequest = [[AWSS3TransferManagerDownloadRequest alloc] init];
    downloadRequest.downloadingFileURL = [NSURL fileURLWithPath:filePath];
    downloadRequest.bucket = S3BucketName;
    downloadRequest.key = [self fileName];
    
    __weak typeof(self) weakSelf = self;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    [[transferManager download:downloadRequest] continueWithExecutor:[AWSExecutor executorWithDispatchQueue:queue] withBlock:^id(AWSTask *task) {
        
        weakSelf.downloading = NO;
        
        if (task.error) {
            
            if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                switch (task.error.code) {
                    case AWSS3TransferManagerErrorCancelled:
                    case AWSS3TransferManagerErrorPaused:
                        break;
                        
                    default:
                        DEBUG_LOG(@"Error: %@", task.error);
                        break;
                }
            }
            else {
                DEBUG_LOG(@"Error: %@", task.error);
            }
            
            if (completedBlock) {
                completedBlock(filePath);
            }
        }
        
        if (task.result) {
            
            if (completedBlock) {
                completedBlock(filePath);
            }
        }
        
        return nil;
    }];
}

- (void)deleteImageFromS3:(void (^)(BOOL result))completedBlock;
{
    AWSS3 *s3 = [AWSS3 defaultS3];
    AWSS3DeleteObjectRequest *deleteObjectRequest = [[AWSS3DeleteObjectRequest alloc] init];
    deleteObjectRequest.bucket = S3BucketName;
    deleteObjectRequest.key = [self fileName];
    
    [[[s3 deleteObject:deleteObjectRequest] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            DEBUG_LOG(@"Delete failed: [%@]", task.error);
            
            if (completedBlock) {
                completedBlock(FALSE);
            }
        }
        else if (task.result) {
            DEBUG_LOG(@"Result delete: [%@]", task.result);
            
            if (completedBlock) {
                completedBlock(TRUE);
            }
        }
        
        return nil;
    }] waitUntilFinished];
}

- (void)createStoryDirectory:(NSString *)path;
{
    // Create the folder.
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    BOOL isDirectory = NO;
    BOOL directoryExists = [fileManager fileExistsAtPath:path isDirectory:&isDirectory];
    if (directoryExists) {
        DEBUG_LOG(@"isDirectory: %d", isDirectory);
    }
    else {
        NSError *error = nil;
        BOOL success = [fileManager createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error];
        DEBUG_LOG(@"success 1: %i", success);
        if (!success) {
            DEBUG_LOG(@"Failed to create directory with error: %@", [error description]);
        }
    }
}

@end

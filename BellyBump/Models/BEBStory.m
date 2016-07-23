#import "BEBStory.h"
#import <AWSS3/AWSS3.h>
#import "BEBConstant.h"
#import "BEBImage.h"

@implementation BEBStory

#pragma mark - Initilize methods
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.photos = [NSMutableArray array];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder;
{
    [coder encodeInteger:self.storyId forKey:@"storyId"];
    [coder encodeObject:self.title forKey:@"name"];
    [coder encodeObject:self.startDate forKey:@"startDate"];
    [coder encodeInteger:self.frequence forKey:@"frequence"];
    [coder encodeInteger:self.gender forKey:@"gender"];
    [coder encodeInteger:self.storyType forKey:@"storyType"];
    [coder encodeInteger:self.pregnancy forKey:@"pregnancy"];
    [coder encodeObject:self.birthDate forKey:@"birthDate"];
    [coder encodeObject:self.photos forKey:@"photos"];
    
    [coder encodeCGPoint:self.faceCenter forKey:@"faceCenter"];
    [coder encodeCGPoint:self.bellyBumpCenter forKey:@"bellyBumpCenter"];
    [coder encodeInteger:self.eyeLinePositionY forKey:@"eyeLinePositionY"];
    [coder encodeInteger:self.bellyBumpLinePositionY forKey:@"bellyBumpLinePositionY"];

}

- (id)initWithCoder:(NSCoder *)coder;
{
    self = [self init];
    
    self.storyId = [coder decodeIntegerForKey:@"storyId"];
    self.title = [coder decodeObjectForKey:@"name"];
    self.startDate = [coder decodeObjectForKey:@"startDate"];
    self.frequence = [coder decodeIntegerForKey:@"frequence"];
    self.gender = [coder decodeIntegerForKey:@"gender"];
    self.pregnancy = [coder decodeIntegerForKey:@"pregnancy"];
    self.storyType = [coder decodeIntegerForKey:@"storyType"];
    self.birthDate = [coder decodeObjectForKey:@"birthDate"];

    self.faceCenter = [coder decodeCGPointForKey:@"faceCenter"];
    self.bellyBumpCenter = [coder decodeCGPointForKey:@"bellyBumpCenter"];
    self.eyeLinePositionY = [coder decodeIntegerForKey:@"eyeLinePositionY"];
    self.bellyBumpLinePositionY = [coder decodeIntegerForKey:@"bellyBumpLinePositionY"];
    
    NSArray *photos = [coder decodeObjectForKey:@"photos"];
    self.photos = [[NSMutableArray alloc] initWithArray:photos copyItems:YES];
    
    return self;
}

- (NSString *)timeForNextPhoto;
{
    // Compute the time interval
    double referenceTime = [[NSDate date] timeIntervalSinceDate:self.startDate];
    double totalSeconds = round(fabs(referenceTime));
    NSInteger days = (NSInteger)totalSeconds / 86400;
    
    if (self.frequence == FrequencyTypeDaily) {
        
        NSInteger seconds = (NSInteger)totalSeconds - days * 86400;
        NSInteger remainSeconds = 86400 - seconds;
        NSInteger remainHours = remainSeconds / 3600;
        
        if (remainHours == 0) {
            
            NSInteger remainMinutes = remainSeconds / 60;
            if (remainMinutes == 0) {
                
                if (remainSeconds == 1) return @"a second";
                return [NSString stringWithFormat:@"%d seconds", (int)remainSeconds];
            }
            else {
                if (remainMinutes == 1) return @"a minute";
                return [NSString stringWithFormat:@"%d minutes", (int)remainMinutes];
            }
        }
        else {
            double minutes = round(remainSeconds / 60.0f);
            double hours = round(minutes / 60.0f);
            if (hours == 1) return @"an hour";
            return [NSString stringWithFormat:@"%d hours", (int)hours];
        }
    }
    else if (self.frequence == FrequencyTypeBiweekly) {
        
        NSInteger weeks = (NSInteger)totalSeconds / (86400 * 7);
        NSInteger seconds = (NSInteger)totalSeconds - weeks * 86400 * 7;
        NSInteger remainSeconds = 86400 * 7 - seconds;
        if (remainSeconds > 4 * 86400) {
            remainSeconds -= 4 * 86400;
        }
        
        NSInteger remainDays = remainSeconds / 86400;
        
        if (remainDays == 0) {
            
            NSInteger remainHours = remainSeconds / 3600;
            if (remainHours == 0) {
                
                NSInteger remainMinutes = remainSeconds / 60;
                if (remainMinutes == 0) {
                    
                    if (remainSeconds == 1) return @"a second";
                    return [NSString stringWithFormat:@"%d seconds", (int)remainSeconds];
                }
                else {
                    if (remainMinutes == 1) return @"a minute";
                    return [NSString stringWithFormat:@"%d minutes", (int)remainMinutes];
                }
            }
            else {
                double minutes = round(remainSeconds / 60.0f);
                double hours = round(minutes / 60.0f);
                if (hours == 1) return @"an hour";
                return [NSString stringWithFormat:@"%d hours", (int)hours];
            }
        }
        else {
            double minutes = round(remainSeconds / 60.0f);
            double hours = round(minutes / 60.0f);
            double days = round(hours / 24.0f);
            if (days == 1) return @"a day";
            return [NSString stringWithFormat:@"%d days", (int)days];
        }
    }
    else {
        NSInteger weeks = (NSInteger)totalSeconds / (86400 * 7);
        NSInteger seconds = (NSInteger)totalSeconds - weeks * 86400 * 7;
        NSInteger remainSeconds = 86400 * 7 - seconds;
        NSInteger remainDays = remainSeconds / 86400;
        
        if (remainDays == 0) {
            
            NSInteger remainHours = remainSeconds / 3600;
            if (remainHours == 0) {
                
                NSInteger remainMinutes = remainSeconds / 60;
                if (remainMinutes == 0) {
                    
                    if (remainSeconds == 1) return @"a second";
                    return [NSString stringWithFormat:@"%d seconds", (int)remainSeconds];
                }
                else {
                    if (remainMinutes == 1) return @"a minute";
                    return [NSString stringWithFormat:@"%d minutes", (int)remainMinutes];
                }
            }
            else {
                double minutes = round(remainSeconds / 60.0f);
                double hours = round(minutes / 60.0f);
                if (hours == 1) return @"an hour";
                return [NSString stringWithFormat:@"%d hours", (int)hours];
            }
        }
        else {
            double minutes = round(remainSeconds / 60.0f);
            double hours = round(minutes / 60.0f);
            double days = round(hours / 24.0f);
            if (days == 1) return @"a day";
            return [NSString stringWithFormat:@"%d days", (int)days];
        }
    }
}

- (void)deleteImagesFromS3:(void (^)(BOOL result))completedBlock;
{
    AWSS3 *s3 = [AWSS3 defaultS3];
    
    NSMutableArray *objectsArray = [NSMutableArray array];
    for (BEBImage *bebImage in self.photos) {
        AWSS3ObjectIdentifier *obj = [[AWSS3ObjectIdentifier alloc] init];
        obj.key = [bebImage fileName];
        [objectsArray addObject:obj];
    }
    
    AWSS3Remove *s3Remove = [[AWSS3Remove alloc] init];
    s3Remove.objects = objectsArray;
    
    AWSS3DeleteObjectsRequest *multipleObjectsDeleteReq = [[AWSS3DeleteObjectsRequest alloc] init];
    multipleObjectsDeleteReq.bucket = S3BucketName;
    multipleObjectsDeleteReq.remove = s3Remove;
    
    [[[s3 deleteObjects:multipleObjectsDeleteReq] continueWithBlock:^id(AWSTask *task) {
        
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

- (void)deleteImagesLocal;
{
    for (BEBImage *bebImage in self.photos) {
        [bebImage deleteImageLocal];
    }
}

@end

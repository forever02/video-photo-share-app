#import "BEBStoryboard.h"

@implementation BEBStoryboard

+ (UIStoryboard *)storyboard;
{
    if (IS_IPHONE_6PLUS) {
        return [UIStoryboard storyboardWithName:@"BEBMain6Plus" bundle:nil];
    }
    else if (IS_IPHONE_6) {
        return [UIStoryboard storyboardWithName:@"BEBMain6" bundle:nil];
    }
    else {
        return [UIStoryboard storyboardWithName:@"BEBMain" bundle:nil];
    }
}

@end

#import "BEBDividerLine.h"

@implementation BEBDividerLine

- (instancetype)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews;
{
    CGRect newFrame = self.frame;
    if (newFrame.size.height == 1.0f) {
        newFrame.size.height = 1.0f / [[UIScreen mainScreen] scale];
    }
    if (newFrame.size.width == 1.0f) {
        newFrame.size.width = 1.0f / [[UIScreen mainScreen] scale];
    }
    self.frame = newFrame;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

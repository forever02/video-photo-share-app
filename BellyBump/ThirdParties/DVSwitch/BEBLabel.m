
#import "BEBLabel.h"

@implementation BEBLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)drawTextInRect:(CGRect)rect
{

    rect.origin.y += 5;
    
    [super drawTextInRect:rect];
}


@end


#import "UIView+Initialization.h"

@implementation UIView (Initialization)

- (instancetype)loadFromNib {
    
    UIView *view = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil] firstObject];
    return view;
}

@end

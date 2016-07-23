
#import "GKCropBorderView.h"


@interface GKCropBorderView()

-(NSMutableArray*)_calculateAllNeededHandleRects;

@end

@implementation GKCropBorderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark -
#pragma drawing
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(ctx, BackgroundColorLightGray.CGColor);
    CGContextSetLineWidth(ctx, 1.0f);
    CGContextAddRect(ctx, CGRectMake(kHandleDiameter / 2 + 0.5f, kHandleDiameter / 2 + 0.5f, rect.size.width - kHandleDiameter - 1.0f, rect.size.height - kHandleDiameter - 1.0f));
    CGContextStrokePath(ctx);
    
    CGContextSetStrokeColorWithColor(ctx, BackgroundColorLightGray.CGColor);
    CGContextSetLineWidth(ctx, 0.5f);
    
    CGContextMoveToPoint(ctx, rect.origin.x+rect.size.width/3 + 0.5f, rect.origin.y + kHandleDiameter / 2);
    CGContextAddLineToPoint(ctx, rect.origin.x+rect.size.width/3 + 0.5f, rect.origin.y+rect.size.height - kHandleDiameter / 2);
    CGContextMoveToPoint(ctx, rect.origin.x+rect.size.width/3*2 + 0.5f, rect.origin.y + kHandleDiameter / 2);
    CGContextAddLineToPoint(ctx, rect.origin.x+rect.size.width/3*2 + 0.5f, rect.origin.y+rect.size.height - kHandleDiameter / 2);
    
    CGContextMoveToPoint(ctx, rect.origin.x + kHandleDiameter / 2, rect.origin.y+rect.size.height/3 + 0.5f);
    CGContextAddLineToPoint(ctx, rect.origin.x+rect.size.width - kHandleDiameter / 2, rect.origin.y+rect.size.height/3 + 0.5f);
    CGContextMoveToPoint(ctx, rect.origin.x + kHandleDiameter / 2, rect.origin.y+rect.size.height/3*2 + 0.5f);
    CGContextAddLineToPoint(ctx, rect.origin.x+rect.size.width - kHandleDiameter / 2, rect.origin.y+rect.size.height/3*2 + 0.5f);
    
    CGContextStrokePath(ctx);
    
    NSMutableArray *handleRectArray = [self _calculateAllNeededHandleRects];
    for (NSValue *value in handleRectArray) {
        
        CGRect currentHandleRectBorder = [value CGRectValue];
        CGContextSetRGBFillColor(ctx, 237.0f/255.0f, 237.0f/255.0f, 237.0f/255.0f, 0.3f);
        CGContextFillEllipseInRect(ctx, currentHandleRectBorder);
        
        CGRect currentHandleRect = [value CGRectValue];
        currentHandleRect.origin.x += 3.0f;
        currentHandleRect.size.width -= 6.0f;
        currentHandleRect.origin.y += 3.0f;
        currentHandleRect.size.height -= 6.0f;
        CGContextSetRGBFillColor(ctx, 1., 1., 1., 0.95);
        CGContextFillEllipseInRect(ctx, currentHandleRect);
    }
}

#pragma mark -
#pragma private
-(NSMutableArray*)_calculateAllNeededHandleRects
{
    NSMutableArray *a = [NSMutableArray new];
    
    //starting with the upper left corner and then following clockwise
    //CGRect currentRect = CGRectMake(0, 0, kHandleDiameter, kHandleDiameter);
    //[a addObject:[NSValue valueWithCGRect:currentRect]];
    
    CGRect currentRect = CGRectMake(self.frame.size.width / 2 - kHandleDiameter / 2, 0, kHandleDiameter, kHandleDiameter);
    [a addObject:[NSValue valueWithCGRect:currentRect]];
    
    //currentRect = CGRectMake(self.frame.size.width - kHandleDiameter, 0 , kHandleDiameter, kHandleDiameter);
    //[a addObject:[NSValue valueWithCGRect:currentRect]];
    
    //upper row done
    if (self.cropAvatar) {
        currentRect = CGRectMake(self.frame.size.width - kHandleDiameter, self.frame.size.height / 2 - kHandleDiameter / 2, kHandleDiameter, kHandleDiameter);
        [a addObject:[NSValue valueWithCGRect:currentRect]];
    }
    
    //currentRect = CGRectMake(self.frame.size.width - kHandleDiameter, self.frame.size.height - kHandleDiameter, kHandleDiameter, kHandleDiameter);
    //[a addObject:[NSValue valueWithCGRect:currentRect]];
    
    currentRect = CGRectMake(self.frame.size.width / 2 - kHandleDiameter / 2, self.frame.size.height - kHandleDiameter, kHandleDiameter, kHandleDiameter);
    [a addObject:[NSValue valueWithCGRect:currentRect]];
    
    //currentRect = CGRectMake(0, self.frame.size.height - kHandleDiameter, kHandleDiameter, kHandleDiameter);
    //[a addObject:[NSValue valueWithCGRect:currentRect]];
    
    //now back up again
    if (self.cropAvatar) {
        currentRect = CGRectMake(0, self.frame.size.height / 2 - kHandleDiameter / 2, kHandleDiameter, kHandleDiameter);
        [a addObject:[NSValue valueWithCGRect:currentRect]];
    }
    
    return a;
}
@end

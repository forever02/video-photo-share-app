#import "BEBFilterSelectionView.h"

static const CGFloat kGapFilterItem = 4.0f;

@interface BEBFilterSelectionView() <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation BEBFilterSelectionView

- (void)awakeFromNib;
{
    [super awakeFromNib];
    
    [self configureScrollView];
}

- (void)configureScrollView;
{
    CGRect frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.scrollView = [[UIScrollView alloc] initWithFrame:frame];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    [self addSubview:self.scrollView];
}

- (void)setFilterImages:(NSArray *)filterImages filterNames:(NSArray *)filterNames;
{
    self.filterImages = filterImages;
    CGFloat kWidthItem = IS_IPHONE_6PLUS ? 76.0f : (IS_IPHONE_6 ? 68.0f : 59.0f);
    CGFloat kHeightItem = IS_IPHONE_6PLUS ? 77.0f : (IS_IPHONE_6 ? 68.0f : 59.0f);
    
    CGFloat x = IS_IPHONE_6PLUS ? 9.0f : (IS_IPHONE_6 ? 10.0f : kGapFilterItem + 1.0f);
    for (NSInteger i = 0; i < filterImages.count; i++) {
        
        CGRect frame = CGRectMake(x + i*(kWidthItem + kGapFilterItem), 0, kWidthItem, 95.0f);
        if (IS_IPHONE_5 || IS_IPHONE_4) {
            frame.origin.y += 2.0f;
        }
        UIView *view = [[UIView alloc] initWithFrame:frame];
        
        frame.origin.x = 0;
        frame.size.height = kHeightItem;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
        imageView.image = filterImages[i];
        [view addSubview:imageView];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(tapFilterImage:)];
        imageView.userInteractionEnabled = YES;
        [imageView addGestureRecognizer:tapGesture];
        imageView.tag = i;
        
        frame.origin.y = kHeightItem;
        if (IS_IPHONE_5 || IS_IPHONE_4) {
            frame.origin.y += 5.0f;
        }
        frame.size.height = 15.0f;
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f];
        label.text = filterNames[i];
        [view addSubview:label];
        
        [self.scrollView addSubview:view];
    }
    
    self.scrollView.contentSize = CGSizeMake((kWidthItem + kGapFilterItem) * filterImages.count, kHeightItem);
    if (filterImages.count < 5) {
        [self.scrollView setScrollEnabled:NO];
    }
}

- (void)tapFilterImage:(UIGestureRecognizer *)gestureRecognizer;
{
    UIImageView *imageView = (UIImageView *)gestureRecognizer.view;
    NSInteger index = imageView.tag;
    
    // Perform selector on delegate
    if ([self.delegate respondsToSelector:@selector(bebFilterSelectionView:didSelectFilterAtIndex:)]) {
        
        [self.delegate bebFilterSelectionView:self didSelectFilterAtIndex:index];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    CGFloat leftRemain = self.scrollView.contentSize.width - self.scrollView.frame.size.width;
    scrollView.pagingEnabled = self.scrollView.contentOffset.x < leftRemain;
}

@end

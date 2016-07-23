#import "BEBFontSelectionView.h"
#import "DVSwitch.h"

static const CGFloat kWidthItem = 53.5f;
static const CGFloat kHeightItem = 34.0f;

@interface BEBFontSelectionView() <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) DVSwitch *selectionSwitch;

@end

@implementation BEBFontSelectionView

- (void)awakeFromNib;
{
    [super awakeFromNib];
    
    self.backgroundColor = RGB(255, 246, 223, 1);
    self.layer.cornerRadius = 18.0f;
    self.clipsToBounds = YES;
    
    [self configureScrollView];
}

- (void)configureScrollView;
{
    CGRect frame = CGRectMake(6, 0, self.frame.size.width - 13, self.frame.size.height);
    self.scrollView = [[UIScrollView alloc] initWithFrame:frame];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    [self addSubview:self.scrollView];
}

- (void)setFonts:(NSArray *)fonts;
{
    _fonts = fonts;
    
    NSMutableArray *strings = [NSMutableArray array];
    for (NSInteger i = 0; i < fonts.count; i++) {
        [strings addObject:@"abc"];
    }
    
    // Create selection switch
    self.selectionSwitch = [DVSwitch switchWithStringsArray:strings];
    self.selectionSwitch.frame = CGRectMake(0, 1, kWidthItem * fonts.count, kHeightItem);
    self.selectionSwitch.layer.cornerRadius = kHeightItem/2;
    self.selectionSwitch.clipsToBounds = YES;
    self.selectionSwitch.selectedIndex = self.positionItemSelected;
    self.selectionSwitch.backgroundColor = RGB(255, 246, 223, 1);
    self.selectionSwitch.sliderColor = RGB(161, 211, 223, 1);
    self.selectionSwitch.labelTextColorInsideSlider = [UIColor whiteColor];
    self.selectionSwitch.labelTextColorOutsideSlider = RGB(155, 155, 155, 1);
    self.selectionSwitch.cornerRadius = 17.0f;
    self.selectionSwitch.fonts = fonts;
    
    // Set handler selected item index
    __weak BEBFontSelectionView *weakSelf = self;
    [self.selectionSwitch setPressedHandler:^(NSUInteger index) {
        weakSelf.positionItemSelected = index % 5;
        [weakSelf handleSelectedFontAtIndex:index];
    }];
    
    [self.scrollView addSubview:self.selectionSwitch];
    self.scrollView.contentSize = CGSizeMake(kWidthItem * fonts.count, kHeightItem);
    if (fonts.count <= 5) {
        [self.scrollView setScrollEnabled:NO];
    }
}

- (void)handleSelectedFontAtIndex:(NSInteger)index;
{
    // Perform selector on delegate
    if (self.delegate && [self.delegate respondsToSelector:@selector(bebFontSelectionView:didSelectFontAtIndex:)]) {
        
        [self.delegate bebFontSelectionView:self didSelectFontAtIndex:index];
    }
}

//*****************************************************************************
#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    if (self.positionItemSelected == -1) {
        [self.selectionSwitch selectIndex:0 animated:NO];
        self.positionItemSelected = 0;
    }
    [self.selectionSwitch updateSliderWithTranslate:scrollView.contentOffset];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
{
    CGFloat pageWidth = CGRectGetWidth(self.scrollView.frame);
    NSUInteger page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    [self handleSelectedFontAtIndex:page * 5 + self.positionItemSelected];
}


@end

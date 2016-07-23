#import "BEBAudioSelectionView.h"
#import "DVSwitch.h"

static const CGFloat kWidthItem = 53.0f;

@interface BEBAudioSelectionView() <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) DVSwitch *selectionSwitch;

@end

@implementation BEBAudioSelectionView

- (void)awakeFromNib;
{
    [super awakeFromNib];
    
    self.backgroundColor = RGB(230, 231, 232, 1); //RGB(187, 90, 89, 1);
    self.layer.cornerRadius = 16.0f;
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
        [strings addObject:@"\u266B\u1F6AB"];
    }
    
    // Create selection switch
    self.selectionSwitch = [DVSwitch switchWithStringsArray:strings];
    self.selectionSwitch.frame = CGRectMake(0, 2, kWidthItem * fonts.count, 28);
    self.selectionSwitch.layer.cornerRadius = 14;
    self.selectionSwitch.clipsToBounds = YES;
    self.selectionSwitch.selectedIndex = self.positionItemSelected;
    self.selectionSwitch.backgroundColor = RGB(230, 231, 232, 1); //RGB(187, 90, 89, 1);
    self.selectionSwitch.sliderColor = RGB(161, 211, 223, 1);
    self.selectionSwitch.labelTextColorInsideSlider = RGB(15, 15, 15, 1);
    self.selectionSwitch.labelTextColorOutsideSlider = RGB(15, 15, 15, 1);
    self.selectionSwitch.fonts = fonts;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    imageView.image = [UIImage imageNamed:@"icon_timer_story"];
    [self.selectionSwitch addSubview:imageView];
    
    // Set handler selected item index
    __weak BEBAudioSelectionView *weakSelf = self;
    [self.selectionSwitch setPressedHandler:^(NSUInteger index) {
        weakSelf.positionItemSelected = index % 5;
        [weakSelf handleSelectedFontAtIndex:index];
    }];
    
    [self.scrollView addSubview:self.selectionSwitch];
    self.scrollView.contentSize = CGSizeMake(kWidthItem * fonts.count, 32);
    if (fonts.count <= 5) {
        [self.scrollView setScrollEnabled:NO];
    }
}

- (void)handleSelectedFontAtIndex:(NSInteger)index;
{
    // Perform selector on delegate
    if (self.delegate && [self.delegate respondsToSelector:@selector(bebAudioSelectionView:didSelectAudioAtIndex:)]) {
        
        [self.delegate bebAudioSelectionView:self didSelectAudioAtIndex:index];
    }
}

//*****************************************************************************
#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    [self.selectionSwitch updateSliderWithTranslate:scrollView.contentOffset];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
{
    CGFloat pageWidth = CGRectGetWidth(self.scrollView.frame);
    NSUInteger page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    [self handleSelectedFontAtIndex:page * 5 + self.positionItemSelected];
}


@end

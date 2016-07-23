
@protocol BEBFontSelectionViewDelegate <NSObject>

- (void)bebFontSelectionView:(id)fontSelectionView didSelectFontAtIndex:(NSInteger)index;

@end

@interface BEBFontSelectionView : UIView

#pragma mark - Properties
@property (nonatomic, copy) NSArray *fonts;
@property (nonatomic, weak) id<BEBFontSelectionViewDelegate> delegate;
@property (nonatomic) NSInteger positionItemSelected;

@end


@protocol BEBFilterSelectionViewDelegate <NSObject>

- (void)bebFilterSelectionView:(id)filterSelectionView didSelectFilterAtIndex:(NSInteger)index;

@end

@interface BEBFilterSelectionView : UIView

#pragma mark - Properties
@property (nonatomic, copy) NSArray *filterImages;
@property (nonatomic, weak) id<BEBFilterSelectionViewDelegate> delegate;

#pragma mark - Methods
- (void)setFilterImages:(NSArray *)filterImages filterNames:(NSArray *)filterNames;

@end

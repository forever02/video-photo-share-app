
@protocol BEBAudioSelectionViewDelegate <NSObject>

- (void)bebAudioSelectionView:(id)audioSelectionView didSelectAudioAtIndex:(NSInteger)index;

@end

@interface BEBAudioSelectionView : UIView

#pragma mark - Properties
@property (nonatomic, copy) NSArray *fonts;
@property (nonatomic, weak) id<BEBAudioSelectionViewDelegate> delegate;
@property (nonatomic) NSInteger positionItemSelected;

@end

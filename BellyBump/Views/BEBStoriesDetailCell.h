@class BEBImage;

@protocol BEBStoriesDetailCellDelegate <NSObject>

- (void)bebStoriesDetailCell:(id)storiesDetailCell didTouchOnPhotoAtIndex:(NSInteger)index;
- (void)bebStoriesDetailCellClickOpenCamera:(id)storiesDetailCell;
- (void)bebStoriesDetailCellClickOpenLibrary:(id)storiesDetailCell;

@end

@interface BEBStoriesDetailCell : UICollectionViewCell

#pragma mark - Properties
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, weak) id<BEBStoriesDetailCellDelegate> delegate;

#pragma mark - IBOutlets

#pragma mark - Methods
- (void)setThumbnailImage:(BEBImage *)bebImage;

@end

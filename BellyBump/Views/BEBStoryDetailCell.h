
@class BEBImage;

@protocol BEBStoryDetailCellDelegate <NSObject>

- (void)bebStoryDetailCell:(id)storyDetailCell didTouchOnDeleteButtonAtIndex:(NSInteger)index;

@end

@interface BEBStoryDetailCell : UICollectionViewCell

#pragma mark - Properties
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, weak) id<BEBStoryDetailCellDelegate> delegate;

#pragma mark - IBOutlets
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *thumbImageView;

#pragma mark - Methods
- (void)markThumbnailImageSelected:(BOOL)isSelected;
- (void)setThumbnailImage:(BEBImage *)bebImage;

@end

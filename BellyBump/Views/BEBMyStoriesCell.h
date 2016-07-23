
@class BEBStory;

@protocol BEBMyStoriesCellDelegate <NSObject>

- (void)bebMyStoriesCell:(id)myStoriesCell didTouchOnDetailStoryAtIndex:(NSInteger)index;
- (void)bebMyStoriesCell:(id)myStoriesCell didDeleteStoryAtIndex:(NSInteger)index;

@end

@interface BEBMyStoriesCell : UICollectionViewCell

#pragma mark - Properties
@property (nonatomic, strong) BEBStory *story;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, weak) id<BEBMyStoriesCellDelegate> delegate;

#pragma mark - IBOutlets

#pragma mark - Methods
- (void)resetDeleteStoryAnimation;

@end

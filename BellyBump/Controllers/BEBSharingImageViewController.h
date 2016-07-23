
#import "BEBViewController.h"

@protocol BEBSharingImageViewControllerDelegate;

@interface BEBSharingImageViewController : BEBViewController

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, weak) id<BEBSharingImageViewControllerDelegate> delegate;

@end

@protocol BEBSharingImageViewControllerDelegate <NSObject>

- (void)bebSharingImageViewController:(BEBSharingImageViewController *)sharingImageViewController
                 dismissWithAnimation:(BOOL)animation;

@end



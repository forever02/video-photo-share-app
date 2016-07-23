#import <UIKit/UIKit.h>
#import "BEBStory.h"

@protocol BEBNewStoryViewControllerProtocol;

@interface BEBNewStoryViewController : UIViewController

@property (nonatomic, weak) id<BEBNewStoryViewControllerProtocol> delegate;

@end

@protocol BEBNewStoryViewControllerProtocol <NSObject>

- (void)bebNewStoryViewController:(BEBNewStoryViewController *)newStoryViewController
                 dismissWithStory:(BEBStory *)story;

@end
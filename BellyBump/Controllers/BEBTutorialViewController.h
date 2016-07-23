
#import "BEBViewController.h"
#import <UIKit/UIKit.h>
#import "BEBStory.h"

@protocol BEBTutorialViewControllerProtocol;

@interface BEBTutorialViewController : BEBViewController

@property (nonatomic, weak) id<BEBTutorialViewControllerProtocol> delegate;

@end

@protocol BEBTutorialViewControllerProtocol <NSObject>

- (void)bebTutorialViewController:(BEBTutorialViewController *)newStoryViewController
                 dismissWithStory:(BEBStory *)story;

@end
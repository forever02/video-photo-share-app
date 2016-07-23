#import "BEBViewController.h"

@interface BEBNotificationViewController : BEBViewController

@property (nonatomic, copy) NSString *message;
@property (nonatomic, getter = isHideOverlay) BOOL hideOverlay;

@end

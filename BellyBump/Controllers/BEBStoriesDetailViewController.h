#import "BEBViewController.h"

@class BEBStory;

@interface BEBStoriesDetailViewController : BEBViewController

@property (nonatomic, strong) BEBStory *story;
@property (nonatomic) BOOL needTakeImage;
@property (nonatomic) UIDatePicker *datepicker;

@end

#import <UIKit/UIKit.h>
#import "BEBStory.h"

@protocol BEBCamViewControllerDelegate;

@interface BEBCamViewController : UIViewController

@property (nonatomic) BOOL firstImage;          // Mark first image in the story.
@property (nonatomic, strong) BEBStory *story;   // Story type

@property (strong, nonatomic) UIImage *previousPhoto;

@property (nonatomic, weak) id<BEBCamViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *previousPhotoView;
@property (strong, nonatomic) IBOutlet UIButton *bttFlashOnOff;

@end

@protocol BEBCamViewControllerDelegate <NSObject>

- (void)bebCamViewController:(BEBCamViewController *)camViewController
          finishedWithImage:(UIImage *)image;

@end
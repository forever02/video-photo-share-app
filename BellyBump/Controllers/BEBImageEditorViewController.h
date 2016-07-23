#import "HFImageEditorViewController.h"

@interface BEBImageEditorViewController : HFImageEditorViewController

@property (nonatomic) CGFloat previousImageAlpha;
@property (nonatomic) BOOL previousImageHidden;
@property (nonatomic, strong) UIImage *previousImage;
@property (nonatomic) BOOL addTextProcess;

@end

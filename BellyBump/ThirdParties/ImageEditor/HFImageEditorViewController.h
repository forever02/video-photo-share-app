#import <UIKit/UIKit.h>
#import "BEBViewController.h"

@protocol HFImageEditorViewControllerDelegate;

@protocol HFImageEditorFrame
@required
@property(nonatomic,assign) CGRect cropRect;
@end

@class  HFImageEditorViewController;

typedef void(^HFImageEditorDoneCallback)(UIImage *image, UIImage *captionImage, BOOL canceled);

@interface HFImageEditorViewController : BEBViewController<UIGestureRecognizerDelegate>

@property(nonatomic,copy) UIImage *sourceImage;
@property(nonatomic,copy) UIImage *previewImage;
@property(nonatomic,assign) CGSize cropSize;
@property(nonatomic,assign) CGRect cropRect;
@property(nonatomic,assign) CGFloat outputWidth;
@property(nonatomic,assign) CGFloat minimumScale;
@property(nonatomic,assign) CGFloat maximumScale;

@property(nonatomic,assign) BOOL panEnabled;
@property(nonatomic,assign) BOOL rotateEnabled;
@property(nonatomic,assign) BOOL scaleEnabled;
@property(nonatomic,assign) BOOL tapToResetEnabled;
@property(nonatomic,assign) BOOL checkBounds;

@property (nonatomic, weak) id<HFImageEditorViewControllerDelegate> delegate;
@property(nonatomic,readonly) CGRect cropBoundsInSourceImage;

- (void)reset:(BOOL)animated;
- (IBAction)doneAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (UIImage *)addCaptionInImage:(UIImage *)image;
- (UIImage *)image:(UIImage *)image
       withCaption:(NSString *)text
          position:(CGPoint)position
              font:(UIFont *)font
             color:(UIColor *)color;
- (void)handleRotationWithValue:(CGFloat)value;
- (void)rollBackCorrectTransform;
- (void)resetSliderValueAtChildView:(CGFloat)value;

@end

@protocol HFImageEditorViewControllerDelegate <NSObject>

- (void)imageEditor:(HFImageEditorViewController *)imageEditor
    finishWithImage:(UIImage *)editedImage
       captionImage:(UIImage *)captionImage
             cancel:(BOOL) canceled;

@end



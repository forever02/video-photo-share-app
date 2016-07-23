
@interface UIViewController (Popup)
@property (nonatomic, strong) UIViewController *presentedPopupViewController;
@property (nonatomic, strong) UIViewController *presentingPopupViewController;
@property (nonatomic, strong) UIView *overlayView;

- (void)popupViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)popupViewController:(UIViewController *)viewController animated:(BOOL)animated overlayOpacity:(CGFloat)overlayOpacity;
- (void)dismisPopupViewControllerAnimated:(BOOL)animated;
- (void)popupViewController:(UIViewController *)viewController animated:(BOOL)animated dimissedWhenTapOverlay:(BOOL)dismissed;

- (UIViewController *)getTopPresentedPopupViewController;

@end
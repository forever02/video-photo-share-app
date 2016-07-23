
#import <objc/runtime.h>
#import "UIViewController+Popup.h"

static const char *poppedupKey = "PresentedPopupViewController";
static const char *poppingupKey = "PoppingupViewController";

static const CGFloat kAnimationTime = 0.25;
static const NSUInteger kOverlayViewTag = 1024;
static const CGFloat kOverlayOpacity = 0.52f;

@implementation UIViewController (Popup)

@dynamic overlayView;

- (void)popupViewController:(UIViewController *)viewController animated:(BOOL)animated overlayOpacity:(CGFloat)overlayOpacity;
{
    if (!viewController)
        [NSException raise:NSInvalidArgumentException
                    format:@"Could not pop up a nil controller"];
    
    if (!viewController.view)
        [NSException raise:NSInvalidArgumentException
                    format:@"Could not pop up a controller with nil view"];
    
    if ([viewController isEqual:self.presentedPopupViewController])
        [NSException raise:NSInvalidArgumentException format:@"The controller %@ is currently popped up", viewController];
    
    
    // Dismiss current popped-up view controller
    [self dismisPopupViewControllerAnimated:NO];
    
    self.presentedPopupViewController = viewController;
    viewController.presentingPopupViewController = self;
    
    // Remove the view from it's current view
    [viewController.view removeFromSuperview];
    
    UIView *containerView = [[self class] containerViewForPresentingViewController:self];
    
    // Add overlay view into the window
    UIView *overlayView = [[UIView alloc] initWithFrame:containerView.bounds];
    
    overlayView.backgroundColor = [UIColor colorWithWhite:0.0
                                                    alpha:overlayOpacity];
    
    [self setTagForOverlayView:overlayView
                 containerView:containerView];
    
    // Add the overlay view into the container
    [containerView addSubview:overlayView];
    
    if (!animated) {
        
        // Add the popup's content into the overlay view
        [overlayView addSubview:viewController.view];
    }
    else {
        
        /* We will move the added view from the bottom of the device toward the top edge */
        
        // Overlay view
        viewController.view.frame = CGRectOffset(overlayView.bounds, 0, CGRectGetHeight(containerView.bounds));
        overlayView.backgroundColor = [UIColor clearColor];
        overlayView.alpha = 0;
        
        [overlayView addSubview:viewController.view];
        
        // Disable user interaction while animating
        containerView.userInteractionEnabled = NO;
        
        [UIView animateWithDuration:kAnimationTime
                         animations:^{
                             
                             viewController.view.frame = overlayView.bounds;
                             overlayView.alpha = 1;
                             overlayView.backgroundColor = [UIColor colorWithWhite:0.0
                                                                             alpha:overlayOpacity];
                         }
                         completion:^(BOOL finished){
                             containerView.userInteractionEnabled = YES;
                         }];
    }
}

-(void)popupViewController:(UIViewController *)viewController animated:(BOOL)animated;
{
    if (!viewController)
        [NSException raise:NSInvalidArgumentException
                    format:@"Could not pop up a nil controller"];
    
    if (!viewController.view)
        [NSException raise:NSInvalidArgumentException
                    format:@"Could not pop up a controller with nil view"];
    
    if ([viewController isEqual:self.presentedPopupViewController])
        [NSException raise:NSInvalidArgumentException format:@"The controller %@ is currently popped up", viewController];
    
    
    // Dismiss current popped-up view controller
    [self dismisPopupViewControllerAnimated:NO];
    
    self.presentedPopupViewController = viewController;
    viewController.presentingPopupViewController = self;
    
    // Remove the view from it's current view
    [viewController.view removeFromSuperview];
    
    UIView *containerView = [[self class] containerViewForPresentingViewController:self];
    
    // Add overlay view into the window
    UIView *overlayView = [[UIView alloc] initWithFrame:containerView.bounds];

    overlayView.backgroundColor = [UIColor colorWithWhite:0.0
                                                    alpha:kOverlayOpacity];
    
    [self setTagForOverlayView:overlayView
                 containerView:containerView];
    
    // Add the overlay view into the container
    [containerView addSubview:overlayView];
    
    if (!animated) {
        
        // Add the popup's content into the overlay view
        [overlayView addSubview:viewController.view];
    }
    else {
        
        /* We will move the added view from the bottom of the device toward the top edge */
        
        // Overlay view
        viewController.view.frame = CGRectOffset(overlayView.bounds, 0, CGRectGetHeight(containerView.bounds));
        overlayView.backgroundColor = [UIColor clearColor];
        overlayView.alpha = 0;
        
        [overlayView addSubview:viewController.view];
        
        // Disable user interaction while animating
        containerView.userInteractionEnabled = NO;
        
        [UIView animateWithDuration:kAnimationTime
                         animations:^{
                             
                             viewController.view.frame = overlayView.bounds;
                             overlayView.alpha = 1;
                             overlayView.backgroundColor = [UIColor colorWithWhite:0.0
                                                                                  alpha:kOverlayOpacity];
                         }
                         completion:^(BOOL finished){
                             containerView.userInteractionEnabled = YES;
                         }];
    }
}

-(void)dismisPopupViewControllerAnimated:(BOOL)animated;
{
    if (!self.presentedPopupViewController)
        return;
    
    // Dismiss child popup view controller
    UIViewController *presentedVC = self.presentedPopupViewController;
    if (presentedVC.presentedPopupViewController) {
        [presentedVC dismisPopupViewControllerAnimated:NO];
    }
    
    UIView *containerView = [[self class] containerViewForPresentingViewController:self];
    //    UIView *overlay =  [[[[UIApplication sharedApplication] delegate] window] viewWithTag:kOverlayViewTag];
    UIView *overlay = [self overlayViewInContainerView:containerView];
    
    if (!animated) {
        
        // Remove the controller's view
        [self.presentedPopupViewController.view removeFromSuperview];
        
        // Remove the overlay view
        if (overlay)
            [overlay removeFromSuperview];
        
        // Reset the propperties
        self.presentedPopupViewController.presentingPopupViewController = nil;
        self.presentedPopupViewController = nil;
        self.overlayView = nil;
    }
    else {
        CGRect frame = containerView.frame;
        containerView.userInteractionEnabled = NO;
        [UIView animateWithDuration:kAnimationTime
                         animations:^{
                             
                             self.presentedPopupViewController.view.frame = CGRectOffset(overlay.bounds, 0, CGRectGetHeight(frame));
                             overlay.alpha = 0;
                         }
                         completion:^(BOOL finished){
                             [self.presentedPopupViewController.view removeFromSuperview];
                             [overlay removeFromSuperview];
                             self.presentedPopupViewController.presentingPopupViewController = nil;
                             self.presentedPopupViewController = nil;
                             self.overlayView = nil;
                             containerView.userInteractionEnabled = YES;
                         }];
        
    }
}

-(UIViewController *)presentedPopupViewController;
{
    return objc_getAssociatedObject(self, &poppedupKey);
}

-(void)setPresentedPopupViewController:(UIViewController *)presentedPopupViewController;
{
    objc_setAssociatedObject(self, &poppedupKey, presentedPopupViewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIViewController *)presentingPopupViewController;
{
    return objc_getAssociatedObject(self, &poppingupKey);
}

-(void)setPresentingPopupViewController:(UIViewController *)viewController;
{
    objc_setAssociatedObject(self, &poppingupKey, viewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIView *)overlayView;
{
    return objc_getAssociatedObject(self, @selector(overlayView));
}

-(void)setOverlayView:(UIView *)overlayView;
{
    objc_setAssociatedObject(self, @selector(overlayView), overlayView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (UIView *)containerViewForPresentingViewController:(UIViewController *)presentingViewController;
{
    return [[[UIApplication sharedApplication] delegate] window];
//    return presentingViewController.view;
}

- (void)dismissCurrentPopup;
{
    if (self.presentedPopupViewController.presentedPopupViewController == nil)
        [self dismisPopupViewControllerAnimated:YES];
}

- (void)dismissTap;
{
    // Just to dismiss tap
    DEBUG_LOG(@"%@", NSStringFromSelector(_cmd));
}

- (void)popupViewController:(UIViewController *)viewController animated:(BOOL)animated dimissedWhenTapOverlay:(BOOL)dismissed;
{
    [self popupViewController:viewController animated:animated];
    
    if (dismissed == YES) {
        
        UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] init];
        [tapper addTarget:self
                   action:@selector(dismissCurrentPopup)];
        
        UIView *containerView = [[self class] containerViewForPresentingViewController:self];
        UIView *overlayView = [self overlayViewInContainerView:containerView];
        
        [overlayView addGestureRecognizer:tapper];
    }
}

- (void)setTagForOverlayView:(UIView *)overlayView containerView:(UIView *)containerView;
{
    NSUInteger tag = kOverlayViewTag;
    // Get tag of this view controller
    if (self.view.tag >= tag) {
        tag = self.view.tag;
    }
    
    // Check tag has been used
    UIView *view = [containerView viewWithTag:tag];
    if (view != nil) {
        // Get new tag for overlayView
        tag = view.tag + 1;
    }
    [overlayView setTag:tag];
    [self.presentedPopupViewController.view setTag:tag];
}

- (UIView *)overlayViewInContainerView:(UIView *)containerView;
{
    NSUInteger tag = self.presentedPopupViewController.view.tag;
    UIView *view = [containerView viewWithTag:tag];
    
    if (view != nil)
        return view;
    
    return [containerView viewWithTag:kOverlayViewTag];
}

- (UIViewController *)getTopPresentedPopupViewController;
{
    UIViewController *presentedVC = self.presentedPopupViewController;
    while (presentedVC) {
        UIViewController *nextPresentedVC = presentedVC.presentedPopupViewController;
        if (nextPresentedVC)
            presentedVC = nextPresentedVC;
        else
            return presentedVC;
    }
    
    if (presentedVC)
        return presentedVC;
    else
        return self;
}

@end

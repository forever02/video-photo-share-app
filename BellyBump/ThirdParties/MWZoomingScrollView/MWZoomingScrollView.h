//
//  ZoomingScrollView.h
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MWPhotoProtocol.h"
#import "MWTapDetectingImageView.h"
#import "MWTapDetectingView.h"
#import "BEBImage.h"

@protocol MWZoomingScrollViewDelegate <NSObject>
@end

@interface MWZoomingScrollView : UIScrollView <UIScrollViewDelegate, MWTapDetectingImageViewDelegate, MWTapDetectingViewDelegate> {

}

@property (nonatomic) NSUInteger index;
@property (nonatomic, strong) BEBImage *photo;
@property (nonatomic, weak) UIButton *selectedButton;
@property (nonatomic, weak) UIButton *playButton;
@property (nonatomic, weak) id<MWZoomingScrollViewDelegate> mwZoomingDelegate;

- (id)initWithMWZoomingDelegate:(id<MWZoomingScrollViewDelegate>)delegate;
- (void)displayImage;
- (void)displayImageFailure;
- (void)setMaxMinZoomScalesForCurrentBounds;
- (void)prepareForReuse;
- (void)setImageHidden:(BOOL)hidden;

@end

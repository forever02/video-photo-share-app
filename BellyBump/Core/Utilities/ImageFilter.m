#import "ImageFilter.h"
#import "GPUImage.h"

@interface ImageFilter()
{
    GPUImageOutput<GPUImageInput> *filter;
}

@property (nonatomic, strong) GPUImagePicture *stillImageSource;
@property(readwrite, unsafe_unretained, nonatomic) IBOutlet UISlider *filterSettingsSlider;


@end
@implementation ImageFilter

-(instancetype)init
{
    self = [super init];
    if (self) {
        
        self.stillImageSource = [[GPUImagePicture alloc] init];
    }
    return self;
}


- (UIImage *)gpuImageFromImage:(UIImage *)sourceImage withType:(GPUImageShowcaseFilterType)filterType;
{
 //   NSLog(@"%d", filterType);
    switch (filterType)
    {
        case GPUIMAGE_SATURATION:
        {

            filter = [[GPUImageSaturationFilter alloc] init];
            ((GPUImageSaturationFilter *)filter).saturation = 2.0f;
        }; break;
            
        case GPUIMAGE_CONTRAST:
        {
            filter = [[GPUImageContrastFilter alloc] init];
            ((GPUImageContrastFilter *)filter).contrast = 1.4f;
        }; break;
            
        case GPUIMAGE_BRIGHTNESS:
        {
            // self.title = @"Brightness";
            filter = [[GPUImageBrightnessFilter alloc] init];
            ((GPUImageBrightnessFilter *)filter).brightness = -0.1f;

        }; break;
            
        case GPUIMAGE_LEVELS:
        {
            // self.title = @"Levels";
            
            filter = [[GPUImageLevelsFilter alloc] init];
            [((GPUImageLevelsFilter *)filter) setMin:45.0/255.0 gamma:0.95 max:238.0/255.0];

        }; break;
            
        case GPUIMAGE_EXPOSURE:
        {
            // self.title = @"Exposure";
            filter = [[GPUImageExposureFilter alloc] init];
            ((GPUImageExposureFilter *)filter).exposure = .2f;

        }; break;
            
            
        case GPUIMAGE_HUE:
        {
            // self.title = @"Hue";
            filter = [[GPUImageHueFilter alloc] init];
            ((GPUImageHueFilter *)filter).hue = 90.0;

        }; break;
            
        case GPUIMAGE_WHITEBALANCE:
        {
            // self.title = @"White Balance";
            
            filter = [[GPUImageWhiteBalanceFilter alloc] init];
            ((GPUImageWhiteBalanceFilter *)filter).temperature = 7500.0;

        }; break;
            
        case GPUIMAGE_MONOCHROMERED:
        {
            // self.title = @"Monochrome";
            filter = [[GPUImageMonochromeFilter alloc] init];
            [(GPUImageMonochromeFilter *)filter setColor: (GPUVector4){0.6, 0.09, 0.24, 0.8}];
            
        }; break;
          
        case GPUIMAGE_MONOCHROMEGREEN:
        {
            filter = [[GPUImageMonochromeFilter alloc] init];
            [(GPUImageMonochromeFilter *)filter setColor: (GPUVector4){0.0f, 0.8f, 0.0f, 0.8f}];
            
        }; break;
            
        case   GPUIMAGE_MONOCHROMEBLUE:
        {
            filter = [[GPUImageMonochromeFilter alloc] init];
            [(GPUImageMonochromeFilter *)filter setColor: (GPUVector4){0.0f, 0.0f, 0.8f, 0.8f}];
            
            
        }; break;
            
        case  GPUIMAGE_MONOCHROMEPURPLE1:
        {
            filter = [[GPUImageMonochromeFilter alloc] init];
            [(GPUImageMonochromeFilter *)filter setColor: (GPUVector4){0.81f, 0.24f, 1.0f, 0.8f}];
            
        }; break;
            
        case  GPUIMAGE_MONOCHROMEPURPLE2:
        {
            filter = [[GPUImageMonochromeFilter alloc] init];
            [(GPUImageMonochromeFilter *)filter setColor: (GPUVector4){0.93f, 0.65f, 0.95f, 0.8f}];
            
        }; break;
            
        case GPUIMAGE_MONOCHROMEYELLOW:
        {
            filter = [[GPUImageMonochromeFilter alloc] init];
            [(GPUImageMonochromeFilter *)filter setColor: (GPUVector4){0.95f, 0.94f, 0.84f, 0.8f}];
            
        }; break;
            
        case GPUIMAGE_MONOCHROMECYAN:
        {
            filter = [[GPUImageMonochromeFilter alloc] init];
            [(GPUImageMonochromeFilter *)filter setColor: (GPUVector4){0.86f, 0.96f, 0.96f, 0.8f}];
            
        }; break;
            
        case GPUIMAGE_MONOCHROMEORANGE:
        {
            filter = [[GPUImageMonochromeFilter alloc] init];
            [(GPUImageMonochromeFilter *)filter setColor: (GPUVector4){0.99f, 0.82f, 0.5f, 0.8f}];
            
        }; break;
            
        case GPUIMAGE_TONECURVE:
        {
            // self.title = @"Tone curve";
            
            filter = [[GPUImageToneCurveFilter alloc] init];
            NSArray *defaultCurve = [NSArray arrayWithObjects:
                                     [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                                     [NSValue valueWithCGPoint:CGPointMake(0.65f, 0.5f)],
                                     [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)], nil];
            
            [(GPUImageToneCurveFilter *)filter setBlueControlPoints:defaultCurve];
            
        }; break;
            
        case GPUIMAGE_HIGHLIGHTSHADOW:
        {
            filter = [[GPUImageHighlightShadowFilter alloc] init];
            [(GPUImageHighlightShadowFilter *)filter setShadows:0.7f];

        }; break;
            
        case GPUIMAGE_POLARPIXELLATE:
        {
            filter = [[GPUImagePolarPixellateFilter alloc] init];
        }; break;
            
        case GPUIMAGE_PIXELLATE_POSITION:
        {
            filter = [[GPUImagePolarPixellateFilter alloc] init];
            ((GPUImagePolarPixellateFilter *)filter).pixelSize = CGSizeMake(0.02f, 0.02f);

        }; break;

        case GPUIMAGE_HALFTONE:
        {
            filter = [[GPUImageHalftoneFilter alloc] init];
            ((GPUImageHalftoneFilter *)filter).fractionalWidthOfAPixel = 0.0001;

        }; break;
 
        case GPUIMAGE_GRAYSCALE:
        {
            filter = [[GPUImageGrayscaleFilter alloc] init];
        }; break;
            
        case GPUIMAGE_SMOOTHTOON:
        {
            filter = [[GPUImageSmoothToonFilter alloc] init];
            ((GPUImageSmoothToonFilter *)filter).threshold = 6.0f;
        }; break;
            
        case GPUIMAGE_EMBOSS:
        {
            filter = [[GPUImageEmbossFilter alloc] init];
        }; break;

        case GPUIMAGE_POSTERIZE:
        {
            filter = [[GPUImagePosterizeFilter alloc] init];
        }; break;
  
        case GPUIMAGE_PINCH:
        {
            filter = [[GPUImagePinchDistortionFilter alloc] init];
        }; break;
 
        case GPUIMAGE_DILATION:
        {
            self.filterSettingsSlider.hidden = YES;
            
            filter = [[GPUImageRGBDilationFilter alloc] initWithRadius:2];
        }; break;

        case GPUIMAGE_VIGNETTE:
        {
            filter = [[GPUImageVignetteFilter alloc] init];
        }; break;
            
        case GPUIMAGE_BOXBLUR:
        {
            filter = [[GPUImageBoxBlurFilter alloc] init];
        }; break;
            
        case GPUIMAGE_UIELEMENT:
        {
            filter = [[GPUImageSepiaFilter alloc] init];
        }; break;
            
        case GPUIMAGE_MONOCHROMESUMMER:
        {
            filter = [[GPUImageMonochromeFilter alloc] init];
            [(GPUImageMonochromeFilter *)filter setColor: (GPUVector4){199.0f/255.0f, 134.0f/255.0f, 89.0f/255.0f, 1.0f}];
        }; break;
            
        case GPUIMAGE_MONOCHROMESOFTBLUE:
        {
            filter = [[GPUImageMonochromeFilter alloc] init];
            [(GPUImageMonochromeFilter *)filter setColor: (GPUVector4){179.0f/255.0f, 170.0f/255.0f, 219.0f/255.0f, 1.0f}];
        }; break;
            
        default: filter = [[GPUImageSepiaFilter alloc] init]; break;
    }
    
    self.stillImageSource = [[GPUImagePicture alloc] initWithImage:sourceImage];
    
    [self.stillImageSource addTarget:filter];
    [filter useNextFrameForImageCapture];
    [self.stillImageSource processImage];
    return  [filter imageFromCurrentFramebuffer];
}

@end

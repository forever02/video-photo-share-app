#pragma once
#import "BEBAppearanceConstants.h"

/** BOOL: Detect if device is the Simulator **/
#define IS_SIMULATOR (TARGET_IPHONE_SIMULATOR)

#define DEGREES_TO_RADIANS(x) ((M_PI * (x)) / 180.0)

#define SYSTEM_VERSION_LESS_THAN(v) \
([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_4 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 480.0f)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_IPHONE_6 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0f)
#define IS_IPHONE_6PLUS (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0f)
#define IS_RETINA ([[UIScreen mainScreen] scale] == 2.0f)

#define iOS_Version [[[UIDevice currentDevice] systemVersion] floatValue]

#define iOS_Current_Device [[UIDevice currentDevice] model]

#define RGB(r, g, b, a) \
[UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a]

#define isLandscapeInterface UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)

#define STATUS_CODE_ERROR(error) [[[error userInfo] objectForKey:AFNetworkingOperationFailingURLResponseErrorKey] statusCode]

#define SCREEN_WIDTH (CGRectGetWidth([UIScreen mainScreen].bounds))
#define SCREEN_HEIGHT (CGRectGetHeight([UIScreen mainScreen].bounds))

#define NEW_IMAGE_SIZE_FIT_WIDTH(size) CGSizeMake(floorf((SCREEN_WIDTH/size.width) * size.width), floorf((SCREEN_WIDTH/size.width) * size.height))

// Make macro for debug.
#define SHOW_DEBUG 1

#if SHOW_DEBUG == 1
#define DEBUG_LOG(fmt, ...) NSLog((@"File: %s - Line:%d: " fmt), [BEBUtilities getFileName:__FILE__], __LINE__, ##__VA_ARGS__)
#elif SHOW_DEBUG == 0
    #define DEBUG_LOG(fmt, ...) do {} while(0)
#endif

// Fonts macro
#define RegularFontWithSize(x) [UIFont fontWithName:kFontNameRegular size:x]
#define LightFontWithSize(x) [UIFont fontWithName:kFontNameLight size:x]
#define BoldFontWithSize(x) [UIFont fontWithName:kFontNameBold size:x]

// Key by id for dictionary
#define kKeyById(id) [NSString stringWithFormat:@"%@", id]

// Images
#define kAvatarDefault [UIImage imageNamed:@"avatar_default"]
#define BackgroundColorLightGray RGB(237.0f, 237.0f, 237.0f, 1.0f)



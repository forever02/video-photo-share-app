//
//  BEBAppearanceManager.m
//  BellyBump
//
//  Created by PHAN P. Dong (Alain) on 10/20/15.
//  Copyright (c) 2015 Wayfarer. All rights reserved.
//

#import "BEBAppearanceManager.h"
#import "BEBAppearanceConstants.h"
#import "BEBMacro.h"

@implementation BEBAppearanceManager

+ (instancetype)sharedInstance;
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (void)setupDefaultConfiguration {
    
    /* Navigation bar: Back nav icon, nav background color, nav text's attributes */
//    [[UINavigationBar appearance] setBackIndicatorImage:[UIImage imageNamed:@"icon_nav_back"]];
//    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"icon_nav_back"]];
    [[UINavigationBar appearance] setBarTintColor:kNavigationBarColor];
    NSDictionary *navTextAttributes = @{
                                        NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:15.0f],
                                        NSForegroundColorAttributeName : [UIColor whiteColor],
                                        };
    [[UINavigationBar appearance] setTitleTextAttributes:navTextAttributes];
}

@end

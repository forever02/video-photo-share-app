//
//  BEBAppearanceManager.h
//  BellyBump
//
//  Created by PHAN P. Dong (Alain) on 10/20/15.
//  Copyright (c) 2015 Wayfarer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BEBAppearanceManager : NSObject

+ (instancetype)sharedInstance;

- (void)setupDefaultConfiguration;

@end

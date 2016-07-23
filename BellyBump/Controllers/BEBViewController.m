//
//  BEBBaseViewController.m
//  BellyBump
//
//  Created by PHAN P. Dong (Alain) on 9/13/15.
//  Copyright (c) 2015 Wayfarer. All rights reserved.
//

#import "BEBViewController.h"

static NSString *const kNavigationBarTintColor = @"kNavigationBarTintColor";
static NSString *const kNavigationBarTranslucent = @"kNavigationBarTranslucent";
static NSString *const kNavigationBarTitleTextAttributes = @"kNavigationBarTitleTextAttributes";

@interface BEBViewController ()

@property (nonatomic, strong) NSMutableDictionary *appearanceSettings;

@end

@implementation BEBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self setupAppreance];
    
    self.appearanceSettings = [NSMutableDictionary dictionary];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupAppreance {
    
    if (self.navigationController.viewControllers[0] != self) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"icon_nav_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(goBack)];
    }
}

- (void)goBack {
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)saveAppearanceSettings {
    
    if (self.navigationController) {
        [self.appearanceSettings setObject:self.navigationController.navigationBar.barTintColor
                                    forKey:kNavigationBarTintColor];
        [self.appearanceSettings setObject:@(self.navigationController.navigationBar.translucent)
                                    forKey:kNavigationBarTranslucent];
        [self.appearanceSettings setObject:self.navigationController.navigationBar.titleTextAttributes
                                    forKey:kNavigationBarTitleTextAttributes];
    }
}

- (void)restoreAppearanceSettings {
    
    if (self.navigationController) {
        self.navigationController.navigationBar.barTintColor = self.appearanceSettings[kNavigationBarTintColor];
        self.navigationController.navigationBar.translucent = [self.appearanceSettings[kNavigationBarTranslucent] boolValue];
        self.navigationController.navigationBar.titleTextAttributes = self.appearanceSettings[kNavigationBarTitleTextAttributes];
    }
}

@end

//
//  AdViewController.m
//
//  iAdPlusAdMob
//	Version 1.0.4
//
//  Created by PJ Cook on 22/03/2012.
//  Copyright (c) 2012 Software101. All rights reserved.
//
//  Distributed under the permissive zlib License
//  Get the latest version from either of this location:
//
//  https://github.com/pjcook/iAdPlusAdMob
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import "AdViewController.h"
#import "AdBannerController.h"
#import "GADBannerView.h"

@interface AdViewController ()

- (void)layoutAnimated:(BOOL)animated;
- (void)layoutAnimated:(BOOL)animated withInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end

@implementation AdViewController

- (void)setView:(UIView *)view origin:(CGPoint)origin
{
    CGRect rect = view.frame;
    rect.origin = origin;
    view.frame = rect;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    // Configure AdBannerController
    AdBannerController *adController = [AdBannerController sharedInstance];
	adController.delegate = self;
    
    // Set initial AdView positions
    [self setView:adController.adMobBannerView origin:CGPointMake(0, self.view.frame.size.height)];
    [self setView:adController.bannerView origin:CGPointMake(0, self.view.frame.size.height)];
    
    // Ad AdViews to the UI
	[self.view addSubview:adController.adMobBannerView];
	[self.view addSubview:adController.bannerView];
    
    [self refreshAdView];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
    // Clean up AdViews
    AdBannerController *adController = [AdBannerController sharedInstance];
	adController.delegate = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Clean up AdViews
    AdBannerController *adController = [AdBannerController sharedInstance];
	adController.delegate = nil;
    [adController.adMobBannerView removeFromSuperview];
    [adController.bannerView removeFromSuperview];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self layoutAnimated:NO];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self layoutAnimated:duration > 0.0 withInterfaceOrientation:toInterfaceOrientation];
}

- (void)layoutAnimated:(BOOL)animated
{
	[self layoutAnimated:animated withInterfaceOrientation:self.interfaceOrientation];
}

- (void)layoutAnimated:(BOOL)animated withInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    AdBannerController *adController = [AdBannerController sharedInstance];

	// iAd logic
    [adController.bannerView sizeThatFits:self.view.frame.size];
//    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
//        adController.bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
//    } else {
//        adController.bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
//    }
    
    CGFloat tabBarAdjustment = 0.0f;
    if (self.tabBarController && self.tabBarController.tabBar.isTranslucent)
    {
        tabBarAdjustment = self.tabBarController.tabBar.frame.size.height;
    }
    
    CGRect frame = self.view.frame;
    CGRect contentFrame = frame;
    CGRect bannerFrame = adController.bannerView.frame;
    if (adController.bannerView.bannerLoaded)
	{
        contentFrame.size.height = frame.size.height - frame.size.height;
        bannerFrame.origin.y = frame.size.height - bannerFrame.size.height - tabBarAdjustment;
    } 
	else 
	{
        bannerFrame.origin.y = frame.size.height;
    }
	
	// AdMob logic
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        [adController.adMobBannerView setAdSize:kGADAdSizeSmartBannerPortrait];
    } else {
        [adController.adMobBannerView setAdSize:kGADAdSizeSmartBannerLandscape];
    }
    
	CGRect adMobFrame = adController.adMobBannerView.frame;
	if (!adController.bannerView.bannerLoaded && adController.hasAdMobAd)
	{
		contentFrame.size.height = frame.size.height - adMobFrame.size.height;
		adMobFrame.origin.y = frame.size.height - adMobFrame.size.height - tabBarAdjustment;
	}
	else 
	{
		adMobFrame.origin.y = frame.size.height;
	}
	//NSLog(@"iAd:%f %f %f %f", bannerFrame.origin.x, bannerFrame.origin.y, bannerFrame.size.width, bannerFrame.size.height);
	//NSLog(@"Adm:%f %f %f %f", adMobFrame.origin.x, adMobFrame.origin.y, adMobFrame.size.width, adMobFrame.size.height);
    
	// size all the frames to fit
    [UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^
    {
        self.contentView.frame = contentFrame;
        [self.contentView layoutIfNeeded];
        adController.bannerView.frame = bannerFrame;
		adController.adMobBannerView.frame = adMobFrame;
        NSLog(@"iAd has superview:%@", adController.bannerView.superview ? @"YES" : @"NO");
        if (adController.bannerView.superview)
        {
            [adController.bannerView.superview addSubview:adController.bannerView];
        }
        else
        {
            [self.view addSubview:adController.bannerView];
        }
        NSLog(@"Admob has superview:%@", adController.adMobBannerView.superview ? @"YES" : @"NO");
        if (adController.adMobBannerView.superview)
        {
            [adController.adMobBannerView.superview addSubview:adController.adMobBannerView];
        }
        else
        {
            [self.view addSubview:adController.adMobBannerView];
        }
    }];
}

- (void)refreshAdView
{
	[self layoutAnimated:YES];
}

#pragma -
#pragma AdBannerControllerDelegate methods

- (void)showBannerView:(ADBannerView *)bannerView animated:(BOOL)animated
{
    [self layoutAnimated:animated];
}

- (void)hideBannerView:(ADBannerView *)bannerView animated:(BOOL)animated
{
    [self layoutAnimated:animated];
}

- (void)showAdMobBannerView:(GADBannerView *)bannerView animated:(BOOL)animated
{
	[self layoutAnimated:animated];
}

- (void)hideAdMobBannerView:(GADBannerView *)bannerView animated:(BOOL)animated
{
	[self layoutAnimated:animated];
}

@end

//
//  AdViewController.m
//
//  iAdPlusAdMob
//	Version 1.0.0
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

@property (nonatomic, strong) ADBannerView *bannerView;
@property (nonatomic, strong) GADBannerView *adMobBannerView;
@property (nonatomic, strong) UIView *adMobContainer;

- (void)layoutAnimated:(BOOL)animated;
- (void)layoutAnimated:(BOOL)animated withInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end

@implementation AdViewController

@synthesize bannerView;
@synthesize adMobBannerView;
@synthesize adMobContainer;
@synthesize contentView;

- (void)viewDidLoad
{
	[super viewDidLoad];
	CGRect adMobBannerRect = [AdBannerController sharedInstance].adMobBannerView.bounds;
	adMobBannerRect.size.width = self.view.bounds.size.width;
	adMobBannerRect.origin.x = 0.0f;
	adMobBannerRect.origin.y = self.view.bounds.size.height;

	// create a container for the adMob AD banner so that we can align it and give it a background color if required.
	self.adMobContainer = [[UIView alloc] initWithFrame:adMobBannerRect];
	
	// This makes the adMobContainer stretch across the screen as required (landscape mode).
	self.adMobContainer.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
	
	// This applies a background color to the adMobContainer.  This means in landscape mode where the AD doesn't fill the width, you can hide the UI to give a consistent UI.  Set to transparent if not required.
	self.adMobContainer.backgroundColor = [UIColor redColor];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
	[AdBannerController sharedInstance].delegate = self;
	self.bannerView = [AdBannerController sharedInstance].bannerView;
	self.adMobBannerView = [AdBannerController sharedInstance].adMobBannerView;
	CGRect adMobRect = self.adMobBannerView.bounds;
	adMobRect.origin.x = MAX(0.0f, ceil((self.view.frame.size.width - adMobRect.size.width) / 2.0f));
	adMobBannerView.frame = adMobRect;
	self.adMobBannerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;

	[self.adMobContainer addSubview:self.adMobBannerView];
	[self.view addSubview:self.adMobContainer];
	[self.view addSubview:self.bannerView];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	self.bannerView = nil;
	self.adMobBannerView = nil;
    [AdBannerController sharedInstance].delegate = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
	self.contentView = nil;
	self.bannerView = nil;
	self.adMobBannerView = nil;
	self.adMobContainer = nil;
    [AdBannerController sharedInstance].delegate = nil;
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
	// iAd logic
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        self.bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
    } else {
        self.bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
    }
    
    CGRect contentFrame = self.view.bounds;
    CGRect bannerFrame = self.bannerView.frame;
    if (bannerView.bannerLoaded) 
	{
        contentFrame.size.height -= bannerView.frame.size.height;
        bannerFrame.origin.y = contentFrame.size.height;
    } 
	else 
	{
        bannerFrame.origin.y = contentFrame.size.height;
    }
	
	// AdMob logic
	CGRect adMobContainerFrame = self.adMobContainer.frame;
	adMobContainerFrame.size.height = self.adMobBannerView.frame.size.height;
	if (!bannerView.bannerLoaded && [AdBannerController sharedInstance].hasAdMobAd)
	{
		contentFrame.size.height -= adMobContainerFrame.size.height;
		adMobContainerFrame.origin.y = contentFrame.size.height;
	}
	else 
	{
		adMobContainerFrame.origin.y = self.view.bounds.size.height;
	}
	NSLog(@"%f %f %f %f", self.adMobBannerView.frame.origin.x, self.adMobBannerView.frame.origin.y, self.adMobBannerView.frame.size.width, self.adMobBannerView.frame.size.height);
    
	// size all the frames to fit
    [UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{
        contentView.frame = contentFrame;
        [contentView layoutIfNeeded];
        bannerView.frame = bannerFrame;
		self.adMobContainer.frame = adMobContainerFrame;
    }];
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

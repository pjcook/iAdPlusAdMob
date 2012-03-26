//
//  AdBannerController.m
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

#import "AdBannerController.h"
#import "AdBannerConstants.h"

@interface AdBannerController()
{
	id<AdBannerControllerDelegate> _delegate;
}

@property (nonatomic, strong, readwrite) ADBannerView *bannerView;
@property (nonatomic, strong, readwrite) GADBannerView *adMobBannerView;
@property (nonatomic, assign, readwrite) BOOL hasIAd;
@property (nonatomic, assign, readwrite) BOOL hasAdMobAd;

- (CGRect)adMobBannerSizeForDisplay;
- (GADRequest *)createAdMobRequest;

@end

@implementation AdBannerController

@synthesize bannerView;
@synthesize adMobBannerView;
@synthesize delegate = _delegate;
@synthesize hasIAd;
@synthesize hasAdMobAd;

- (void)dealloc
{
    self.bannerView.delegate = nil;
	self.adMobBannerView.delegate = nil;
}

- (id)init
{
    self = [super init];
    if (self)
    {
		// create iAd banner
		if (shouldDisplayIAds)
		{
			self.bannerView = [[ADBannerView alloc] init];
			self.bannerView.delegate = self;
		}
		
		// create admob banner
		if (shouldDisplayAdMobAds && ![adMobId isEqualToString:@"NoAds"])
		{
			self.adMobBannerView = [[GADBannerView alloc] initWithFrame:[self adMobBannerSizeForDisplay]];
			self.adMobBannerView.delegate = self;
			self.adMobBannerView.adUnitID = adMobId;
		}
    }
    return self;
}

static AdBannerController *_sharedInstance;

+ (AdBannerController *)sharedInstance
{
    
    if (_sharedInstance == nil)
    {
        @synchronized(self)
        {
            if (_sharedInstance == nil)
            {
                _sharedInstance = [[AdBannerController alloc] init];
            }
        }
    }
    return _sharedInstance;
}

+ (void)removeSharedInstance
{
    @synchronized(self)
    {
        _sharedInstance.delegate = nil;
        _sharedInstance = nil;
    }
}

- (CGRect)adMobBannerSizeForDisplay
{
	CGRect rect;
	UIWindow *mainWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
	
	//create size depending on device and orientation
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
	{
		rect = CGRectMake(0.0f, mainWindow.bounds.size.height, 
						   GAD_SIZE_728x90.width, 
						   GAD_SIZE_728x90.height);
	}
	else
	{
		rect = CGRectMake(0.0f, 
						   mainWindow.bounds.size.height, 
						   GAD_SIZE_320x50.width, 
						   GAD_SIZE_320x50.height);
	}
	return rect;
}

- (GADRequest *)createAdMobRequest
{
	GADRequest *request = [GADRequest request];
	
	//Make the request for a test ad
	request.testDevices = [NSArray arrayWithObjects:
						   GAD_SIMULATOR_ID,			// Simulator
						   @"9d0f6a4c047b333e945c6c1c43cb84feacb60262",
						   nil];
	
	return request;
}

- (void)setDelegate:(id<AdBannerControllerDelegate>)adelegate
{
	_delegate = adelegate;
	if (shouldDisplayAdMobAds)
	{
		self.adMobBannerView.rootViewController = (UIViewController *)_delegate;
		if (_delegate != nil)
		{
			[self.adMobBannerView loadRequest:[self createAdMobRequest]];
		}
	}
}

- (id<AdBannerControllerDelegate>)delegate
{
	return _delegate;
}

#pragma -
#pragma ADBannerViewDelegate methods

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
	self.hasIAd = YES;
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(showBannerView:animated:)])
    {
        [self.delegate showBannerView:banner animated:YES];
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
	self.hasIAd = NO;
	NSLog(@"%@\n%@", [error localizedDescription], [error localizedFailureReason]);
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(hideBannerView:animated:)])
    {
        [self.delegate hideBannerView:banner animated:YES];
    }
}

#pragma mark GADBannerViewDelegate methods

// Since we've received an ad, let's go ahead and set the frame to display it.
- (void)adViewDidReceiveAd:(GADBannerView *)adView 
{
	self.hasAdMobAd = YES;
	CGRect rect = adMobBannerView.frame;
	rect.size.width = adView.frame.size.width;
	rect.size.height = adView.frame.size.height;
	adView.frame = rect;
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(showAdMobBannerView:animated:)])
    {
        [self.delegate showAdMobBannerView:adView animated:YES];
    }
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error 
{
	self.hasAdMobAd = NO;
	NSLog(@"%@\n%@", [error localizedDescription], [error localizedFailureReason]);
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(hideAdMobBannerView:animated:)])
    {
        [self.delegate hideAdMobBannerView:view animated:YES];
    }
}

@end

//
//  AdBannerController.m
//
//  iAdPlusAdMob
//	Version 1.0.2
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

NSString *const kAdBannerControllerDefaultAdMobId = @"NoAds";

@interface AdBannerController()

@property (nonatomic, strong, readwrite) ADBannerView *bannerView;
//@property (nonatomic, strong, readwrite) GADBannerView *adMobBannerView;
@property (nonatomic, readwrite) BOOL hasIAd;
@property (nonatomic, readwrite) BOOL hasAdMobAd;

- (GADRequest *)createAdMobRequest;

@end

@implementation AdBannerController

@dynamic shouldDisplayIAds;
@dynamic shouldDisplayAdMobAds;
@dynamic delegate;

BOOL _shouldDisplayIAds;
BOOL _shouldDisplayAdMobAds;
id<AdBannerControllerDelegate> _delegate;

- (id)init
{
    self = [super init];
    if (self)
    {
		self.bannerView = nil;
		self.adMobBannerView = nil;
		self.adMobId = kAdBannerControllerDefaultAdMobId;
		self.shouldDisplayIAds = NO;
		self.shouldDisplayAdMobAds = NO;
    }
    return self;
}

static AdBannerController *_sharedInstance;

+ (AdBannerController *)sharedInstance
{
    if (_sharedInstance == nil)
    {
        _sharedInstance = [[AdBannerController alloc] init];
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

- (void)setShouldDisplayIAds:(BOOL)shouldDisplayIAds
{
	_shouldDisplayIAds = shouldDisplayIAds;
	
	// create iAd banner
	if (shouldDisplayIAds)
	{
		self.bannerView = [[ADBannerView alloc] init];
		self.bannerView.delegate = self;
	}
	else 
	{
		self.bannerView.delegate = nil;
		self.bannerView = nil;
	}
}

- (BOOL)shouldDisplayIAds
{
	return _shouldDisplayIAds;
}

- (void)setShouldDisplayAdMobAds:(BOOL)shouldDisplayAdMobAds
{
	_shouldDisplayAdMobAds = shouldDisplayAdMobAds;
	
	// create admob banner
	if (shouldDisplayAdMobAds && ![_adMobId isEqualToString:kAdBannerControllerDefaultAdMobId])
	{
		self.adMobBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
		self.adMobBannerView.delegate = self;
		self.adMobBannerView.adUnitID = _adMobId;
	}
	else 
	{
		self.adMobBannerView.delegate = nil;
		self.adMobBannerView = nil;
	}
}

- (BOOL)shouldDisplayAdMobAds
{
	return _shouldDisplayAdMobAds;
}

- (GADRequest *)createAdMobRequest
{
	GADRequest *request = [GADRequest request];
	
	return request;
}

- (void)setDelegate:(id<AdBannerControllerDelegate>)adelegate
{
	_delegate = adelegate;
	if (_shouldDisplayAdMobAds)
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
	NSLog(@"ERROR (iAds):%@\n%@", [error localizedDescription], [error localizedFailureReason]);
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
	CGRect rect = _adMobBannerView.frame;
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
	NSLog(@"ERROR (AdMob):%@\n%@", [error localizedDescription], [error localizedFailureReason]);
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(hideAdMobBannerView:animated:)])
    {
        [self.delegate hideAdMobBannerView:view animated:YES];
    }
}

@end

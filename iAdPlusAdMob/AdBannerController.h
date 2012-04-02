//
//  AdBannerController.h
//
//  iAdPlusAdMob
//  Version 1.0.0
//
//  Created by PJ Cook on 22/03/2012.
//  Copyright (c) 2012 Software101. All rights reserved.
//
//  Distributed under the permissive zlib License
//  Get the latest version from here:
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

#import <Foundation/Foundation.h>
#import <iAd/iAd.h>
#import "GADBannerView.h"

@protocol AdBannerControllerDelegate;

@interface AdBannerController : NSObject
    <ADBannerViewDelegate, GADBannerViewDelegate>

@property (nonatomic, strong) id<AdBannerControllerDelegate> delegate;
@property (nonatomic, strong, readonly) ADBannerView *bannerView;
@property (nonatomic, strong, readonly) GADBannerView *adMobBannerView;
@property (nonatomic, assign, readonly) BOOL hasIAd;
@property (nonatomic, assign, readonly) BOOL hasAdMobAd;
@property (nonatomic, strong) NSString *adMobId;
@property (nonatomic, assign) BOOL shouldDisplayIAds;
@property (nonatomic, assign) BOOL shouldDisplayAdMobAds;

+ (AdBannerController *)sharedInstance;
+ (void)removeSharedInstance;

@end

@protocol AdBannerControllerDelegate <NSObject>

- (void)showBannerView:(ADBannerView *)bannerView animated:(BOOL)animated;
- (void)hideBannerView:(ADBannerView *)bannerView animated:(BOOL)animated;
- (void)showAdMobBannerView:(GADBannerView *)bannerView animated:(BOOL)animated;
- (void)hideAdMobBannerView:(GADBannerView *)bannerView animated:(BOOL)animated;

@end

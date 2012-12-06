Purpose
--------------

iAdPlusAdMob is a simple library that allows you to ad iAds and AdMob advertising to your applications with the smallest amount of effort.  You simply need to include the library files in your project and make sure that any view controllers that you would like to include Ads inherit from the AdViewController class.  In order for the class to work fully, you should place your content inside the contentView view of the class however.  Doing this will allow the class to dynamically resize the main content view to accommodate the Ads when it is served.  You should therefore make sure that any content that you put in the contentView view is either in a scrollview or some other appropriate container so that content is not hidden under the Ads.

Currently this project uses arc.  I can commit or create a non arc version if required.


Installation
--------------

To install iAdPlusAdMob into your app, drag the following files into your project:
 - AdViewController.h and .m
 - AdBannerController.h and .m

Make sure that you include the iAd.framework in your project also.

Then simply inherit a UIViewController from the AdViewContoller class instead of directly from UIViewController.

You will also need to configure iAds in iTunes Connect before you submit your app to Apple.  Please go here for more information: 
https://developer.apple.com/appstore/resources/iad/index.html
https://developer.apple.com/appstore/resources/iad/index.html#prepare

You will need to be logged in to iTunesConnect view these documents.

You should download the latest AdMob framework from here: https://developers.google.com/mobile-ads-sdk/download

and also include the following frameworks:
 - StoreKit
 - AudioToolbox
 - MessageUI
 - SystemConfiguration
 - CoreGraphics
 - AdSupport

You can find additional AdMob documentation here if you're interested: https://developers.google.com/mobile-ads-sdk/docs/ios/fundamentals

Once you have added the code library and additional frameworks to your project, the simplest way to configure this library is to add the following code to the top of your application delegate file:

+ (void)initialize
{
	// Configure AdBannerController
	[AdBannerController sharedInstance].adMobId = @"Your admob app id here";
	[AdBannerController sharedInstance].shouldDisplayIAds = YES;
	[AdBannerController sharedInstance].shouldDisplayAdMobAds = YES;
}

The static initialize method is only called once during the application life cycle and is therefore the best place to singularly initialize any of your components and libraries.

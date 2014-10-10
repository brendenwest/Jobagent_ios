//
//  Ads.m
//
//  Created by Brenden West on 9/8/14.
//  Copyright (c) 2014 Brenden West. All rights reserved.
//

#import "AppDelegate.h"
#import "Ads.h"

@implementation Ads

#pragma Ad code

+ (GADRequest *)request {
    
    GADRequest *request = [GADRequest request];
    
    // Make the request for a test ad if on the simulator as well as any test devices
    request.testDevices = @[ GAD_SIMULATOR_ID ];
    
    // pass current location info on ad request
    //    [request setLocationWithDescription:[NSString stringWithFormat:@"%@ %@",[curLocation objectForKey:@"postalcode"],[curLocation objectForKey:@"country"]]];
    
    // pass current location info on ad request
//    [request setLocationWithDescription:[NSString stringWithFormat:@"%@ %@",[[NSUserDefaults standardUserDefaults] stringForKey:@"postalcode"], curLocale]];
    
    return request;
}

#pragma mark GADBannerViewDelegate implementation

// We've received an ad successfully.
+ (void)adViewDidReceiveAd:(GADBannerView *)adView {
    NSLog(@"Received ad successfully");
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"adView:didFailToReceiveAdWithError:%@", [error localizedDescription]);
}

+ (void)getAd:(UIViewController *)vc {
    // Create ad view of the standard size at the bottom of the screen. Account for nav bar & tab bar heights
    // Available AdSize constants are explained in GADAdSize.h.

    double statusBarOffset = (IS_OS_7_OR_LATER) ? 20.0 : 0;
    double titleBarOffset = (vc.navigationController) ? vc.navigationController.navigationBar.frame.size.height : vc.tabBarController.tabBar.frame.size.height;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    CGPoint origin = CGPointMake((screenWidth-320)/2,
                                 screenHeight - titleBarOffset - CGSizeFromGADAdSize(kGADAdSizeBanner).height - statusBarOffset + 14);
    
    // Use predefined GADAdSize constants to define the GADBannerView.
    GADBannerView *bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner origin:origin];
    
    // Specify the ad unit ID.
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    bannerView_.adUnitID = [appDelegate.configuration objectForKey:@"adUnitID"];
    
    
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    bannerView_.rootViewController = vc;
    [vc.view addSubview:bannerView_];
    
    // Initiate a generic request to load it with an ad.
    [bannerView_ loadRequest:[GADRequest request]];
}


@end

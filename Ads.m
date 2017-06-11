//
//  Ads.m
//
//  Created by Brenden West on 9/8/14.
//  Copyright (c) 2014 Brenden West. All rights reserved.
//

#import "AppDelegate.h"
#import "Ads.h"

@import GoogleMobileAds;

@implementation Ads

#pragma Ad code
/*
+ (GADRequest *)request {
    
    GADRequest *request = [GADRequest request];
    
    // Make the request for a test ad if on the simulator as well as any test devices
    request.testDevices = @[ kGADSimulatorID ];
    
    // pass current location info on ad request
    //    [request setLocationWithDescription:[NSString stringWithFormat:@"%@ %@",[curLocation objectForKey:@"postalcode"],[curLocation objectForKey:@"country"]]];
    
    // pass current location info on ad request
//    [request setLocationWithDescription:[NSString stringWithFormat:@"%@ %@",[[NSUserDefaults standardUserDefaults] stringForKey:@"postalcode"], curLocale]];
    
    return request;
}
 */

+ (void)getAd:(UIViewController *)vc {

    double statusBarOffset = (IS_OS_7_OR_LATER) ? 20.0 : 0;
    double titleBarOffset = (vc.navigationController) ? vc.navigationController.navigationBar.frame.size.height : vc.tabBarController.tabBar.frame.size.height;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    CGPoint origin = CGPointMake((screenWidth-320)/2,
                                 screenHeight - titleBarOffset - CGSizeFromGADAdSize(kGADAdSizeBanner).height - statusBarOffset + 14);

    GADBannerView *bannerView_ = [[GADBannerView alloc]
                       initWithAdSize:kGADAdSizeBanner origin:origin];

    GADRequest *request = [GADRequest request];
    request.testDevices = @[ kGADSimulatorID ];
    
    [vc.view addSubview:bannerView_];
    
    // Specify the ad unit ID.
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    bannerView_.adUnitID = [appDelegate.configuration objectForKey:@"adUnitID"];

    bannerView_.rootViewController = vc;
    [bannerView_ loadRequest:request];

}

@end

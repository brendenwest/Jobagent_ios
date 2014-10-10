//
//  Ads.h
//  techsaurus
//
//  Created by Brenden West on 9/8/14.
//  Copyright (c) 2014 Brenden West. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GADRequest.h"
#import "GADBannerView.h"

@interface Ads : NSObject

+ (void)getAd:(UIViewController *)view;

@end
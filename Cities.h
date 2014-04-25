//
//  Cities.h
//  jobagent
//
//  Created by mac on 3/29/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class AppDelegate;

@interface Cities : UITableViewController <NSXMLParserDelegate> {

    AppDelegate *del;

	NSArray *placemarks;
	CLPlacemark *location;
	
}

@property (nonatomic, strong) AppDelegate *del;
@property (nonatomic, strong) NSArray *placemarks;
@property (nonatomic, strong) CLPlacemark *location;


@end
//
//  Tasks.h
//  jobagent
//
//  Created by mac on 2/24/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "GADBannerView.h"

@interface Tips : UIViewController < UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate> {

	IBOutlet UITableView	*tableView;
//  UIButton *btnTips;
//    UILabel *lblAbout;
	
    // Google ad instance
	GADBannerView *bannerView_;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIButton *btnTips;
@property (nonatomic, weak) IBOutlet UILabel *lblAbout;

@property (strong, nonatomic) NSArray *allItems;

- (IBAction)shareJobAgent:(id)sender;
- (GADRequest *)request;

@end

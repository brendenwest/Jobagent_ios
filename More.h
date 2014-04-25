//
//  More.h
//  jobagent
//
//  Created by mac on 4/18/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@class AppDelegate;

@interface More : UITableViewController <MFMailComposeViewControllerDelegate> {

	NSMutableArray *menuList;
	AppDelegate *del;
}

@property (nonatomic, strong) NSMutableArray *menuList;
@property (nonatomic, strong) AppDelegate *del;

@end

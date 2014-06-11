//
//  JobDetail.h
//  jobagent
//
//  Created by mac on 3/9/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <CoreData/CoreData.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "EditItemVC.h"

@class AppDelegate, WebVC, Job;

@interface JobDetail : UIViewController <EditItemDelegate, MFMailComposeViewControllerDelegate, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource> {
	
	AppDelegate *appDelegate;
	UITableView	*tableView;
	UISegmentedControl *jobActions;

	NSManagedObjectContext *managedObjectContext;
	NSMutableDictionary *aJob; // used by search results VC
	Job *_selectedLead; // used by favorites VC
	WebVC *_webVC;

}

@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) WebVC *webVC;

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UISegmentedControl *jobActions;
@property (nonatomic, strong) NSArray *jobFields;
@property (nonatomic, strong) NSString *editedItemId;


@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSMutableDictionary *aJob;
@property (nonatomic, strong) Job *selectedLead;

@end


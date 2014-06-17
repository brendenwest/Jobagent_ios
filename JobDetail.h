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
#import "WebVC.h"
#import "EditItemVC.h"
#import "PickList.h"

@class AppDelegate, WebVC, Job;

@interface JobDetail : UIViewController <EditItemDelegate, PickListDelegate, MFMailComposeViewControllerDelegate, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource> {
	
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
@property (nonatomic, strong) NSArray *jobLabels;
@property (nonatomic, strong) NSArray *jobKeys;
@property (nonatomic, strong) NSArray *jobTypes;
@property (nonatomic, strong) NSString *editedItemId;


@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSMutableDictionary *aJob;
@property (nonatomic, strong) Job *selectedLead;

// Date Picker properties
// keep track which indexPath points to the cell with UIDatePicker
@property (nonatomic, strong) NSIndexPath *datePickerIndexPath;

@property (assign) NSInteger pickerCellRowHeight;

@property (nonatomic, strong) IBOutlet UIDatePicker *pickerView;

// this button appears only when the date picker is shown (iOS 6.1.x or earlier)
@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;


@end


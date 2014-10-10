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

	NSManagedObjectContext *managedObjectContext;
    
    NSArray *jobLabels;
    NSArray *jobKeys;
    NSArray *jobTypes;
    NSString *editedItemId;

    // Date Picker properties
    // keep track which indexPath points to the cell with UIDatePicker
    NSIndexPath *datePickerIndexPath;
    NSInteger pickerCellRowHeight;

}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UISegmentedControl *jobActions;


@property (nonatomic, strong) NSMutableDictionary *aJob; // set by SearchJobs
@property (nonatomic, strong) Job *selectedLead; // set by Leads


@property (nonatomic, strong) IBOutlet UIDatePicker *pickerView;

// this button appears only when the date picker is shown (iOS 6.1.x or earlier)
@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;


@end


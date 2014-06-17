//
//  JobDetail.h
//  jobagent
//
//  Created by mac on 3/9/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "EditItemVC.h"
#import "PickList.h"

@class AppDelegate, Event;

@interface EventDetail : UIViewController <EditItemDelegate, PickListDelegate, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource> {
	
	AppDelegate *appDelegate;
	UITableView	*tableView;

	NSManagedObjectContext *managedObjectContext;
	Event *_selectedEvent;

}

@property (nonatomic, strong) AppDelegate *appDelegate;

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UISegmentedControl *jobActions;
@property (nonatomic, strong) NSArray *eventLabels;
@property (nonatomic, strong) NSArray *eventKeys;
@property (nonatomic, strong) NSArray *eventTypes;
@property (nonatomic, strong) NSArray *eventPriorities;
@property (nonatomic, strong) NSString *editedItemId;


@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) Event *selectedEvent;

@property (nonatomic, strong) UISegmentedControl *eventPriority;

// Date Picker properties
// keep track which indexPath points to the cell with UIDatePicker
@property (nonatomic, strong) NSIndexPath *datePickerIndexPath;

@property (assign) NSInteger pickerCellRowHeight;

@property (nonatomic, strong) IBOutlet UIDatePicker *pickerView;

// this button appears only when the date picker is shown (iOS 6.1.x or earlier)
@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;


@end


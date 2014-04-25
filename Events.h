//
//  Events.h
//  jobagent
//
//  Created by mac on 3/25/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

@class EventDetail, AppDelegate;

@interface Events : UITableViewController <NSFetchedResultsControllerDelegate> {
	AppDelegate *del;
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
	
	EventDetail *_eventDetailVC; // for linking to details
	BOOL _firstInsert;
	
}
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) IBOutlet EventDetail *eventDetailVC;
@property (nonatomic, strong) AppDelegate *del;

- (void)configureCell:(UITableViewCell *)cell 
			 withEvent:(NSManagedObject *)model;

- (void)customBarButtons;

@end

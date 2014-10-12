//
//  Events.h
//  jobagent
//
//  Created by mac on 3/25/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

@class EventDetail;

@interface Events : UITableViewController <NSFetchedResultsControllerDelegate> {

    BOOL _firstInsert;
    AppDelegate *appDelegate;
	
}
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (void)configureCell:(UITableViewCell *)cell 
			 withEvent:(NSManagedObject *)model;

@end

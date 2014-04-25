//
//  Tasks.h
//  jobagent
//
//  Created by mac on 2/24/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

@class TaskDetail;

@interface Tasks : UITableViewController <NSFetchedResultsControllerDelegate, NSXMLParserDelegate> {
	AppDelegate *del;
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
	
	TaskDetail *_taskDetailVC; // for linking to details
	NSXMLParser *rssParser;
	NSMutableString *currentElementValue;
	NSMutableArray *tmpTasks;
	NSMutableDictionary *tmpTask;
	NSArray *priorityValues;
	BOOL _firstInsert;
	
}

@property (nonatomic, strong) AppDelegate *del;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) IBOutlet TaskDetail *taskDetailVC;

@property (nonatomic, strong) NSArray *priorityValues;
@property (nonatomic, strong) NSMutableArray *tmpTasks;
@property (nonatomic, strong) NSMutableDictionary *tmpTask;
@property (nonatomic, strong) NSXMLParser *rssParser;
@property (nonatomic, strong) NSMutableString *currentElementValue;

- (void)configureCell:(UITableViewCell *)cell 
			 withTask:(NSManagedObject *)model;

- (void)customBarButtons;

@end

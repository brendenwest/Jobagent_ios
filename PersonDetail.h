//
//  PersonDetail.h
//  jobagent
//
//  Created by mac on 4/1/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "EditItemVC.h"
#import "PickList.h"

@class AppDelegate, Person;

@interface PersonDetail : UIViewController <UITableViewDelegate, UITableViewDataSource,  UITextFieldDelegate,  MFMailComposeViewControllerDelegate, EditItemDelegate, PickListDelegate > {

	AppDelegate *appDelegate;
	UITableView *tableView;
    
    NSManagedObjectContext *managedObjectContext;
	Person *_selectedPerson;

    UISegmentedControl *btnContactActions;

    
}

@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) NSArray *contactTypes;
@property (nonatomic, strong) NSArray *contactLabels;
@property (nonatomic, strong) NSArray *contactKeys;
@property (nonatomic, strong) NSString *editedItemId;

@property (nonatomic, strong) Person *selectedPerson;

@property (nonatomic, strong) IBOutlet UISegmentedControl *btnContactActions;

@end

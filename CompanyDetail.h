//
//  CompanyDetail.h
//  jobagent
//
//  Created by mac on 3/29/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <QuartzCore/QuartzCore.h>
#import "EditItemVC.h"
#import "PickList.h"

@class AppDelegate, Company, LeadDetail, PersonDetail, SearchJobs, Leads, People;

@interface CompanyDetail : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate, EditItemDelegate, PickListDelegate> {
	
	AppDelegate *appDelegate;
    
	NSManagedObjectContext *managedObjectContext;
	Company *_selectedCompany;
    
	SearchJobs *_searchVC;
	Leads *_leadsVC;
	People *_contactsVC;
	
	IBOutlet UISegmentedControl *btnInternalLinks;
	
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UITextView *notes;

@property (nonatomic, strong) Company *selectedCompany;

@property (nonatomic, strong) NSArray *coTypes;
@property (nonatomic, strong) NSArray *coLabels;
@property (nonatomic, strong) NSArray *coKeys;
@property (nonatomic, strong) NSString *editedItemId;

@property (nonatomic, strong) IBOutlet UISegmentedControl *btnExternalLinks;


@end


//
//  CompanyDetail.h
//  jobagent
//
//  Created by mac on 3/29/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <QuartzCore/QuartzCore.h>

@class Company, LeadDetail, PersonDetail, SearchJobs;

@interface CompanyDetail : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource> {
	
	UITextField	*coName;
	UITextField	*coType;
	UITextView	*notes;
	UITableView *tblJobsPeople;
	NSMutableArray *people;
	NSMutableArray *jobs;
	NSMutableDictionary *userSettings;
	
	NSManagedObjectContext *managedObjectContext;
	Company *_selectedCompany;
	PersonDetail *_personVC;
	LeadDetail *_leadVC;
	SearchJobs *_searchVC;
	
	UIPickerView		*myPickerView;
	NSArray *pickerViewArray;
	IBOutlet UIButton *btnMap;
	IBOutlet UIButton *btnType;
	IBOutlet UISegmentedControl *btnJobsPeople;
	
}

@property (nonatomic, strong) IBOutlet UITextField *coName;
@property (nonatomic, strong) IBOutlet UITextField *coType;
@property (nonatomic, strong) IBOutlet UITextView *notes;
@property (nonatomic, strong) IBOutlet UITableView *tblJobsPeople;
@property (nonatomic, strong) NSMutableArray *people;
@property (nonatomic, strong) NSMutableArray *jobs;
@property (nonatomic, strong) NSArray *pickerViewArray;

@property (nonatomic, strong) NSMutableDictionary *userSettings;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) Company *selectedCompany;

@property (nonatomic, strong) LeadDetail *leadVC; // for linking to job details
@property (nonatomic, strong) PersonDetail *personVC; // for linking to person details
@property (nonatomic, strong) SearchJobs *searchVC; // for linking to job search

@property (nonatomic, strong) IBOutlet UIButton *btnMap;
@property (nonatomic, strong) IBOutlet UIButton *btnType;
@property (nonatomic, strong) IBOutlet UISegmentedControl *btnJobsPeople;
@property (nonatomic, strong) UIPickerView *myPickerView;


- (void) doneAction:(id)sender; 
- (IBAction) searchMap:(id)sender;
- (IBAction) showPicker:(id)sender;		// for showing company type selector
- (IBAction) switchView:(id)sender;     // for segmented control actions


@end


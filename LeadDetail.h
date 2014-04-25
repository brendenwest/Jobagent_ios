//
//  LeadDetail.h
//  jobagent
//
//  Created by mac on 3/21/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <QuartzCore/QuartzCore.h>

@class Job, CompanyDetail, PersonDetail, WebVC, AppDelegate;

@interface LeadDetail : UIViewController <UIScrollViewDelegate,UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource> {

    IBOutlet UIScrollView *scrollView;

	AppDelegate *del;
	UITextField	*jobTitle;
	UITextField	*company;
	UITextField	*city;
	UITextField	*person;
	UITextField	*link;
	UITextField	*pay;
	UITextField	*jobType;
    
    UIView *activeField;
    
	UIButton *btnDate;
	UITextView *description;
	Job *_selectedLead;
	
	UIButton *btnJobTypes;
	UIButton *btnCompany;
	UIButton *btnPerson;
	UIButton *btnLink;
	UIButton *btnCurrent;
	UIButton *btnCompanies;
	UIButton *btnPeople;
	
	NSManagedObjectContext *managedObjectContext;

	CompanyDetail *_companyVC;
	PersonDetail *_personVC;
	WebVC *_webVC;
	
	UIDatePicker *datePickerView;
	UIPickerView		*myPickerView;
	NSMutableArray		*pickerViewArray;
	NSMutableArray *aCompanies;
	NSMutableArray *aJobs;
	NSMutableArray *aPeople;
	
	NSDateFormatter *dateFormatter; 

}
@property (nonatomic, strong) NSDateFormatter *dateFormatter; 	
@property (nonatomic, strong) AppDelegate *del;
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) IBOutlet UITextField *jobTitle;
@property (nonatomic, strong) IBOutlet UITextField *company;
@property (nonatomic, strong) IBOutlet UITextField *city;
@property (nonatomic, strong) IBOutlet UITextField *person;
@property (nonatomic, strong) IBOutlet UITextField *link;
@property (nonatomic, strong) IBOutlet UITextField *pay;
@property (nonatomic, strong) IBOutlet UITextField *jobType;
@property (nonatomic, strong) IBOutlet UIButton *btnDate;
@property (nonatomic, strong) IBOutlet UITextView *description;
@property (nonatomic, strong) IBOutlet UIView *activeField;
@property double scrollUp;
@property double scrollDown;

@property (nonatomic, strong) IBOutlet UIButton *btnCompany;
@property (nonatomic, strong) IBOutlet UIButton *btnPerson;
@property (nonatomic, strong) IBOutlet UIButton *btnLink;
@property (nonatomic, strong) IBOutlet UIButton *btnJobTypes;
@property (nonatomic, strong) IBOutlet UIButton *btnCompanies;
@property (nonatomic, strong) IBOutlet UIButton *btnPeople;
@property (nonatomic, strong) UIButton *btnCurrent;

@property (nonatomic, strong) NSMutableArray *aCompanies;
@property (nonatomic, strong) NSMutableArray *aJobs;
@property (nonatomic, strong) NSMutableArray *aPeople;

@property (nonatomic, strong) Job *selectedLead;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) CompanyDetail *companyVC; // for linking to job details
@property (nonatomic, strong) PersonDetail *personVC; // for linking to person details
@property (nonatomic, strong) WebVC *webVC; // for linking to external sites

@property (nonatomic, strong) UIDatePicker *datePickerView;
@property (nonatomic, strong) UIPickerView *myPickerView;
@property (nonatomic, strong) NSMutableArray *pickerViewArray;

- (IBAction)doneKey:(id)sender;
- (IBAction)switchView:(id)sender;
- (IBAction)showPicker:(id)sender;		// for showing job type selector

@end

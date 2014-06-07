//
//  PersonDetail.h
//  jobagent
//
//  Created by mac on 4/1/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@class AppDelegate, Person, CompanyDetail;

@interface PersonDetail : UIViewController <UIScrollViewDelegate, UITextFieldDelegate, UITextViewDelegate, MFMailComposeViewControllerDelegate > {

	AppDelegate *appDelegate;
    IBOutlet UIScrollView *scrollView;

	UITextField	*name;
	UITextField	*phone;
	UITextField	*email;
	UITextField	*company;
	UITextField	*pTitle;
    UIView *activeField;
	UITextView	*description;
	UIButton *btnTitles;
	UIButton *btnCompany;
	UIButton *btnPhone;
	UIButton *btnMail;
	
	Person *_selectedPerson;
	CompanyDetail *_companyVC;
}

@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) IBOutlet UITextField *name;
@property (nonatomic, strong) IBOutlet UITextField *company;
@property (nonatomic, strong) IBOutlet UITextField *phone;
@property (nonatomic, strong) IBOutlet UITextField *email;
@property (nonatomic, strong) IBOutlet UITextField *pTitle;
@property (nonatomic, strong) IBOutlet UIView *activeField;
@property double scrollUp;
@property double scrollDown;

@property (nonatomic, strong) IBOutlet UITextView *description;
@property (nonatomic, strong) IBOutlet UIButton *btnCompany;
@property (nonatomic, strong) IBOutlet UIButton *btnPhone;
@property (nonatomic, strong) IBOutlet UIButton *btnMail;

@property (nonatomic, strong) Person *selectedPerson;
@property (nonatomic, strong) CompanyDetail *companyVC; // for linking to company details

- (IBAction)btnPushed:(id)sender;

@end

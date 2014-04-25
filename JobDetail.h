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

@class AppDelegate, WebVC;

@interface JobDetail : UIViewController <UITextViewDelegate, MFMailComposeViewControllerDelegate, NSFetchedResultsControllerDelegate> {
	
	AppDelegate *del;
	UILabel	*jobTitle;
	UILabel	*company;
	UILabel	*location;
	UILabel *pubDate;
	UILabel *jobType;
	UILabel *pay;
	UITextView *description;
	UISegmentedControl *jobActions;

	NSManagedObjectContext *managedObjectContext;
	NSDictionary *_aJob;
	WebVC *_webVC;

}

@property (nonatomic, strong) AppDelegate *del;
@property (nonatomic, strong) WebVC *webVC;

@property (nonatomic, strong) IBOutlet UILabel *jobTitle;
@property (nonatomic, strong) IBOutlet UILabel *company;
@property (nonatomic, strong) IBOutlet UILabel *location;
@property (nonatomic, strong) IBOutlet UILabel *pubDate;
@property (nonatomic, strong) IBOutlet UILabel *jobType;
@property (nonatomic, strong) IBOutlet UILabel *pay;
@property (nonatomic, strong) IBOutlet UITextView *description;
@property (nonatomic, strong) IBOutlet UISegmentedControl *jobActions;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSDictionary *aJob;

@end


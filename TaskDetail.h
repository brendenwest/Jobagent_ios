//
//  TaskDetail.h
//  jobagent
//
//  Created by mac on 3/23/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@class AppDelegate, Task;

@interface TaskDetail : UIViewController <UIScrollViewDelegate, UITextFieldDelegate, UITextViewDelegate > {
	
	AppDelegate *del;
    IBOutlet UIScrollView *scrollView;
	IBOutlet UITextField	*taskTitle;
	IBOutlet UISegmentedControl *btnPriority;

	NSDateFormatter *dateFormatter;
	UIButton *btnEndDate;
	UIButton *btnCurrent;
	UIDatePicker *pickerView;

	UITextView *description;
	Task *_selectedTask;
    UIView *activeField;

}

@property (nonatomic, strong) IBOutlet UITextField *taskTitle;
@property (nonatomic, strong) IBOutlet UIButton *btnEndDate;
@property (nonatomic, strong) IBOutlet UIButton *btnCurrent;
@property (nonatomic, strong) IBOutlet UISegmentedControl *btnPriority;
@property (nonatomic, strong) IBOutlet UIDatePicker *pickerView;
@property (nonatomic, strong) IBOutlet UITextView *description;

@property (nonatomic, strong) NSDateFormatter *dateFormatter; 
@property (nonatomic, strong) AppDelegate *del;
@property (nonatomic, strong) UIScrollView *scrollView;
@property double scrollUp;
@property double scrollDown;

@property (nonatomic, strong) Task *selectedTask;


- (IBAction)setPriority:(id)sender;
- (IBAction)showPicker:(id)sender;
- (IBAction)doneAction:(id)sender;

@end

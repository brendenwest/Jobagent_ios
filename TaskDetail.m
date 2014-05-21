//
//  TaskDetail.m
//  jobagent
//
//  Created by mac on 3/23/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import "TaskDetail.h"
#import "Task.h"
#import "AppDelegate.h"
#import "Common.h"

@implementation TaskDetail

@synthesize scrollView, dateFormatter, taskTitle, btnEndDate, btnCurrent, description, btnPriority, pickerView, del;
@synthesize selectedTask = _selectedTask;


- (IBAction)doneAction:(id)sender 
{
		
	// remove the "Done" button in the nav bar
	self.navigationItem.rightBarButtonItem = nil;
	
	[btnCurrent setTitle:[self.dateFormatter stringFromDate:self.pickerView.date] forState:(UIControlState)UIControlStateNormal];
	pickerView.hidden = YES;

}

- (IBAction)setPriority:(id)sender {
	
	self.selectedTask.priority = [NSNumber numberWithInt:(int)[sender selectedSegmentIndex]];

}

- (IBAction)showPicker:(id)sender {
	
	// add the "Done" button to the nav bar
	UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone  target:self action:@selector(doneAction:)];
	
	self.navigationItem.rightBarButtonItem = doneButton;

	btnCurrent = (UIButton *)sender;

	if (![btnCurrent.currentTitle isEqual: @"mm/dd/yy"]) {
		self.pickerView.date = [self.dateFormatter dateFromString:btnCurrent.currentTitle];
	}

	pickerView.hidden = NO;
}

#pragma Helper methods

- (void) backgroundTouched {
    
	for (UIView* view in self.view.subviews) {
		if ([view isKindOfClass:[UITextField class]] || [view isKindOfClass:[UITextView class]])
			[view resignFirstResponder];
	}
}

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}


// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    // get kb height
    // get textfield bottom Y coord
    // if textfield bottom Y coord < KB height (coordinates start from lower left of screen), then move scrollview
    
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    _scrollDown = scrollView.contentOffset.y;
    
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Homebrewed
    _scrollUp = (activeField.frame.origin.y + activeField.frame.size.height) - (self.view.frame.size.height-kbSize.height+scrollView.contentOffset.y);
    if (_scrollUp > 0) {
        
        CGPoint scrollPoint = CGPointMake(0.0, _scrollUp);
        [scrollView setContentOffset:scrollPoint animated:YES];
    }
    
}


// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    if (_scrollUp > 0) {
        
        CGPoint scrollPoint = CGPointMake(0.0, _scrollDown);
        [scrollView setContentOffset:scrollPoint animated:YES];
        _scrollUp = 0;
    }
}

// end Helper methods
//*******

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"Task";

	description.delegate = self;
	del = (AppDelegate *)[UIApplication sharedApplication].delegate;

    // allow user to dismiss keyboard by tapping background screen
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTouched)];
    
    // make sure gesture recognizer doesn't cancel button touches
    singleTap.cancelsTouchesInView = NO;
    
    [scrollView addGestureRecognizer: singleTap];
    scrollView.contentSize = self.view.frame.size;
    scrollView.delegate = self;
    
    [self registerForKeyboardNotifications];

    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterShortStyle];

    description.layer.cornerRadius = 8;
	description.layer.borderWidth = 1;
	description.layer.borderColor = [[UIColor grayColor] CGColor];	
    
	// create a custom navigation bar button and set it to always say "Back"
	UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
	temporaryBarButtonItem.title = @"Back";
	self.navigationItem.backBarButtonItem = temporaryBarButtonItem;

}


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];


	taskTitle.text = _selectedTask.title;	
	description.text =  (_selectedTask.notes != nil) ? _selectedTask.notes : @"";
    
    // set value for date button 
	NSString *tmpTitle = [Common getShortDate:[NSString stringWithFormat:@"%@",_selectedTask.end]];
	[btnEndDate setTitle:tmpTitle forState:UIControlStateNormal];
    btnPriority.selectedSegmentIndex = [_selectedTask.priority integerValue];
	
    [del trackPV:self.title];

}

#pragma mark textField methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // the user pressed the "Done" button, so dismiss the keyboard
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
	
}



#pragma mark textView methods


-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text { if([text isEqualToString:@"\n"]) [textView resignFirstResponder]; return YES; }

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    activeField = textView;
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
	return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
	self.selectedTask.notes = description.text;
	[textView resignFirstResponder];
}

- (void)textViewShouldReturn:(UITextView *)textView {
	[textView resignFirstResponder];
}


- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
    if (taskTitle.text.length > 0) {
        self.selectedTask.title = taskTitle.text;
        self.selectedTask.notes = description.text;
        self.selectedTask.priority = [NSNumber numberWithInteger:[btnPriority selectedSegmentIndex]];

        self.selectedTask.end = [Common dateFromString:btnEndDate.currentTitle];
        pickerView.hidden = YES;

        NSError *error = nil;
        if (![self.selectedTask.managedObjectContext save:&error]) {
            // Handle the error...
            NSLog(@"Error saving %@, %@", error, [error userInfo]);
        }
    } else {
        // delete empty task record
        [self.selectedTask.managedObjectContext deleteObject:self.selectedTask];
    }
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
    self.dateFormatter = nil;
}


@end

//
//  EditView.m
//  jobagent
//
//  Created by Brenden West on 6/9/14.
//
//

#import "EditItemVC.h"
#import "Common.h"
#import "AppDelegate.h"

@implementation EditItemVC

@synthesize appDelegate, labelText, itemLabel, itemTextView, itemText;


- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Edit";
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
	
    if (IS_OS_7_OR_LATER) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

    [Common formatTextView:itemTextView:nil];

	// create a custom navigation bar button and set it to always say "Back"
	UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
	temporaryBarButtonItem.title = @"Back";
	self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    itemLabel.text = labelText;
    itemTextView.text = itemText;
    
    [appDelegate trackPV:self.title];
    
}

#pragma mark textView methods

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text { if([text isEqualToString:@"\n"]) [textView resignFirstResponder]; return YES; }

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    // save edits back to calling VC
    
    itemText = itemTextView.text;
    [[self delegate]setItemText:itemText];
        
}

@end

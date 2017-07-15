//
//  EditView.m
//  jobagent
//
//  Created by Brenden West on 6/9/14.
//
//

#import "EditItemVC.h"
#import "Common.h"

@implementation EditItemVC

@synthesize labelText, itemLabel, itemTextView, itemText;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
	
    [Common formatTextView:itemTextView:nil];

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

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [itemTextView resignFirstResponder];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    // save edits back to calling VC
    [super viewWillDisappear:(BOOL)animated];
    [[self delegate] textEditHandler:itemTextView.text];
        
}

@end

//
//  About.m
//  jobagent
//
//  Created by Brenden West on 1/13/12.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import "About.h"
#import "AppDelegate.h"

@implementation About

@synthesize scrollView, btnFeedback, btnShare, webAbout;

- (IBAction)sendMail:(id)sender {
    // add check for can't send mail
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
        mailController.mailComposeDelegate = self;
        NSString *subject = [NSString stringWithFormat:@"Job Agent Feedback"];
        NSString *body = [NSString stringWithFormat:@"\n\nSent from the Job Agent mobile app.\n\n http://itunes.apple.com/us/app/job-agent/id517622797?ls=1&mt=8"];
        
        if (sender == btnFeedback) {

            NSArray *recipients = [[NSArray alloc] initWithObjects:@"info@brisksoft.us", nil]; 
            [mailController setToRecipients:recipients];
        } else {
            subject = @"Great job search app";

        }
        
        [mailController setSubject:subject];
        [mailController setMessageBody:body isHTML:YES];
        [self presentViewController:mailController animated:YES completion:NULL];

    } else {
            
        NSLog(@"Device is unable to send email in its current state.");
    }    
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error 
{
	if (error) {
		UIAlertView *cantMailAlert = [[UIAlertView alloc] initWithTitle:@"Mail error" message:[error localizedDescription] delegate:NULL cancelButtonTitle:@"OK" otherButtonTitles:NULL];
		[cantMailAlert show];
	}
    [controller dismissViewControllerAnimated:YES completion:nil];

}


// Share Job Agent
- (NSArray *)activityViewController:(NSArray *)activityViewController itemsForActivityType:(NSString *)activityType {
    if (![activityType isEqualToString:UIActivityTypePostToTwitter]) {
        // link to Job Agent in app store
        NSString *tinyUrl2 = [NSString stringWithFormat:@"http://tinyurl.com/api-create.php?url=%@",NSLocalizedString(@"URL_JOBAGENT_IOS", nil)];
        
        NSString *shortURLforJobAgent = [NSString stringWithContentsOfURL:[NSURL URLWithString:tinyUrl2]
                                                                 encoding:NSASCIIStringEncoding
                                                                    error:nil];
        
        return @[
                 [NSString stringWithFormat:@"Job Agent app works for me - %@", shortURLforJobAgent ]
                 ];
    } else {
        return @[@"Default message"];
    }
}

- (void)shareJobAgent {
    NSLog(@"sharing in general");
    
    //    App ID:	257730111036545
    //    App Secret:	4a271f589e72195b7578a49809876b9a(reset)
    
    NSString *tinyUrl1 = [NSString stringWithFormat:@"http://tinyurl.com/api-create.php?url=%@",NSLocalizedString(@"URL_JOBAGENT_IOS", nil)];
    NSString *shortURLforJobAgent = [NSString stringWithContentsOfURL:[NSURL URLWithString:tinyUrl1]
                                                        encoding:NSASCIIStringEncoding
                                                           error:nil];
    
    NSString *postText = [NSString stringWithFormat:@"Job Agent app works for me - %@ ", shortURLforJobAgent];
    NSURL *recipients = [NSURL URLWithString:@""];
    
    NSArray *activityItems;
    activityItems = @[postText, recipients];
    
    UIActivityViewController *activityController =
    [[UIActivityViewController alloc]
     initWithActivityItems:activityItems applicationActivities:nil];
    
    
    [activityController setValue:[NSString stringWithFormat:@"Job Agent app"] forKey:@"subject"];
    
    /* use shortURL */
    
    // Removed un-needed activities
    activityController.excludedActivityTypes = [[NSArray alloc] initWithObjects:
                                                UIActivityTypeCopyToPasteboard,
                                                UIActivityTypePostToWeibo,
                                                UIActivityTypeSaveToCameraRoll,
                                                UIActivityTypeCopyToPasteboard,
                                                UIActivityTypeMessage,
                                                UIActivityTypeAssignToContact,
                                                nil];
    
    [self presentViewController:activityController
                       animated:YES completion:nil];
    
    
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"About Job Agent";

    scrollView.contentSize = self.view.frame.size;
    scrollView.delegate = self;
    
    NSString *fullURL = @"http://brisksoft.us/jobagent/about.html";
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    [webAbout loadRequest:requestObj];
    
	// create a custom navigation bar button and set it to always say "Back"
	UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
	temporaryBarButtonItem.title = @"Back";
	self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] trackPV:self.title];

}

- (void)dealloc {
    
}


@end

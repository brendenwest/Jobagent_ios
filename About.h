//
//  About.h
//  jobagent
//
//  Created by Brenden West on 1/13/12.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


@interface About : UIViewController <UIScrollViewDelegate, MFMailComposeViewControllerDelegate> {

    IBOutlet UIScrollView *scrollView;
	UIButton *btnMail;
    IBOutlet UIWebView *webAbout;

}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIButton *btnFeedback;
@property (nonatomic, strong) IBOutlet UIButton *btnShare;
@property (nonatomic, strong) UIWebView *webAbout;

- (IBAction)sendMail:(id)sender;
- (IBAction)shareJobAgent;

@end

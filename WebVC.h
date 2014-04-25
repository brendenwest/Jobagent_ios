//
//  webview.h
//  jobagent
//
//  Created by mac on 4/6/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WebVC : UIViewController <UITextFieldDelegate, UIWebViewDelegate>
{
	UIWebView *myWebView;
	NSString *requestedURL;
	
}

@property (nonatomic, strong) UIWebView	*myWebView;
@property (nonatomic, strong) NSString	*requestedURL;

@end

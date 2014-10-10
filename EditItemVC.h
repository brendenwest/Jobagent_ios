//
//  EditView.h
//  jobagent
//
//  Created by Brenden West on 6/9/14.
//
//

@class AppDelegate;

@protocol EditItemDelegate <NSObject>

- (void)setItemText:(NSString*)itemText;

@end

@interface EditItemVC : UIViewController < UITextViewDelegate> {

    AppDelegate *appDelegate;

}

@property (retain) id <EditItemDelegate> delegate;

@property (nonatomic, strong) IBOutlet UILabel *itemLabel;
@property (nonatomic, strong) IBOutlet UITextView *itemTextView;

@property (nonatomic, strong) NSString *labelText;
@property (nonatomic, strong) NSString *itemText;

@end

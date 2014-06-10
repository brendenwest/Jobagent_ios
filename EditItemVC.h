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

@property (nonatomic, strong) AppDelegate *appDelegate;
@property(retain) id <EditItemDelegate> delegate;

@property (nonatomic, weak) IBOutlet UILabel *itemLabel;
@property (nonatomic, weak) IBOutlet UITextView *itemTextView;

@property (nonatomic, strong) NSString *labelText;
@property (nonatomic, strong) NSString *itemText;

@end

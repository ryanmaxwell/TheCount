//
//  EditCounterViewController.h
//  TheCount
//
//  Created by Ryan Maxwell on 15/05/11.
//  Copyright 2011 Cactuslab. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Counter;
@class CountRecordTableViewCell;
@protocol EditCounterDelegate;

@interface EditCounterViewController : UIViewController <UIActionSheetDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) UIViewController<EditCounterDelegate> *delegate;
@property (nonatomic, strong) Counter *counter;
@property (nonatomic, strong) NSArray *sortedRecords;

@property (nonatomic, weak) IBOutlet UITextField *counterNameTextField;
@property (nonatomic, weak) IBOutlet UITextField *customIncrementTextField;
@property (nonatomic, weak) IBOutlet UISegmentedControl *incrementSegmentedControl;
@property (nonatomic, weak) IBOutlet UITableView *historyTableView;

- (IBAction)deleteButtonWasPressed;
- (IBAction)incrementValueChanged:(id)sender;
- (IBAction)touchedBackground;

// validation - used by add view also
+ (BOOL)isCustomIncrementValid:(NSInteger)value;
+ (void)displayInvalidCustomIncrementAlert;

@end

@protocol EditCounterDelegate <NSObject>
@required
- (void)editCounterViewController:(EditCounterViewController *)ecvc 
                 didDeleteCounter:(Counter *)counter;
@end

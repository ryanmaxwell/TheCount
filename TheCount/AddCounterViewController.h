//
//  AddCounterViewController.h
//  TheCount
//
//  Created by Ryan Maxwell on 15/05/11.
//  Copyright 2011 Cactuslab. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Counter;
@protocol AddCounterDelegate;

@interface AddCounterViewController : UIViewController
@property (nonatomic, weak) UIViewController<AddCounterDelegate> *delegate;

@property (nonatomic, weak) IBOutlet UITextField *counterNameTextField;
@property (nonatomic, weak) IBOutlet UITextField *customIncrementTextField;
@property (nonatomic, weak) IBOutlet UISegmentedControl *incrementSegmentedControl;

- (IBAction)cancelButtonWasPressed;
- (IBAction)saveButtonWasPressed;

@end

@protocol AddCounterDelegate <NSObject>
@required
// counter = nil on cancel button pressed
- (void)addCounterViewController:(AddCounterViewController *)acvc 
				   didAddCounter:(Counter *)counter;
@end

//
//  CounterPageViewController.h
//  TheCount
//
//  Created by Ryan Maxwell on 9/05/11.
//  Copyright 2011 Cactuslab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlipsideViewController.h"
#import "FlipDigitPanelView.h"
@class Counter;
@class MainViewController;

@interface CounterPageViewController : UIViewController <UITextFieldDelegate, FlipDigitPanelViewDelegate> 

@property (nonatomic, strong) Counter *counter;

@property (nonatomic, strong) IBOutlet FlipDigitPanelView *flipDigitPanel;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *incrementLabel;

- (id)initWithCounter:(Counter *)counter;
- (IBAction)incrementCounter;
- (IBAction)decrementCounter;
- (IBAction)reset;
- (void)createNewCountRecordWithValue:(NSNumber *)numberValue;

@end

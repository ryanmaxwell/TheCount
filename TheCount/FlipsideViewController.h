//
//  FlipsideViewController.h
//  TheCount
//
//  Created by Ryan Maxwell on 8/05/11.
//  Copyright 2011 Cactuslab. All rights reserved.
//

#import "EditCounterViewController.h"
#import "AddCounterViewController.h"
@protocol FlipsideViewControllerDelegate;

@interface FlipsideViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, AddCounterDelegate, EditCounterDelegate> 
@property (nonatomic, weak) id <FlipsideViewControllerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *counters;
@property (nonatomic, weak) IBOutlet UITableView *countersTableView;
@property (nonatomic, weak) IBOutlet UISwitch *leftHandModeSwitch;

- (IBAction)done;
- (IBAction)toggleLeftHandMode:(id)sender;

@end

@protocol FlipsideViewControllerDelegate <NSObject>
@required
- (void)flipsideViewControllerDidFinish;
- (void)addedCounter;
- (void)deletedCounterAtIndex:(NSUInteger)index;
- (void)movedCounterFromIndex:(NSUInteger)oldIndex toIndex:(NSUInteger)newIndex;
@end

//
//  CounterPageViewController.m
//  TheCount
//
//  Created by Ryan Maxwell on 9/05/11.
//  Copyright 2011 Cactuslab. All rights reserved.
//

#import "CounterPageViewController.h"
#import "FlipDigitPanelView.h"
#import "DataAccessor.h"
#import "Counter.h"

@interface CounterPageViewController () {
    BOOL _isUpdatingUI;
}
@end

@implementation CounterPageViewController
@synthesize flipDigitPanel = _flipDigitPanel, counter = _counter;
@synthesize nameLabel = _nameLabel, incrementLabel = _incrementLabel;

#pragma mark - Initialization

- (id)initWithCounter:(Counter *)counter {
    self = [super initWithNibName:@"CounterPageView" bundle:[NSBundle mainBundle]];
    
    if (self) {
        self.counter = counter;
        _isUpdatingUI = NO;
    }
    return self;
}

#pragma mark - IBActions

- (void)displayCounterValue {
    _isUpdatingUI = YES;
    
    NSInteger totalCounterValue = self.counter.totalIntegerValue;
    [self.flipDigitPanel displayIntegerValue:totalCounterValue];
    NSLog(@"%d", totalCounterValue);
}

- (void)incrementCounter {
    if (!_isUpdatingUI) {
        _isUpdatingUI = YES;
        
        [self createNewCountRecordWithValue:self.counter.incrementValue];
        [self displayCounterValue];
    }
}

- (void)decrementCounter {
    if (!_isUpdatingUI) {
        _isUpdatingUI = YES;
        
        [self createNewCountRecordWithValue:self.counter.decrementValue];
        [self displayCounterValue];
    }
}

- (void)createNewCountRecordWithValue:(NSNumber *)numberValue {
    CountRecord *countRecord = (CountRecord *)[NSEntityDescription insertNewObjectForEntityForName:@"CountRecord" 
                                                                            inManagedObjectContext:[DataAccessor sharedDataAccessor].managedObjectContext];
    countRecord.value = numberValue;
    countRecord.creationDate = [NSDate date];
    countRecord.cumulativeTotal = [NSNumber numberWithInteger:(self.counter.totalIntegerValue + [self.counter.incrementValue integerValue])];
    self.counter.records = [self.counter.records setByAddingObject:countRecord];
    
    [[DataAccessor sharedDataAccessor] saveContext];
}

- (void)reset {
    if (!_isUpdatingUI) {
        _isUpdatingUI = YES;
        
        for (CountRecord *cr in self.counter.records) {
            [[DataAccessor sharedDataAccessor].managedObjectContext deleteObject:cr];
        }
        [[DataAccessor sharedDataAccessor] saveContext];

        [self displayCounterValue];
    }
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    NSLog(@"%@ Did Load", counter.name);
    
    [self displayCounterValue];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    NSLog(@"%@ Will Appear", counter.name);
    
    self.nameLabel.text = self.counter.name;
    self.incrementLabel.text = [NSString stringWithFormat:@"Changes by %d", [self.counter.incrementValue intValue]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    NSLog(@"%@ Did Appear", counter.name);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload {
    self.flipDigitPanel = nil;
    self.nameLabel = nil;
    self.incrementLabel = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - FlipDigitPanelViewDelegate

- (void)flipDigitPanelViewFinishedUpdating {
    _isUpdatingUI = NO;
}

@end

//
//  EditCounterViewController.m
//  TheCount
//
//  Created by Ryan Maxwell on 15/05/11.
//  Copyright 2011 Cactuslab. All rights reserved.
//

#import "EditCounterViewController.h"
#import "CountRecordTableViewCell.h"
#import "Counter.h"
#import "CountRecord.h"
#import "DataAccessor.h"

#define kCustomIncrementTextFieldFrameOffsetY   45
#define kHistoryTableViewFrameOffsetY           39

typedef enum {
    Increment1Index = 0,
    Increment10Index,
    Increment100Index,
    IncrementCustomIndex
} IncrementSegmentedControlIndex;

#define kMininumCustomIncrementValue            1
#define kMininumCustomIncrementValueString      @"one"
#define kMaximumCustomIncrementValue            1000000
#define kMaximumCustomIncrementValueString      @"one million"

static NSDateFormatter *_cellDateFormatter;
static NSDateFormatter *_sectionHeaderDateFormatter;
static NSString *_countRecordCellIdentifier = @"CountRecordCell";

@interface EditCounterViewController () {
    BOOL _counterDeleted;
}
- (void)showCustomIncrementTextField:(BOOL)showTextField;
- (void)saveCounter;
@end

@implementation EditCounterViewController
@synthesize counter = _counter, sortedRecords = _sortedRecords, delegate = _delegate;
@synthesize counterNameTextField = _counterNameTextField, customIncrementTextField = _customIncrementTextField;
@synthesize incrementSegmentedControl = _incrementSegmentedControl, historyTableView = _historyTableView;

#pragma mark - Initialization

// called when loaded from storyboard
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _cellDateFormatter = [[NSDateFormatter alloc] init];
        [_cellDateFormatter setDateStyle:NSDateFormatterNoStyle];
        [_cellDateFormatter setTimeStyle:NSDateFormatterShortStyle];
        
        _sectionHeaderDateFormatter = [[NSDateFormatter alloc] init];
        [_sectionHeaderDateFormatter setDoesRelativeDateFormatting:YES];
        [_sectionHeaderDateFormatter setDateStyle:NSDateFormatterShortStyle];
        [_sectionHeaderDateFormatter setTimeStyle:NSDateFormatterNoStyle];
    }
    return self;
}


- (void)saveCounter {
    self.counter.name = self.counterNameTextField.text;
    BOOL counterValid = YES;
    
    NSInteger incrementValue;
    NSInteger selectedIndex = self.incrementSegmentedControl.selectedSegmentIndex;
    
    switch (selectedIndex) {
        case Increment1Index: {
            incrementValue = 1;
            break;
        }
        case Increment10Index: {
            incrementValue = 10;
            break;
        }
        case Increment100Index: {
            incrementValue = 100;
            break;
        }
        case IncrementCustomIndex: {
            incrementValue = [self.customIncrementTextField.text integerValue];
            
            if (![EditCounterViewController isCustomIncrementValid:incrementValue]) {
                counterValid = NO;
                [EditCounterViewController displayInvalidCustomIncrementAlert];
            } else {
                self.customIncrementTextField.text = [NSString stringWithFormat:@"%d", incrementValue];
            }
            break;
        }
        default: {
            incrementValue = 1;
            break;
        }
    }
    
    if (counterValid){
//        NSLog(@"%@ Increment saved as %d", self.counter.name, incrementValue);
        self.counter.incrementValue = [NSNumber numberWithInteger:incrementValue];
        [[DataAccessor sharedDataAccessor] saveContext];
    }
}

+ (BOOL)isCustomIncrementValid:(NSInteger)value {
    if (value >= kMininumCustomIncrementValue && value <= kMaximumCustomIncrementValue) {
        return YES;
    } else return NO;
}

+ (void)displayInvalidCustomIncrementAlert {
    NSString *message = [NSString stringWithFormat:@"Please choose a number between %@ and %@", kMininumCustomIncrementValueString, kMaximumCustomIncrementValueString];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Increment" 
                                                    message:message
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK" 
                                          otherButtonTitles:nil];
    [alert show];
}


#pragma mark - IBActions

- (IBAction)doneButtonWasPressed {
    // essentially the same thing as pressing the "Back" button - just in the top right for ease of use
    
    if (self.incrementSegmentedControl.selectedSegmentIndex == IncrementCustomIndex && 
        ![EditCounterViewController isCustomIncrementValid:[self.customIncrementTextField.text integerValue]]) {
        // invalid counter increment
        [EditCounterViewController displayInvalidCustomIncrementAlert];
        
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)deleteButtonWasPressed {
    UIActionSheet *confirmActionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to delete this counter?" 
                                                                    delegate:self 
                                                           cancelButtonTitle:@"Cancel" 
                                                      destructiveButtonTitle:@"Delete" 
                                                           otherButtonTitles:nil];
    [confirmActionSheet showInView:self.view];
}


- (IBAction)incrementValueChanged:(id)sender {
    NSInteger selectedSegmentIndex = ((UISegmentedControl *)sender).selectedSegmentIndex;
    
    if (selectedSegmentIndex == IncrementCustomIndex) {
        [self showCustomIncrementTextField:YES];
    } else {
        [self showCustomIncrementTextField:NO];
    }
}

- (void)showCustomIncrementTextField:(BOOL)showTextField {
    
    if (showTextField) {
        
        if (self.customIncrementTextField.hidden == YES) {
            
            self.customIncrementTextField.hidden = NO;
            
            // animate down text field
            [UIView animateWithDuration:0.25 animations:^{
                self.customIncrementTextField.frame = CGRectOffset(self.customIncrementTextField.frame, 
                                                              0, 
                                                              kCustomIncrementTextFieldFrameOffsetY);
                
                // resize table view
                self.historyTableView.frame = CGRectMake(self.historyTableView.frame.origin.x, 
                                                    self.historyTableView.frame.origin.y+kHistoryTableViewFrameOffsetY,
                                                    self.historyTableView.frame.size.width,
                                                    self.historyTableView.frame.size.height-kHistoryTableViewFrameOffsetY);
                
            } completion:^(BOOL finished){
                [self.customIncrementTextField becomeFirstResponder];
            }];
            
        }
        
    } else {
        // hide text field
        
        if (self.customIncrementTextField.hidden == NO) {
            [self.customIncrementTextField resignFirstResponder];
            
            // animate up text field
            [UIView animateWithDuration:0.25 animations:^{
                self.customIncrementTextField.frame = CGRectOffset(self.customIncrementTextField.frame, 
                                                              0, 
                                                              -kCustomIncrementTextFieldFrameOffsetY);
                
                // resize table view
                self.historyTableView.frame = CGRectMake(self.historyTableView.frame.origin.x, 
                                                    self.historyTableView.frame.origin.y-kHistoryTableViewFrameOffsetY,
                                                    self.historyTableView.frame.size.width,
                                                    self.historyTableView.frame.size.height+kHistoryTableViewFrameOffsetY);
                
            } completion:^(BOOL finished){
                self.customIncrementTextField.hidden = YES;
            }];
        }
    }
}


- (IBAction)touchedBackground {
    // Hide keyboard
    [self.counterNameTextField resignFirstResponder];
    [self.customIncrementTextField resignFirstResponder];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // delete clicked
        _counterDeleted = YES;
        [self.delegate editCounterViewController:self didDeleteCounter:self.counter];
    }
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Navigation Bar Button Items
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                                                                target:self 
                                                                                action:@selector(doneButtonWasPressed)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    [self.historyTableView registerNib:[UINib nibWithNibName:@"CountRecordTableViewCell" bundle:[NSBundle mainBundle]] 
                forCellReuseIdentifier:_countRecordCellIdentifier];
    
    self.sortedRecords = [self.counter recordsInSectionsSortedByCreationDateAscending:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.counterNameTextField.text = self.counter.name;
    self.customIncrementTextField.hidden = NO;
    
    NSInteger incrementValue = [self.counter.incrementValue integerValue];
    
    NSUInteger segmentIndex;
    
    switch (incrementValue) {
        case 1: {
            segmentIndex = Increment1Index;
            break;
        }
        case 10: {
            segmentIndex = Increment10Index;
            break;
        }
        case 100: {
            segmentIndex = Increment100Index;
            break;
        }
        default:{
            self.customIncrementTextField.text = [NSString stringWithFormat:@"%d", incrementValue];
            segmentIndex = IncrementCustomIndex;
            break;
        }
    }
    
    if (segmentIndex != IncrementCustomIndex) {
        self.customIncrementTextField.hidden = YES;
        
        // hide text field below the segmented control
        self.customIncrementTextField.frame = CGRectOffset(self.customIncrementTextField.frame, 
                                                      0, 
                                                      -kCustomIncrementTextFieldFrameOffsetY);
        
        // resize table view larger
        self.historyTableView.frame = CGRectMake(self.historyTableView.frame.origin.x, 
                                            self.historyTableView.frame.origin.y-kHistoryTableViewFrameOffsetY,
                                            self.historyTableView.frame.size.width,
                                            self.historyTableView.frame.size.height+kHistoryTableViewFrameOffsetY);
    }
    
    // this fires the IB Action, which animates any frame transtions
    self.incrementSegmentedControl.selectedSegmentIndex = segmentIndex; 
}

- (void)viewWillDisappear:(BOOL)animated {
    if (!_counterDeleted) {
        [self saveCounter];
    }
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload {
    self.counterNameTextField = nil;
    self.customIncrementTextField = nil;
    self.incrementSegmentedControl = nil;
    self.historyTableView = nil;
    [super viewDidUnload];
}


#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
//    [self saveCounter];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.sortedRecords count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.sortedRecords objectAtIndex:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    CountRecord *firstInSection = [[self.sortedRecords objectAtIndex:section] objectAtIndex:0];
    return [_sectionHeaderDateFormatter stringFromDate:firstInSection.creationDay];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CountRecordTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_countRecordCellIdentifier];
    
    CountRecord *countRecord = [[self.sortedRecords objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    cell.valueLabel.text = [NSString stringWithFormat:@"%d", [countRecord.value integerValue]];
    cell.dateLabel.text = [_cellDateFormatter stringFromDate:countRecord.creationDate];
    cell.totalLabel.text = [NSString stringWithFormat:@"%d", [countRecord.cumulativeTotal integerValue]];
    
    return cell;
}

@end

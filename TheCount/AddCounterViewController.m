//
//  AddCounterViewController.m
//  TheCount
//
//  Created by Ryan Maxwell on 15/05/11.
//  Copyright 2011 Cactuslab. All rights reserved.
//

#import "AddCounterViewController.h"
#import "EditCounterViewController.h"
#import "Counter.h"
#import "DataAccessor.h"

#define kCustomIncrementTextFieldFrameOffsetY   45

typedef enum {
    Increment1Index = 0,
    Increment10Index,
    Increment100Index,
    IncrementCustomIndex
} IncrementSegmentedControlIndex;

@interface AddCounterViewController ()
- (void)showCustomIncrementTextField:(BOOL)showTextField;
@end

@implementation AddCounterViewController
@synthesize delegate = _delegate;
@synthesize counterNameTextField = _counterNameTextField, customIncrementTextField = _customIncrementTextField;
@synthesize incrementSegmentedControl = _incrementSegmentedControl;

#pragma mark - IBActions

- (IBAction)saveButtonWasPressed {
    if (self.incrementSegmentedControl.selectedSegmentIndex == IncrementCustomIndex && 
        ![EditCounterViewController isCustomIncrementValid:[self.customIncrementTextField.text integerValue]]) {
        // invalid counter increment
        [EditCounterViewController displayInvalidCustomIncrementAlert];
    } else {
        Counter *counter = (Counter *)[NSEntityDescription insertNewObjectForEntityForName:@"Counter" 
                                                                    inManagedObjectContext:[DataAccessor sharedDataAccessor].managedObjectContext];
        counter.name = self.counterNameTextField.text;
        counter.creationDate = [NSDate date];
        
        NSInteger selectedSegmentIndex = self.incrementSegmentedControl.selectedSegmentIndex;
        NSInteger incrementValue;
        switch (selectedSegmentIndex) {
            case Increment1Index:
                incrementValue = 1;
                break;
            case Increment10Index:
                incrementValue = 10;
                break;
            case Increment100Index:
                incrementValue = 100;
                break;
            case IncrementCustomIndex: {
                incrementValue = [self.customIncrementTextField.text integerValue];
                break;
            }
            default:
                incrementValue = 1;
                break;
        }
        
        counter.incrementValue = [NSNumber numberWithInteger:incrementValue];
        
        [[DataAccessor sharedDataAccessor] saveContext];
        [self.delegate addCounterViewController:self didAddCounter:counter];
    }
}

- (IBAction)cancelButtonWasPressed {
	[self.delegate addCounterViewController:self didAddCounter:nil];
}

- (IBAction)incrementValueChanged:(id)sender {
    NSInteger selectedSegmentIndex = ((UISegmentedControl *)sender).selectedSegmentIndex;
    
    if (selectedSegmentIndex == IncrementCustomIndex ) {
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
            } completion:^(BOOL finished){
                [self.customIncrementTextField becomeFirstResponder];
            }];
            
        }
        
    } else {
        // hide text field
        
        if (self.customIncrementTextField.hidden == NO) {
            [self.counterNameTextField becomeFirstResponder];
            
            // animate up text field
            [UIView animateWithDuration:0.25 animations:^{
                self.customIncrementTextField.frame = CGRectOffset(self.customIncrementTextField.frame, 
                                                              0, 
                                                              -kCustomIncrementTextFieldFrameOffsetY);
            } completion:^(BOOL finished){
                self.customIncrementTextField.hidden = YES;
            }];
            
        }
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
    
    // hide text field below the segmented control
    self.customIncrementTextField.frame = CGRectOffset(self.customIncrementTextField.frame, 0, -kCustomIncrementTextFieldFrameOffsetY);
    self.customIncrementTextField.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.counterNameTextField becomeFirstResponder];
}

- (void)viewDidUnload {
    self.counterNameTextField = nil;
    self.customIncrementTextField = nil;
    self.incrementSegmentedControl = nil;
    [super viewDidUnload];
}

@end

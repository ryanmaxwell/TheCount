//
//  FlipsideViewController.m
//  TheCount
//
//  Created by Ryan Maxwell on 8/05/11.
//  Copyright 2011 Cactuslab. All rights reserved.
//

#import "FlipsideViewController.h"
#import "MainViewController.h"
#import "EditCounterViewController.h"
#import "Counter.h"
#import "DataAccessor.h"
#import "CounterPageViewController.h"

#define kMaximumNumberOfCounters    18

@implementation FlipsideViewController

@synthesize delegate = _delegate, counters = _counters;
@synthesize leftHandModeSwitch = _leftHandModeSwitch, countersTableView = _countersTableView;

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.countersTableView.backgroundColor = [UIColor clearColor]; // gets rid of little black corners on cells
    
    [self.countersTableView setEditing:YES animated:NO];
    
    self.leftHandModeSwitch.on = [[[NSUserDefaults standardUserDefaults] valueForKey:@"LeftHandMode"] boolValue];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.countersTableView reloadData];
    
    // disable done button if there is no counters
    self.navigationItem.rightBarButtonItem.enabled = ([self.counters count] > 0) ? YES : NO;
    self.navigationItem.leftBarButtonItem.enabled = ([self.counters count] < kMaximumNumberOfCounters) ? YES : NO;
}

- (void)viewDidUnload {
    self.countersTableView = nil;
    self.leftHandModeSwitch = nil;
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"AddCounter"]) {
        AddCounterViewController *acvc = (AddCounterViewController *)segue.destinationViewController;
        acvc.delegate = self;
    }
}

#pragma mark - Actions

- (IBAction)done {
    [self.delegate flipsideViewControllerDidFinish];
}

- (IBAction)toggleLeftHandMode:(id)sender {
    BOOL isOn = ((UISwitch *)sender).isOn;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:[NSNumber numberWithBool:isOn] forKey:@"LeftHandMode"];
    [defaults synchronize];
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:[NSBundle mainBundle]];
    EditCounterViewController *ecvc = (EditCounterViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"EditCounterViewController"];
    
    ecvc.delegate = self;
    ecvc.counter = [self.counters objectAtIndex:indexPath.row];
    ecvc.navigationItem.title = @"Edit Counter";
    [self.navigationController pushViewController:ecvc animated:YES];
}

#pragma mark - Table View Data Source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"FlipsideCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    Counter *cellCounter = [self.counters objectAtIndex:indexPath.row];
    cell.textLabel.text = cellCounter.name;
    cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator; // table is set to editing mode in viewDidLoad
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.counters count];
}

// re-arranging

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    Counter *movedCounter = [self.counters objectAtIndex:sourceIndexPath.row];
    
    [self.counters removeObject:movedCounter];
    [self.counters insertObject:movedCounter atIndex:destinationIndexPath.row];
    
    [self.delegate movedCounterFromIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
    
    [[DataAccessor sharedDataAccessor] saveContext];
}


// styling of row (hide delete button and remove left indentation)

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath { 
    return NO; 
}

#pragma mark - EditCounterDelegate

- (void)editCounterViewController:(EditCounterViewController *)ecvc didDeleteCounter:(Counter *)counter {
    
    NSUInteger removedCounterIndex = [self.counters indexOfObject:counter];
    [self.counters removeObjectAtIndex:removedCounterIndex];
    
    [[DataAccessor sharedDataAccessor].managedObjectContext deleteObject:counter];
    [[DataAccessor sharedDataAccessor] saveContext];
    
    [self.delegate deletedCounterAtIndex:removedCounterIndex];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - AddCounterDelegate

- (void)addCounterViewController:(AddCounterViewController *)acvc didAddCounter:(Counter *)counter {
    
    if(counter != nil) {
        [self.counters insertObject:counter atIndex:[self.counters count]];
        [self.delegate addedCounter];
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

@end

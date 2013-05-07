//
//  MainViewController.m
//  TheCount
//
//  Created by Ryan Maxwell on 8/05/11.
//  Copyright 2011 Cactuslab. All rights reserved.
//

#import "MainViewController.h"
#import "Counter.h"
#import "CountRecord.h"
#import "CounterPageViewController.h"
#import "DataAccessor.h"


#define kAdViewAnimationDuration    0.25
#define kAdViewHeight               50

#define kIncrementButtonWidth       145
#define kDecrementButtonWidth       125
#define kButtonHeight               130
#define kButtonXOffset              20
#define kScreenWidth                320

@interface MainViewController () {
    BOOL _pageControlUsed;
    BOOL _adViewVisible;
    NSInteger _pageJustLoaded;
    UIAlertView *_resetAlert;
}
- (void)scrollToPage:(NSInteger)page animated:(BOOL)animated;
- (void)sizeScrollViewToFitCounters;
- (void)loadPageAndDirectNeighbors:(NSInteger)page;
- (void)loadScrollViewWithPage:(NSInteger)page;

@end

@implementation MainViewController

@synthesize pageControl = _pageControl, scrollView = _scrollView, adView = _adView, bezelImageView = _bezelImageView;
@synthesize counters = _counters, viewControllers = _viewControllers;
@synthesize incrementButton = _incrementButton, decrementButton = _decrementButton, resetButton = _resetButton;
@synthesize incrementButtonView = _incrementButtonView, decrementButtonView = _decrementButtonView;
@synthesize panelViewLeftBackground = _panelViewLeftBackground, panelViewRightBackground = _panelViewRightBackground;

- (void)setCounterDisplayIndexes {
    [self.counters enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop) {
        Counter *counter = (Counter *)object;
        counter.displayIndex = [NSNumber numberWithUnsignedInteger:index];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowFlipside"]) {
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        FlipsideViewController *fvc = (FlipsideViewController *)navController.topViewController;
        fvc.counters = self.counters;
        fvc.delegate = self;
    }
}

- (CounterPageViewController *)visibleCounterPageViewController {
    NSUInteger visiblePage = self.pageControl.currentPage;
    return [self.viewControllers objectAtIndex:visiblePage];
}

#pragma mark - IBActions

- (IBAction)incrementCounter {
    [self.visibleCounterPageViewController incrementCounter];
}

- (IBAction)decrementCounter {
    [self.visibleCounterPageViewController decrementCounter];
}

- (IBAction)reset {
    NSString *counterName = self.visibleCounterPageViewController.counter.name;
    NSString *alertTitle;
    if ([counterName isEqualToString:@""]) {
        alertTitle = @"Are you sure you want to reset the counter?";
    } else {
        alertTitle = [NSString stringWithFormat:@"Are you sure you want to reset the counter \"%@\"?", counterName];
    }
    
    _resetAlert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                         message:@"This will clear all history" 
                                                        delegate:self 
                                               cancelButtonTitle:@"Cancel" 
                                               otherButtonTitles:@"Reset", nil];
    [_resetAlert show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == _resetAlert) {
        if (buttonIndex == 0) {
            // cancel
        } else {
            // reset
            [self.visibleCounterPageViewController reset];
        }
    }
}


#pragma mark - FlipsideViewControllerDelegate

- (void)flipsideViewControllerDidFinish {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)addedCounter {
    [self.viewControllers addObject:[NSNull null]];
    [self setCounterDisplayIndexes];
}

- (void)deletedCounterAtIndex:(NSUInteger)index {
    id vcToDelete = [self.viewControllers objectAtIndex:index];
    
    if ([vcToDelete isKindOfClass:[CounterPageViewController class]]) {
        CounterPageViewController *vc = (CounterPageViewController *)vcToDelete;
        
        if (vc.view.superview != nil) {
            [vc.view removeFromSuperview];
        }
    }
    
    [self.viewControllers removeObjectAtIndex:index];
    
    [self setCounterDisplayIndexes];
}

- (void)movedCounterFromIndex:(NSUInteger)oldIndex toIndex:(NSUInteger)newIndex {
    
    id vcToMove = [self.viewControllers objectAtIndex:oldIndex]; // may be a VC or an NSNULL
    [self.viewControllers removeObjectAtIndex:oldIndex];
    [self.viewControllers insertObject:vcToMove atIndex:newIndex];
     
    [self setCounterDisplayIndexes];
}


- (NSMutableArray *)fetchPreviousCounters {
    // set up request for previous counters
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *counterEntity = [NSEntityDescription entityForName:@"Counter" inManagedObjectContext:[DataAccessor sharedDataAccessor].managedObjectContext];
    [request setEntity:counterEntity];
    
    // sorting of fetch request
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayIndex" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    // execute the request
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[[DataAccessor sharedDataAccessor].managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        // Handle the error.
        NSLog(@"An error.");
    }
//    NSLog(@"Fetched %d counters from DB", [mutableFetchResults count]);
    
    return mutableFetchResults;
}


#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // setup Ad view - offset off the bottom of the screen
    self.adView.frame = CGRectMake(0, -50, self.adView.frame.size.width, self.adView.frame.size.height);
    self.adView.requiredContentSizeIdentifiers = [NSSet setWithObject:ADBannerContentSizeIdentifierPortrait];
    _adViewVisible = NO;
    
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    
    self.counters = [self fetchPreviousCounters];
    
    NSUInteger numberOfCounters = [self.counters count];
    
    // view controllers are created lazily
    // fill an array with empty objects
    self.viewControllers = [NSMutableArray arrayWithCapacity:numberOfCounters];
    
    for (NSUInteger i = 0; i < numberOfCounters; i++) {
        [self.viewControllers addObject:[NSNull null]];
    }
    
    // a page is the width of the scroll view
    self.scrollView.pagingEnabled = YES;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * numberOfCounters, 
                                             self.scrollView.frame.size.height);
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    
    // set the visible counter to the the preference
    NSUInteger visiblePage = [[NSUserDefaults standardUserDefaults] integerForKey:@"VisiblePage"];
    
    if (visiblePage < [self.counters count]) {
        self.pageControl.currentPage = visiblePage;
    } else {
        self.pageControl.currentPage = 0;
    }
    
    // background
    self.panelViewLeftBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background"]];
    self.panelViewRightBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background"]];
    
    self.panelViewLeftBackground.frame = CGRectOffset(self.panelViewLeftBackground.frame, 
                                                      -self.panelViewLeftBackground.frame.size.width, 
                                                      0);
    [self.scrollView addSubview:self.panelViewLeftBackground];
    
    self.panelViewRightBackground.frame = CGRectOffset(self.panelViewRightBackground.frame, 
                                                       self.panelViewRightBackground.frame.size.width * [self.counters count], 
                                                       0);
    [self.scrollView addSubview:self.panelViewRightBackground];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playSound) name:@"FlipDigitViewWillFlip" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.pageControl.numberOfPages = [self.counters count];
    
    if ([self.counters count] > 0) {
        [self sizeScrollViewToFitCounters];
        // pages are created on demand
        // load the visible page
        // load the page on either side to avoid flashes when the user starts scrolling
        [self loadPageAndDirectNeighbors:self.pageControl.currentPage];
        [self scrollToPage:self.pageControl.currentPage animated:NO];
    }
    
    BOOL leftHandMode = [[NSUserDefaults standardUserDefaults] boolForKey:@"LeftHandMode"];
    
    CGFloat incrementButtonViewXOffset = leftHandMode ? kScreenWidth-kButtonXOffset-kIncrementButtonWidth : kButtonXOffset;
    CGFloat decrementButtonViewXOffset = leftHandMode ? kButtonXOffset : kScreenWidth-kButtonXOffset-kDecrementButtonWidth;
    
    self.incrementButtonView.frame = CGRectMake(incrementButtonViewXOffset, 
                                           self.incrementButtonView.frame.origin.y, 
                                           self.incrementButtonView.frame.size.width, 
                                           self.incrementButtonView.frame.size.height);
    
    self.decrementButtonView.frame = CGRectMake(decrementButtonViewXOffset, 
                                           self.decrementButtonView.frame.origin.y, 
                                           self.decrementButtonView.frame.size.width, 
                                           self.decrementButtonView.frame.size.height);
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSUInteger numberOfCounters = [self.counters count];
    if (numberOfCounters == 0) {
        // needs to be after a delay or else doesn't work in first time viewDidAppear
        [self performSegueWithIdentifier:@"ShowFlipside" sender:self];
    }
    
//    NSLog(@"current page: %d", self.pageControl.currentPage);
}


- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.pageControl = nil;
    self.scrollView = nil;
    self.viewControllers = nil;
    self.counters = nil;
    self.adView = nil;
    self.bezelImageView = nil;
    self.incrementButton = nil;
    self.decrementButton = nil;
    self.incrementButtonView = nil;
    self.decrementButtonView = nil;
    self.panelViewLeftBackground = nil;
    self.panelViewRightBackground = nil;
    [super viewDidUnload];
}

#pragma mark - Counter Page Loading

- (void)loadPageAndDirectNeighbors:(NSInteger)page {
    NSInteger numberOfPages = [self.counters count];
    
    if (page > 0) {
        [self loadScrollViewWithPage:page - 1];
        [[self.viewControllers objectAtIndex:page - 1] viewWillAppear:NO];
    }
    
    if (page >= 0 && page < numberOfPages) {
        [self loadScrollViewWithPage:page];
        [[self.viewControllers objectAtIndex:page] viewWillAppear:NO];
        [[self.viewControllers objectAtIndex:page] viewDidAppear:NO];
        
        self.pageControl.currentPage = page;
        _pageJustLoaded = page;
    }
    
    if (page < numberOfPages-1) {
        [self loadScrollViewWithPage:page + 1];
        [[self.viewControllers objectAtIndex:page + 1] viewWillAppear:NO];
    }
}


- (void)loadScrollViewWithPage:(NSInteger)page {
    NSInteger numberOfCounters = [self.counters count];
    
    self.panelViewRightBackground.frame = CGRectMake(self.panelViewRightBackground.frame.size.width * numberOfCounters, 
                                                     0, 
                                                     self.panelViewRightBackground.frame.size.width, 
                                                     self.panelViewRightBackground.frame.size.height);
    
    if (page < 0)
        return;
    
    if (page >= numberOfCounters)
        return;
    
    CounterPageViewController *controller;
    
    BOOL createViewController = NO;
    BOOL replaceNullObject = NO;
    
    // create view controller if necessary
    NSInteger numberOfViewControllers = [self.viewControllers count];
    if (page >= numberOfViewControllers) {
        createViewController = YES;
    } else {
        controller = [self.viewControllers objectAtIndex:page];
        if ([controller isKindOfClass:[NSNull class]]) {
            createViewController = YES;
            replaceNullObject = YES;
        }
    }
    
    if (createViewController) {
        Counter *counter = [self.counters objectAtIndex:page];
        controller = [[CounterPageViewController alloc] initWithCounter:counter];
        
        if (replaceNullObject) {
            [self.viewControllers replaceObjectAtIndex:page withObject:controller];
        } else {
            [self.viewControllers insertObject:controller atIndex:page];
        }
    }
    
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    controller.view.frame = frame;
    
    // add the controller's view to the scroll view
    if (controller.view.superview == nil) {
        [self.scrollView addSubview:controller.view];
    }
}

#pragma mark - Scroll View Pagination

- (void)sizeScrollViewToFitCounters {
    NSInteger numOfCounters = [self.counters count];
    self.pageControl.numberOfPages = numOfCounters;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * numOfCounters, 
                                             self.scrollView.frame.size.height);
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if (_pageControlUsed) {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
	
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    NSInteger page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    if (page != _pageJustLoaded) {
        [self loadPageAndDirectNeighbors:page];
    }
    
    // A possible optimization would be to unload the views+controllers which are no longer visible
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _pageControlUsed = NO;
}

- (void)scrollToPage:(NSInteger)page animated:(BOOL)animated {
    // update the scroll view to the appropriate page
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:animated];
}

- (IBAction)changePage:(id)sender {
    NSInteger page = self.pageControl.currentPage;
	
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadPageAndDirectNeighbors:page];
    [self scrollToPage:page animated:YES];
    
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    _pageControlUsed = YES;
}


#pragma mark - AdBannerView Delegate

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    if (!_adViewVisible) {
        [UIView animateWithDuration:kAdViewAnimationDuration 
                         animations:^{
                             // banner is invisible now and moved out of the frame by -50 px
                             banner.frame = CGRectOffset(banner.frame, 0, kAdViewHeight);
                             
                             // move content down 50 px
                             self.scrollView.frame = CGRectOffset(self.scrollView.frame, 0, kAdViewHeight);
                             self.bezelImageView.frame = CGRectOffset(self.bezelImageView.frame, 0, kAdViewHeight);
                             self.pageControl.frame = CGRectOffset(self.pageControl.frame, 0, kAdViewHeight-5);
                         } 
                         completion:^(BOOL finished){ 
                             _adViewVisible = YES; 
                         }];
    }
}


- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    if (_adViewVisible) {
        [UIView animateWithDuration:kAdViewAnimationDuration 
                         animations:^{
                             // banner is visible and we move it out of the screen
                             banner.frame = CGRectOffset(banner.frame, 0, -kAdViewHeight);
                             
                             // move content up 50 px
                             self.scrollView.frame = CGRectOffset(self.scrollView.frame, 0, -kAdViewHeight);
                             self.bezelImageView.frame = CGRectOffset(self.bezelImageView.frame, 0, -kAdViewHeight);
                             self.pageControl.frame = CGRectOffset(self.pageControl.frame, 0, -kAdViewHeight+5);
                         } 
                         completion:^(BOOL finished){ 
                             _adViewVisible = NO;
                         }];
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Not portrait upside down
    
    return (UIInterfaceOrientationIsLandscape(interfaceOrientation) || interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    @synchronized(self) {
        // unload any view controllers that aren't visible/on either side of current page
        NSUInteger currentPage = self.pageControl.currentPage;
        
        NSMutableIndexSet *indexesToRemove = [NSMutableIndexSet indexSet];
        
        [self.viewControllers enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop) {
            if (index != currentPage && index != currentPage+1 && index != currentPage-1) {
                if ([object isKindOfClass:[CounterPageViewController class]]) {
                    CounterPageViewController *vc = (CounterPageViewController *)object;
                    [vc.view removeFromSuperview]; // remove from scroll view
                    [indexesToRemove addIndex:index];
                }
            }
        }];
        
        NSUInteger nullsToCreate = [indexesToRemove count];
        NSMutableArray *nullArray = [NSMutableArray arrayWithCapacity:nullsToCreate];
        for (NSUInteger i = 0; i < nullsToCreate; i++) {
            [nullArray addObject:[NSNull null]];
        }
//        NSLog(@"vc count: %d killed: %d", [viewControllers count], [indexesToRemove count]);
        
        [self.viewControllers replaceObjectsAtIndexes:indexesToRemove withObjects:nullArray];
    }
}

@end

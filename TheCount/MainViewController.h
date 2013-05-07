//
//  MainViewController.h
//  TheCount
//
//  Created by Ryan Maxwell on 8/05/11.
//  Copyright 2011 Cactuslab. All rights reserved.
//

#import "FlipsideViewController.h"
#import <iAd/iAd.h>
#import <AVFoundation/AVFoundation.h>

@class CounterPageViewController;

@interface MainViewController : UIViewController <UIScrollViewDelegate, ADBannerViewDelegate, FlipsideViewControllerDelegate> 
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;
@property (nonatomic, weak) IBOutlet ADBannerView *adView;
@property (nonatomic, weak) IBOutlet UIImageView *bezelImageView;

@property (nonatomic, weak) IBOutlet UIButton *incrementButton;
@property (nonatomic, weak) IBOutlet UIButton *decrementButton;
@property (nonatomic, weak) IBOutlet UIButton *resetButton;

@property (nonatomic, weak) IBOutlet UIView *incrementButtonView;
@property (nonatomic, weak) IBOutlet UIView *decrementButtonView;

@property (nonatomic, strong) UIImageView *panelViewLeftBackground;
@property (nonatomic, strong) UIImageView *panelViewRightBackground;

@property (nonatomic, strong) NSMutableArray *counters;
@property (nonatomic, strong) NSMutableArray *viewControllers;

@property (nonatomic, readonly) CounterPageViewController *visibleCounterPageViewController;

- (IBAction)changePage:(id)sender;
- (IBAction)incrementCounter;
- (IBAction)decrementCounter;
- (IBAction)reset;
- (void)setCounterDisplayIndexes;
@end

//
//  FlipDigitsView.h
//  TheCount
//
//  Created by Ryan Maxwell on 28/05/11.
//  Copyright 2011 Cactuslab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlipDigitView.h"
@protocol FlipDigitPanelViewDelegate;

@interface FlipDigitPanelView : UIView <FlipDigitViewDelegate>
@property (nonatomic, weak) IBOutlet id<FlipDigitPanelViewDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *flipDigits;

- (void)layoutNumberOfFlipDigitViews:(NSUInteger)numberOfViews;
- (void)displayIntegerValue:(NSInteger)value;

@end

@protocol FlipDigitPanelViewDelegate <NSObject>
@required
- (void)flipDigitPanelViewFinishedUpdating;
@end

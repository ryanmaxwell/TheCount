//
//  FlipDigitsView.m
//  TheCount
//
//  Created by Ryan Maxwell on 28/05/11.
//  Copyright 2011 Cactuslab. All rights reserved.
//

#import "FlipDigitPanelView.h"
#import "FlipDigitView.h"

#define kFlipDigitTransformAnimationDuration    0.25

#define kFlipDigitInitialOriginX                23
#define kFlipDigitPadding                       2
#define kFlipDigitMaximumWidth                  90
#define kFlipDigitMaximumHeight                 130

@interface FlipDigitPanelView () {
    BOOL _scaleChanged;
    NSUInteger _charactersUpdated;
    NSUInteger _charactersToUpdate;
    
    NSUInteger _currentNumberOfFlipDigitsVisible;
    CGFloat _currentTransformScale;
}
@end

@implementation FlipDigitPanelView
@synthesize delegate = _delegate;
@synthesize flipDigits = _flipDigits;

// Called when view is unarchived from inside CounterPageView nib
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.flipDigits = [NSMutableArray array];
        _currentNumberOfFlipDigitsVisible = 0;
        _currentTransformScale = 1;
    }
    return self;
}

- (void)layoutNumberOfFlipDigitViews:(NSUInteger)numberOfViewsToLayout {
    if (numberOfViewsToLayout == _currentNumberOfFlipDigitsVisible) {
        return;
    }
    
    _currentNumberOfFlipDigitsVisible = numberOfViewsToLayout;
    
    NSUInteger currentNumberOfViews = [self.flipDigits count];
    
    if (numberOfViewsToLayout > currentNumberOfViews) {
        // create necessary flip digits
        NSUInteger numberOfViewsToCreate = numberOfViewsToLayout - currentNumberOfViews;
        
        NSInteger flipDigitViewOriginX = kFlipDigitMaximumWidth * [self.flipDigits count] + kFlipDigitInitialOriginX;
        
        for (NSUInteger viewNumber = 0; viewNumber < numberOfViewsToCreate; viewNumber++) {
            FlipDigitView *flipDigit = [[FlipDigitView alloc] init];
            flipDigit.delegate = self;
            [self addSubview:flipDigit];
            
            flipDigit.frame = CGRectMake(flipDigitViewOriginX, 0, kFlipDigitMaximumWidth, kFlipDigitMaximumHeight);
            [self.flipDigits addObject:flipDigit];
                 
            flipDigitViewOriginX += kFlipDigitMaximumWidth;
        }
    }
    
    // we have 280px width to work with, with kFlipDigitPadding px between each digit
    
    NSUInteger numberOfSpaces = numberOfViewsToLayout - 1;
    NSUInteger totalWidthWithoutSpaces = (320 - 2 * kFlipDigitInitialOriginX) - (numberOfSpaces * kFlipDigitPadding);
    CGFloat maximumDigitWidth = totalWidthWithoutSpaces/numberOfViewsToLayout;
    
    CGFloat digitWidth = maximumDigitWidth > kFlipDigitMaximumWidth ? kFlipDigitMaximumWidth : maximumDigitWidth;    
    CGFloat scale = digitWidth/kFlipDigitMaximumWidth;
    
    NSUInteger midHeight = kFlipDigitMaximumHeight/2;
    CGFloat frameOriginY = midHeight - ((midHeight * scale));    
    if (_currentTransformScale != scale) {
        _scaleChanged = YES;
        _currentTransformScale = scale;
    } else {
        _scaleChanged = NO;
    }
    
    __block NSUInteger currentFrameOriginX = kFlipDigitInitialOriginX;
    
    [self.flipDigits enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop){
        FlipDigitView *flipDigit = (FlipDigitView *)object;
        
        CGRect flipDigitFrame = CGRectMake(currentFrameOriginX, frameOriginY, digitWidth, kFlipDigitMaximumHeight);
        
        if (index < numberOfViewsToLayout) {
            flipDigit.hidden = NO;
        } else {
            flipDigit.hidden = YES;
        }
        
        if (_scaleChanged) {
            // animate in/out extra digit
            
            [UIView animateWithDuration:kFlipDigitTransformAnimationDuration 
                             animations:^{
                flipDigit.transform = CGAffineTransformMakeScale(scale, scale);
                flipDigit.frame = flipDigitFrame;
            } completion:^(BOOL finished){}];
        
        } else {
            flipDigit.frame = flipDigitFrame;
        }
        
        currentFrameOriginX += digitWidth + kFlipDigitPadding;
    }];
}


- (void)displayIntegerValue:(NSInteger)integerValue {
    // always displays at least 3 characters (leading zeros)
    NSString *integerValueString = [NSString stringWithFormat:@"%03d", integerValue];
//    NSLog(@"string value: %@", integerValueString);
    NSUInteger digitCount = [integerValueString length];
    
    [self layoutNumberOfFlipDigitViews:digitCount];
    
    _charactersUpdated = 0;
    _charactersToUpdate = digitCount;
    
    for (NSUInteger charIndex = 0; charIndex < digitCount; charIndex++) {
        
        FlipDigitView *flipDigit = [self.flipDigits objectAtIndex:charIndex];
        
        NSRange charRange = NSMakeRange(charIndex, 1);
        NSString *newValueString = [integerValueString substringWithRange:charRange];
        
        [flipDigit changeToCharacterString:newValueString];
    }
}

#pragma mark - FlipDigitViewDelegate

- (void)flipDigitViewFinishedUpdating {
    _charactersUpdated++;
    if (_charactersUpdated == _charactersToUpdate) {
        [self.delegate flipDigitPanelViewFinishedUpdating];
    }
}

@end

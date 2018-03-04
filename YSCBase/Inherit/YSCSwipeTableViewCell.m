//
//  YSCSwipeTableViewCell.m
//  YSCKitDemo
//
//  Created by Builder on 16/10/8.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "YSCSwipeTableViewCell.h"

/**
 *  overlay on tableview to prevent multiple swipe
 */
@interface YSCSwipeTableOverlayView : UIView
@property (nonatomic, weak) YSCSwipeTableViewCell *cell;
@end
@implementation YSCSwipeTableOverlayView
+ (instancetype)overlayViewWithCell:(YSCSwipeTableViewCell *)cell onView:(UIView *)view {
    YSCSwipeTableOverlayView *overlayView = [[YSCSwipeTableOverlayView alloc] initWithFrame:view.bounds];
    if ( ! overlayView) {
        return nil;
    }
    overlayView.backgroundColor = [UIColor clearColor];
    overlayView.cell = cell;
    [view addSubview:overlayView];
    return overlayView;
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if ( ! event) {
        return nil;
    }
    
    CGPoint pointOnCell = [self convertPoint:point toView:self.cell];
    if (CGRectContainsPoint(self.cell.bounds, pointOnCell)) {
        UIView *cellImageView = [self.cell valueForKey:@"_cellImageView"];
        CGPoint pointOnCellImageView = [self.cell convertPoint:pointOnCell toView:cellImageView];
        if ( ! CGRectContainsPoint(cellImageView.bounds, pointOnCellImageView)) {
            return nil;// response cross to cell
        }
    }
    
    [self.cell hideSwipeAnimated:YES];// not the cell actions, so hide it
    return self;// meanwhile prevent other cells' response
}
@end


@interface YSCSwipeTableViewCell ()
@property (nonatomic, strong, nullable) UIImageView *cellImageView;
@property (nonatomic, strong) YSCSwipeTableOverlayView *tableOverlayView;
@property (nonatomic, strong) UIView *swipeContainerView;     // shows when start swiping, hides when ended
@property (nonatomic, strong) UIView *leftContainerView;      // left actions
@property (nonatomic, strong) UIView *rightContainerView;     // right actions
@property (nonatomic, strong) NSArray<UIView *> *leftActions;
@property (nonatomic, strong) NSArray<UIView *> *rightActions;
@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, weak) UITableView *parentTableView;

@property (nonatomic, assign) YSCSwipeState swipeState;
@property (nonatomic, assign) CGFloat swipeOffset;
@property (nonatomic, assign) CGPoint startPanPoint;
@property (nonatomic, assign) UITableViewCellSelectionStyle previusSelectionStyle;
@property (nonatomic, assign) BOOL isAnimating;
@end

@implementation YSCSwipeTableViewCell

#pragma mark - override
- (void)prepareForReuse {
    [super prepareForReuse];
    [self cleanActions];
}
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if (editing) {
        [self hideSwipeAnimated:animated];
    }
}

#pragma mark - private methods
- (void)setup {
    [super setup];
    self.animateDuration = 0.3f;
    self.leftActions = @[];
    self.rightActions = @[];
    if (nil == self.panRecognizer) {
        self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_panHandler:)];
        [self addGestureRecognizer:self.panRecognizer];
        self.panRecognizer.delegate = self;
    }
    
    if (nil == self.swipeContainerView) {
        self.swipeContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        self.swipeContainerView.hidden = YES;
        self.swipeContainerView.layer.zPosition = 100;// ensure on the top of contentView
        [self.contentView addSubview:self.swipeContainerView];
    }
    
    if (nil == self.leftContainerView) {
        self.leftContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        self.leftContainerView.backgroundColor = [UIColor clearColor];
        self.leftContainerView.clipsToBounds = YES;
        [self.swipeContainerView addSubview:self.leftContainerView];
    }
    
    if (nil == self.rightContainerView) {
        self.rightContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        self.rightContainerView.backgroundColor = [UIColor clearColor];
        self.rightContainerView.clipsToBounds = YES;
        [self.swipeContainerView addSubview:self.rightContainerView];
    }
    
    if (nil == self.cellImageView) {
        self.cellImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.cellImageView.contentMode = UIViewContentModeCenter;
        self.cellImageView.clipsToBounds = YES;
        self.cellImageView.backgroundColor = [UIColor clearColor];
        [self.swipeContainerView addSubview:self.cellImageView];
    }
}
- (void)_createActionsIfNeeded {
    if (self.leftActions.count == 0 && self.actionsBlock) {
        self.leftActions = self.actionsBlock(self, YSCSwipeDirectionLeftToRight);
    }
    if (self.rightActions.count == 0 && self.actionsBlock) {
        self.rightActions = self.actionsBlock(self, YSCSwipeDirectionRightToLeft);
    }
}
- (void)_layoutActions {
    self.swipeContainerView.hidden = NO;
    self.swipeContainerView.frame = self.bounds;
    self.cellImageView.frame = self.swipeContainerView.bounds;
    self.leftContainerView.frame = CGRectMake(0, 0, 0, self.ysc_height);
    self.rightContainerView.frame = CGRectMake(self.ysc_width, 0, 0, self.ysc_height);
    
    // layout left container view
    CGFloat lastMaxX = 0;
    for (int i = 0; i < self.leftActions.count; i++) {
        UIView *view = self.leftActions[i];
        view.ysc_top = 0;
        view.ysc_left = lastMaxX;
        view.ysc_height = self.ysc_height;
        if (view.ysc_width <= 0) {
            view.ysc_width = self.ysc_height;
        }
        [self.leftContainerView addSubview:view];
        
        lastMaxX = CGRectGetMaxX(view.frame);
    }
    self.leftContainerView.ysc_width = lastMaxX;
    
    // layout right container view
    lastMaxX = 0;
    for (int i = 0; i < self.rightActions.count; i++) {
        UIView *view = self.rightActions[i];
        view.ysc_top = 0;
        view.ysc_left = lastMaxX;
        view.ysc_height = self.ysc_height;
        if (view.ysc_width <= 0) {
            view.ysc_width = self.ysc_height;
        }
        [self.rightContainerView addSubview:view];
        
        lastMaxX = CGRectGetMaxX(view.frame);
    }
    self.rightContainerView.ysc_width = lastMaxX;
    self.rightContainerView.ysc_left = self.ysc_width - lastMaxX;
}
- (UIColor *)_backgroundColorForSwipeContainer {
    if (self.swipeContainerBackgroundColor) {
        return self.swipeContainerBackgroundColor;
    }
    if (self.contentView.backgroundColor &&
        ! [self.contentView.backgroundColor isEqual:[UIColor clearColor]]) {
        return self.contentView.backgroundColor;
    }
    if (self.backgroundColor) {
        return self.backgroundColor;
    }
    return [UIColor clearColor];
}
- (void)_hideActionsWithAnimated:(BOOL)animated completion:(nullable void(^)(BOOL finished))completion {
    [UIView animateWithDuration:animated ? self.animateDuration : 0 animations:^{
        self.swipeOffset = 0;
    } completion:^(BOOL finished) {
        self.swipeState = YSCSwipeStateNone;
        self.cellImageView.image = nil;
        self.swipeContainerView.hidden = YES;
        if (self.tableOverlayView) {
            [self.tableOverlayView removeFromSuperview];
            self.tableOverlayView = nil;
        }
        self.selectionStyle = self.previusSelectionStyle;
        self.parentTableView.panGestureRecognizer.enabled = YES;
        self.isAnimating = NO;
        if (completion) {
            completion(YES);
        }
    }];
}
- (void)_showActionsWithState:(YSCSwipeState)state animated:(BOOL)animated completion:(nullable void(^)(BOOL finished))completion {
    [UIView animateWithDuration:animated ? self.animateDuration : 0 animations:^{
        if (YSCSwipeStateLeftShows == state) {
            self.swipeOffset = self.leftContainerView.ysc_width;
        }
        else {
            self.swipeOffset = -self.rightContainerView.ysc_width;
        }
    } completion:^(BOOL finished) {
        self.swipeState = state;
        self.isAnimating = NO;
        if (completion) {
            completion(YES);
        }
    }];
}
- (void)_panHandler:(UIPanGestureRecognizer *)gesture {
    CGPoint currentPanPoint = [gesture translationInView:self];
    if (UIGestureRecognizerStateBegan == gesture.state) {
        self.highlighted = NO;
        self.startPanPoint = currentPanPoint;
        if (YSCSwipeStateNone == self.swipeState) {
            self.swipeState = YSCSwipeStateSwipingStart;
        }
    }
    else if (UIGestureRecognizerStateChanged == gesture.state) {
        CGFloat offset = currentPanPoint.x - self.startPanPoint.x;
        if (YSCSwipeStateSwipingStart == self.swipeState ||
            YSCSwipeStateLeftShows == self.swipeState ||
            YSCSwipeStateRightShows == self.swipeState) {
            self.swipeState = offset > 0 ? YSCSwipeStateSwipingLeftToRight : YSCSwipeStateSwipingRightToLeft;
        }
        if ((YSCSwipeStateSwipingLeftToRight == self.swipeState && offset < 0) ||
            (YSCSwipeStateSwipingRightToLeft == self.swipeState && offset > 0)) {
            offset = 0;
        }
        if (offset > 0) {
            offset = MIN(offset, self.leftContainerView.ysc_width + 10);
        }
        else if (offset < 0) {
            offset = MAX(offset, -self.rightContainerView.ysc_width - 10);
        }
        self.swipeOffset = offset;
    }
    else {//ended
        CGFloat minOffset = 0;
        YSCSwipeState state = YSCSwipeStateNone;
        if (YSCSwipeStateSwipingLeftToRight == self.swipeState) {
            state = YSCSwipeStateLeftShows;
            minOffset = self.leftContainerView.ysc_width / 3;
        }
        else if (YSCSwipeStateSwipingRightToLeft == self.swipeState) {
            state = YSCSwipeStateRightShows;
            minOffset = self.rightContainerView.ysc_width / 3;
        }
        minOffset = MAX(10, minOffset); // swipe min length at least
        if (fabs(self.swipeOffset) < minOffset) {
            [self _hideActionsWithAnimated:fabs(self.swipeOffset) > 0 ? YES : NO
                                completion:nil];
        }
        else {// do swiping
            [self _showActionsWithState:state animated:YES completion:nil];
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.panRecognizer) {
        if (self.isEditing) {
            return NO; //do not swipe while editing table
        }
        CGPoint translation = [self.panRecognizer translationInView:self];
        if (fabs(translation.y) > fabs(translation.x)) {
            return NO; // user is scrolling vertically
        }
        // prevent swipe on actions
        if (YSCSwipeStateNone != self.swipeState) {
            return NO;
        }
        
        [self _createActionsIfNeeded];
        BOOL allowSwipeLeftToRight = self.leftActions.count > 0;
        BOOL allowSwipeRightToLeft = self.rightActions.count > 0;
        return (allowSwipeLeftToRight && translation.x > 0) || (allowSwipeRightToLeft && translation.x < 0);
    }
    
    return [super gestureRecognizerShouldBegin:gestureRecognizer];
}

#pragma mark - properties
- (void)setSwipeContainerBackgroundColor:(UIColor *)swipeContainerBackgroundColor {
    _swipeContainerBackgroundColor = swipeContainerBackgroundColor;
    self.swipeContainerView.backgroundColor = swipeContainerBackgroundColor;
}
- (void)setSwipeOffset:(CGFloat)swipeOffset {
    _swipeOffset = swipeOffset;
    self.cellImageView.ysc_left = swipeOffset;
//    self.cellImageView.transform = CGAffineTransformMakeTranslation(_swipeOffset, 0);// the other method
}
- (void)setSwipeState:(YSCSwipeState)swipeState {
    _swipeState = swipeState;
    if (YSCSwipeStateSwipingStart == swipeState) {
        self.previusSelectionStyle = self.selectionStyle;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.cellImageView.image = [self ysc_snapshotImage];
        self.swipeContainerView.hidden = NO;
        self.swipeContainerView.backgroundColor = [self _backgroundColorForSwipeContainer];
        [self _layoutActions];
        
        // prevent tableview responses
        self.parentTableView.panGestureRecognizer.enabled = NO;
        if ( ! self.tableOverlayView) {
            self.tableOverlayView = [YSCSwipeTableOverlayView overlayViewWithCell:self onView:self.parentTableView];
        }
    }
    
    if (self.swipeStateChangedBlock) {
        self.swipeStateChangedBlock(self, swipeState);
    }
}
- (UITableView *)parentTableView {
    return [self valueForKey:@"_tableView"];
}

#pragma mark - public methods
- (void)hideSwipeAnimated:(BOOL)animated {
    [self hideSwipeAnimated:animated completion:nil];
}
- (void)hideSwipeAnimated:(BOOL)animated completion:(nullable void(^)(BOOL finished))completion {
    if (self.isAnimating || YSCSwipeStateNone == self.swipeState) {
        if (completion) {
            completion(NO);
        }
        return;
    }
    self.isAnimating = YES;
    [self _hideActionsWithAnimated:animated completion:completion];
}
- (void)showSwipe:(YSCSwipeDirection)direction animated:(BOOL)animated {
    [self showSwipe:direction animated:animated completion:nil];
}
- (void)showSwipe:(YSCSwipeDirection)direction animated:(BOOL)animated completion:(nullable void(^)(BOOL finished))completion {
    if (self.isAnimating) {
        if (completion) {
            completion(NO);
        }
        return;
    }
    self.isAnimating = YES;
    
    // check if can swipe
    [self _createActionsIfNeeded];
    if ((0 == self.leftActions.count && 0 == self.rightActions.count) ||
        (YSCSwipeDirectionLeftToRight == direction && 0 == self.leftActions.count) ||
        (YSCSwipeDirectionRightToLeft == direction && 0 == self.rightActions.count)) {
        self.isAnimating = NO;
        if (completion) {
            completion(NO);
        }
        return;
    }
    self.swipeState = YSCSwipeStateSwipingStart;
    
    // do swiping
    if (YSCSwipeDirectionLeftToRight == direction) {
        [self _showActionsWithState:YSCSwipeStateLeftShows animated:YES completion:completion];
    }
    else {
        [self _showActionsWithState:YSCSwipeStateRightShows animated:YES completion:completion];
    }
}
- (void)cleanActions {
    self.swipeOffset = 0;
    self.leftActions = @[];
    self.rightActions = @[];
    self.actionsBlock = nil;
    self.swipeState = YSCSwipeStateNone;
    self.swipeContainerBackgroundColor = nil;
    [self.leftContainerView ysc_removeAllSubviews];
    [self.rightContainerView ysc_removeAllSubviews];
}

@end

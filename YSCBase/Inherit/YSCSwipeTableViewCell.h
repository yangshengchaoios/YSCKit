//
//  YSCSwipeTableViewCell.h
//  YSCKitDemo
//
//  Created by Builder on 16/10/8.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import <UIKit/UIKit.h>

/** swipe directions */
typedef NS_ENUM(NSInteger, YSCSwipeDirection) {
    YSCSwipeDirectionLeftToRight,
    YSCSwipeDirectionRightToLeft,
};

/** state when swiping  */
typedef NS_ENUM(NSInteger, YSCSwipeState) {
    YSCSwipeStateNone               = 0,
    YSCSwipeStateSwipingStart,
    YSCSwipeStateSwipingLeftToRight,
    YSCSwipeStateSwipingRightToLeft,
    YSCSwipeStateLeftShows,
    YSCSwipeStateRightShows,
};

@interface YSCSwipeTableViewCell : YSCBaseTableViewCell

/**
 *  Optional background color for swipe overlay. If not set,
 *  its inferred automatically from the cell contentView
 */
@property (nonatomic, strong, nullable) UIColor *swipeContainerBackgroundColor;
/** animate duration when show and hide swipe cell, default is 0.3f */
@property (nonatomic, assign) CGFloat animateDuration;
/** compatible for UIButton/UILabel/UIImageView */
@property (nonatomic, copy, nullable) NSArray<UIView *> * __nullable (^actionsBlock)(YSCSwipeTableViewCell * __nonnull cell, YSCSwipeDirection direction);
/** callback when swipestate changed */
@property (nonatomic, copy, nullable) void (^swipeStateChangedBlock)(YSCSwipeTableViewCell * __nonnull cell, YSCSwipeState swipeState);

/** show or hide swipe actions programmatically */
- (void)hideSwipeAnimated:(BOOL)animated;
- (void)hideSwipeAnimated:(BOOL)animated completion:(nullable void(^)(BOOL finished))completion;
- (void)showSwipe:(YSCSwipeDirection)direction animated:(BOOL)animated;
- (void)showSwipe:(YSCSwipeDirection)direction animated:(BOOL)animated completion:(nullable void(^)(BOOL finished))completion;
/** maybe used in some special cases */
- (void)cleanActions;

@end

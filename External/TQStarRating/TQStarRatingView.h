//
//  TQStarRatingView.h
//  TQStarRatingView
//
//  Created by fuqiang on 13-8-28.
//  Copyright (c) 2013年 TinyQ. All rights reserved.
//


#import <UIKit/UIKit.h>

@class TQStarRatingView;

@protocol StarRatingViewDelegate <NSObject>

@optional
-(void)starRatingView:(TQStarRatingView *)view score:(float)score;

@end

@interface TQStarRatingView : UIView

@property (nonatomic, readonly) int numberOfStar;

@property (nonatomic, weak) id <StarRatingViewDelegate> delegate;

/**
 *  初始化TQStarRatingView
 *
 *  @return TQStarRatingViewObject
 */
- (id)initWithFrame:(CGRect)frame numberOfStar:(int)number
     backgroundName:(NSString *)bgName
      foregoundName:(NSString *)fgName
          seperator:(NSInteger)seperator;

/**
 *  设置控件分数
 *
 */
- (void)setScore:(float)score withAnimation:(bool)isAnimate;

/**
 *  设置控件分数
 *
 */
- (void)setScore:(float)score withAnimation:(bool)isAnimate completion:(void (^)(BOOL finished))completion;

@end
//
//  TQStarRatingView.m
//  TQStarRatingView
//
//  Created by fuqiang on 13-8-28.
//  Copyright (c) 2013年 TinyQ. All rights reserved.
//

#import "TQStarRatingView.h"

#define kBACKGROUND_STAR @"star_background"
#define kFOREGROUND_STAR @"star_foreground"
#define kNUMBER_OF_STAR  5
#define kWidthSeperator  5

@interface TQStarRatingView ()

@property (nonatomic, strong) UIView *starBackgroundView;
@property (nonatomic, strong) UIView *starForegroundView;

@property (nonatomic, strong) NSString *starBackgroundName;
@property (nonatomic, strong) NSString *starForegroundName;
@property (nonatomic, assign) NSInteger widthSeperator;

@end

@implementation TQStarRatingView

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame numberOfStar:kNUMBER_OF_STAR backgroundName:kBACKGROUND_STAR foregoundName:kFOREGROUND_STAR seperator:kWidthSeperator];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _numberOfStar = kNUMBER_OF_STAR;
    _starBackgroundName = kBACKGROUND_STAR;
    _starForegroundName = kFOREGROUND_STAR;
    _widthSeperator = kWidthSeperator;
    [self commonInit];
}

/**
 *  初始化TQStarRatingView
 *
 *  @return TQStarRatingViewObject
 */
- (id)initWithFrame:(CGRect)frame numberOfStar:(int)number
     backgroundName:(NSString *)bgName
      foregoundName:(NSString *)fgName
          seperator:(NSInteger)seperator
{
    self = [super initWithFrame:frame];
    if (self) {
        _starBackgroundName = bgName;
        _starForegroundName = fgName;
        _numberOfStar = number;
        _widthSeperator = seperator;
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.starBackgroundView = [self buidlStarViewWithImageName:self.starBackgroundName];
    self.starForegroundView = [self buidlStarViewWithImageName:self.starForegroundName];
    [self addSubview:self.starBackgroundView];
    [self addSubview:self.starForegroundView];
}

#pragma mark -
#pragma mark - Set Score

/**
 *  设置控件分数
 */
- (void)setScore:(float)score withAnimation:(bool)isAnimate
{
    [self setScore:score withAnimation:isAnimate completion:^(BOOL finished){}];
}

/**
 *  设置控件分数
 *
 *  @param score      分数，必须在 0 － 1 之间
 *  @param isAnimate  是否启用动画
 *  @param completion 动画完成block
 */
- (void)setScore:(float)score withAnimation:(bool)isAnimate completion:(void (^)(BOOL finished))completion
{
    NSAssert((score >= 0.0)&&(score <= 1.0), @"score must be between 0 and 1");
    
    if (score < 0)
    {
        score = 0;
    }
    
    if (score > 1)
    {
        score = 1;
    }
    UIImage *starImage = [UIImage imageNamed:self.starBackgroundName];
    float numberOfStars = floorf(score);
    
    CGPoint point = CGPointMake(numberOfStars * (starImage.size.width + self.widthSeperator) + (score-numberOfStars) * starImage.size.width, 0);
    
    if(isAnimate)
    {
        __weak __typeof(self)weakSelf = self;
        
        [UIView animateWithDuration:0.2 animations:^
         {
             [weakSelf changeStarForegroundViewWithPoint:point];
             
         } completion:^(BOOL finished)
         {
             if (completion)
             {
                 completion(finished);
             }
         }];
    }
    else
    {
        [self changeStarForegroundViewWithPoint:point];
    }
}

#pragma mark -
#pragma mark - Touche Event
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    CGRect rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    if(CGRectContainsPoint(rect,point))
    {
        [self changeStarForegroundViewWithPoint:point];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    __weak __typeof(self)weakSelf = self;
    
    [UIView animateWithDuration:0.2 animations:^
     {
         [weakSelf changeStarForegroundViewWithPoint:point];
     }];
}

#pragma mark -
#pragma mark - Buidl Star View

/**
 *  通过图片构建星星视图
 *
 *  @param imageName 图片名称
 *
 *  @return 星星视图
 */
- (UIView *)buidlStarViewWithImageName:(NSString *)imageName
{
    CGRect frame = self.bounds;
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.clipsToBounds = YES;
    for (int i = 0; i < self.numberOfStar; i ++)
    {
        UIImage *starImage = [UIImage imageNamed:imageName];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:starImage];
        
        imageView.frame = CGRectMake(i*(self.widthSeperator+starImage.size.width),
                                     0,
                                     starImage.size.width,
                                     starImage.size.height);
        imageView.center = CGPointMake(imageView.center.x, frame.size.height / 2.0f);
        [view addSubview:imageView];
        imageView.tag = 100 + i;
    }
    return view;
}

#pragma mark -
#pragma mark - Change Star Foreground With Point

/**
 *  通过坐标改变前景视图
 *
 *  @param point 坐标
 */
- (void)changeStarForegroundViewWithPoint:(CGPoint)point
{
    CGPoint p = point;
    if (p.x < 0)
    {
        p.x = 0;
    }
    
    if (p.x > self.frame.size.width)
    {
        p.x = self.frame.size.width;
    }
    
    float score = 0.0f;
    for (int i = 0; i < [self.starBackgroundView.subviews count]; i++) {
        UIImageView *starImageView = (UIImageView *)[self.starBackgroundView viewWithTag:100+i];
        float left = starImageView.frame.origin.x;
        float right = starImageView.frame.origin.x + starImageView.frame.size.width;
        if (left <= point.x && point.x < right) {
            score = i + (point.x - starImageView.frame.origin.x) / starImageView.frame.size.width;
            break;
        }
        else if (point.x >= right) {
            if (i < [self.starBackgroundView.subviews count] - 1) {
                UIImageView *starImageView1 = (UIImageView *)[self.starBackgroundView viewWithTag:101+i];
                if (point.x < starImageView1.frame.origin.x) {
                    score = i + 1;
                    break;
                }
            }
            else {
                score = i + 1;
            }
        }
    }
    NSLog(@"score = %f", score);
    self.starForegroundView.frame = CGRectMake(0, 0, p.x, self.frame.size.height);
    if(self.delegate && [self.delegate respondsToSelector:@selector(starRatingView: score:)])
    {
        [self.delegate starRatingView:self score:score];
    }
}

@end

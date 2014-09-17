//
//  UIImage+Resizable.m
//  EmojiText
//
//  Created by Joey on 14-9-17.
//  Copyright (c) 2014年 JoeytatEmojiText. All rights reserved.
//

#import "UIImage+Resizable.h"

@implementation UIImage (Resizable)
- (UIImage *)imageScaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end

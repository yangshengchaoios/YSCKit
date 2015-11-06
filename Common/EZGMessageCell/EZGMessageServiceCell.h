//
//  EZGMessageServiceCell.h
//  EZGoal
//
//  Created by yangshengchao on 15/11/5.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "EZGMessageBaseCell.h"

//包括
//1.服务开始消息(成功发送位置信息后由B端自动发出)
//2.服务结束：正常结束后需要用户评价、取消服务的结束就直接关闭沟通功能
//3.服务过程中的特殊消息(如取消放弃救援...)
@interface EZGMessageServiceCell : EZGMessageBaseCell

@property (weak, nonatomic) IBOutlet UILabel *serviceTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *separationLineLabel;
@property (weak, nonatomic) IBOutlet UILabel *serviceDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *overLabel;        //服务结束标记

@end

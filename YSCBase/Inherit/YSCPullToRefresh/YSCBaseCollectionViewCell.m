//
//  YSCBaseCollectionViewCell.m
//  YSCKit
//
//  Created by Builder on 16/7/1.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "YSCBaseCollectionViewCell.h"

@implementation YSCBaseCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}
- (id)initWithCoder:(NSCoder*)aDecoder {
    if(self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}
- (void)setup {
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor whiteColor];
    self.contentView.backgroundColor = [UIColor whiteColor];
}

+ (void)registerCellToCollectionView:(UICollectionView *)collectionView {
    NSString *cellName = NSStringFromClass(self.class);
    if (IS_NIB_EXISTS(cellName)) {
        [collectionView registerNib:[UINib nibWithNibName:cellName bundle:nil]
        forCellWithReuseIdentifier:cellName];
    }
    else {
        [collectionView registerClass:self.class forCellWithReuseIdentifier:cellName];
    }
}
+ (instancetype)dequeueCellByCollectionView:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath {
    return [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(self.class) forIndexPath:indexPath];
}

+ (CGSize)sizeOfCellByObject:(NSObject *)object {
    return CGSizeMake(145, 145);
}
- (void)layoutObject:(NSObject *)object {}

- (UILabel *)textLabel {
    if ( ! _textLabel) {
        _textLabel = [[UILabel alloc] initWithFrame:self.contentView.bounds];
        _textLabel.backgroundColor = [UIColor whiteColor];
        _textLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:_textLabel];
    }
    return _textLabel;
}

@end

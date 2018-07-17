//
//  XMGridCollectionCell.m
//  XMGridMoveLayout
//
//  Created by 钱海超 on 2018/7/17.
//  Copyright © 2018年 北京大账房信息技术有限公司. All rights reserved.
//

#import "XMGridCollectionCell.h"
#import "XMGridModel.h"

@interface XMGridCollectionCell()
@property (weak, nonatomic) IBOutlet UILabel     *titleLbl;
@property (weak, nonatomic) IBOutlet UIButton    *operateBtn;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (nonatomic,weak)   NSIndexPath         *currentIndexPath;
@property (nonatomic,weak) NSArray               *groupArray;
@end

@implementation XMGridCollectionCell


#pragma mark - setter/getter方法
- (void)setIsEdit:(BOOL)isEdit
{
    self.operateBtn.hidden = !isEdit;
    if(isEdit && isEdit != _isEdit){
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = [UIColor grayColor].CGColor;
    }else{
        self.layer.borderColor = [UIColor clearColor].CGColor;
    }
    _isEdit = isEdit;
}

/**
 配置数据
 */
- (void)configureDataArray:(NSArray *)dataArray groupArray:(NSArray *)groupArray indexPath:(NSIndexPath *)indexPath
{
    XMGridModel *model = nil;
    if(indexPath.section == 0){
        model = dataArray[indexPath.row];
        self.titleLbl.text = model.title;
        self.imgView.image = [UIImage imageNamed:model.icon];
    }else{
        model = groupArray[indexPath.row];
        self.titleLbl.text = model.title;
        self.imgView.image = [UIImage imageNamed:model.icon];
    }
    if(indexPath.section == 0){
        [self.operateBtn setBackgroundImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    }else{
        [self.operateBtn setBackgroundImage:[UIImage imageNamed:model.allowDelete ? @"delete" : @"add"] forState:UIControlStateNormal];
    }

    self.groupArray = groupArray;

    self.currentIndexPath = indexPath;
}

#pragma mark - 事件监听
- (IBAction)operateBtnClick:(UIButton *)sender {
    if(self.currentIndexPath.section == 0 || [self.groupArray[self.currentIndexPath.item] allowDelete]){
        if(self.delegate && [self.delegate respondsToSelector:@selector(gridCollectionCell:deleteGridAtIndexPath:)]){
            [self.delegate gridCollectionCell:self deleteGridAtIndexPath:self.currentIndexPath];
        }
    }else{
        if(self.delegate && [self.delegate respondsToSelector:@selector(gridCollectionCell:addGridAtIndexPath:)]){
            [self.delegate gridCollectionCell:self addGridAtIndexPath:self.currentIndexPath];
        }
    }
}


@end

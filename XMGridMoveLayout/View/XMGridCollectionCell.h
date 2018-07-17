//
//  XMGridCollectionCell.h
//  XMGridMoveLayout
//
//  Created by 钱海超 on 2018/7/17.
//  Copyright © 2018年 北京大账房信息技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XMGridCollectionCell,XMGridModel;

@protocol XMGridCollectionCellDelegate <NSObject>

/**
 删除
 */
- (void)gridCollectionCell:(XMGridCollectionCell *)cell deleteGridAtIndexPath:(NSIndexPath *)indexPath;

/**
 新增
 */
- (void)gridCollectionCell:(XMGridCollectionCell *)cell addGridAtIndexPath:(NSIndexPath *)indexPath;
@end


@interface XMGridCollectionCell : UICollectionViewCell


@property (nonatomic,assign) BOOL       isEdit; //是否为编辑状态

@property (nonatomic,weak) id<XMGridCollectionCellDelegate> delegate;

/**
 配置数据
 */
- (void)configureDataArray:(NSArray *)dataArray groupArray:(NSArray *)groupArray indexPath:(NSIndexPath *)indexPath;


@end

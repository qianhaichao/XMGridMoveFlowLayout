//
//  XMGridMoveLayout.h
//  XMGridMoveLayout
//
//  Created by 钱海超 on 2018/7/17.
//  Copyright © 2018年 北京大账房信息技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XMGridMoveFlowLayoutDelegate<NSObject>


/**
 用于更改数据源通知
 */
- (void)gridMoveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;


/**
 改变编辑状态通知
 */
- (void)gridChangeEditState:(BOOL)isEdit;


@end

@interface XMGridMoveFlowLayout : UICollectionViewFlowLayout

@property (nonatomic,assign) BOOL       isEdit; //检测是否处于编辑状态
@property (nonatomic,weak) id<XMGridMoveFlowLayoutDelegate> delegate;

@end

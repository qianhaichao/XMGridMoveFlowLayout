//
//  XMGridMoveLayout.m
//  XMGridMoveLayout
//
//  Created by 钱海超 on 2018/7/17.
//  Copyright © 2018年 北京大账房信息技术有限公司. All rights reserved.
//

#import "XMGridMoveFlowLayout.h"
#import "XMGridCollectionCell.h"
#import "XMGridModel.h"

@interface XMGridMoveFlowLayout()<UIGestureRecognizerDelegate>
@property (nonatomic,strong) UILongPressGestureRecognizer       *longGesture;
@property (nonatomic,strong) NSIndexPath                        *currentIndexPath;
@property (nonatomic,strong) UIView                             *snapshotView;
@end

@implementation XMGridMoveFlowLayout

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        //添加监听者
        [self configureObserver];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //添加监听者
        [self configureObserver];
    }
    return self;
}

#pragma mark - 添加监听者
- (void)configureObserver{
    [self addObserver:self forKeyPath:@"collectionView" options:NSKeyValueObservingOptionNew context:nil];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if([keyPath isEqualToString:@"collectionView"]){
        [self setUpGestureRecognizers];
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - 事件监听
- (void)longGesture:(UILongPressGestureRecognizer *)gesture
{
    if(!self.isEdit){
        self.isEdit = YES;
    }
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: //手势开始
            {
                CGPoint loc = [gesture locationInView:self.collectionView];
                //找到当前点击的cell位置
                NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:loc];
                //判断哪个分区可以被点击并且移动
                if(!indexPath || indexPath.section != 0) return;
                self.currentIndexPath = indexPath;

                UICollectionViewCell *targetCell = [self.collectionView cellForItemAtIndexPath:self.currentIndexPath];
                //得到当前cell的映射(截图)
                self.snapshotView = [targetCell snapshotViewAfterScreenUpdates:YES];
                //隐藏被点击的cell
                targetCell.hidden = YES;
                //给截图添加上边框，如果不添加的话，截图有一部分是没有边框的，具体原因也没有找到
                self.snapshotView.layer.borderWidth = 0.5;
                self.snapshotView.layer.borderColor = [UIColor grayColor].CGColor;
                [self.collectionView addSubview:self.snapshotView];
                //放大截图
                self.snapshotView.transform = CGAffineTransformMakeScale(1.1, 1.1);
                self.snapshotView.center = targetCell.center;
            }
            break;
        case UIGestureRecognizerStateChanged: //手势在变化
        {
            CGPoint loc = [gesture locationInView:self.collectionView];
            //更新截图的位置
            self.snapshotView.center = loc;
            NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:loc];
            if(!indexPath) return;
            if(indexPath.section == self.currentIndexPath.section && indexPath.section == 0){
                //通过代理通知改变数据源
                if(self.delegate && [self.delegate respondsToSelector:@selector(gridMoveItemAtIndexPath:toIndexPath:)]){
                    [self.delegate gridMoveItemAtIndexPath:self.currentIndexPath toIndexPath:indexPath];
                }
                //移动方法
                [self.collectionView moveItemAtIndexPath:self.currentIndexPath toIndexPath:indexPath];
                self.currentIndexPath = indexPath;
            }

        }
            break;
        case UIGestureRecognizerStateEnded: //手势结束
        {
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:self.currentIndexPath];
            //手势结束后，把截图隐藏，显示出原先的cell
            [UIView animateWithDuration:0.25 animations:^{
                self.snapshotView.center = cell.center;
            } completion:^(BOOL finished) {
                [self.snapshotView removeFromSuperview];
                cell.hidden = NO;
                self.snapshotView = nil;
                self.currentIndexPath = nil;
                [self.collectionView reloadData];
            }];
        }
            break;

        default:
            break;
    }
}
#pragma mark - setter/getter方法
- (void)setIsEdit:(BOOL)isEdit
{
    if(_isEdit != isEdit){
        if(self.delegate && [self.delegate respondsToSelector:@selector(gridChangeEditState:)])
        [self.delegate gridChangeEditState:isEdit];
    }
    _isEdit = isEdit;

}

#pragma mark - 私有方法
- (void)setUpGestureRecognizers
{
    if(!self.collectionView) return;
    _longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGesture:)];
    _longGesture.minimumPressDuration = 0.3f; //时间长短
    _longGesture.delegate = self;
    [self.collectionView addGestureRecognizer:_longGesture];
    
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"collectionView"];
}

@end

//
//  XMGridViewController.m
//  XMGridMoveLayout
//
//  Created by 钱海超 on 2018/7/17.
//  Copyright © 2018年 北京大账房信息技术有限公司. All rights reserved.
//

#import "XMGridViewController.h"
#import "XMGridMoveFlowLayout.h"
#import "XMGridSectionHeaderView.h"
#import "XMGridCollectionCell.h"
#import "XMGridModel.h"

static NSString *XMGridCollectionCellIde = @"XMGridCollectionCell";
static NSString *XMGridSectionHeaderViewIde = @"XMGridSectionHeaderView";
@interface XMGridViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,XMGridMoveFlowLayoutDelegate,XMGridCollectionCellDelegate>
@property (nonatomic,strong) UICollectionView           *collectionView;
@property (nonatomic,strong) XMGridMoveFlowLayout       *flowlayout;
@property (nonatomic,strong) NSMutableArray             *dataArray;
@property (nonatomic,strong) NSMutableArray             *groupArray;
@property (nonatomic,assign) BOOL                        isEdit;

@property (nonatomic,strong) UIButton       *rightBtn; //导航条右侧按钮

@end

@implementation XMGridViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //初始化数据源
    [self initialDataSource];

    //创建UI
    [self layoutUI];
}

#pragma mark - 初始化数据源
- (void)initialDataSource
{

    self.dataArray = [NSMutableArray arrayWithCapacity:1];
    self.groupArray = [NSMutableArray arrayWithCapacity:1];

    NSArray *groupImgs =   @[@"office_qd",@"office_gzrb",@"office_nbtz",@"office_zljj",@"office_sp",@"office_khbf",@"office_cwcl",@"office_rw",@"office_khgl",@"office_httj",@"office_htmx",@"office_dsdj",@"office_sfgl",@"office_zzjd",@"office_jzgzl",@"office_khpzl",@"office_qktj",@"office_qzkh"];
    NSArray *groupTitles = @[@"签到",@"工作日报",@"内部通知",@"资料交接",@"收票",@"客户拜访",@"财务处理",@"任务",@"客户管理",@"合同统计",@"合同明细",@"代收代缴",@"收费管理",@"做账进度",@"记账工作量",@"客户凭证量",@"欠款统计",@"潜在客户"];

    for (int i=0; i<4; i++) {
        XMGridModel *model = [[XMGridModel alloc] init];
        model.icon = groupImgs[i];
        model.title = groupTitles[i];
        [self.dataArray addObject:model];
    }

    for (int i=0; i<groupImgs.count; i++) {
        XMGridModel *model = [[XMGridModel alloc] init];
        model.icon = groupImgs[i];
        model.title = groupTitles[i];
        [self.groupArray addObject:model];
    }

    //过滤底部数据源和全部数据源的公共部分
    NSArray *filterArr =  [self.groupArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.title in %@",[self.dataArray valueForKeyPath:@"title"]]];

    [filterArr setValue:@(YES) forKeyPath:@"allowDelete"];
}

#pragma mark - 创建UI
- (void)layoutUI
{
    [self.view addSubview:self.collectionView];

    //添加右边的编辑按钮
    [self addRightBarButtonItem];
}

#pragma mark - 似有方法
/**
 * 添加右边的编辑按钮
 */
- (void)addRightBarButtonItem
{
    self.rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_rightBtn setTitle:@"管理" forState:UIControlStateNormal];
    [_rightBtn addTarget:self action:@selector(rightBarButtonItemAction:) forControlEvents:UIControlEventTouchUpInside];
    [_rightBtn sizeToFit];
    [_rightBtn setTitle:@"完成" forState:UIControlStateSelected];
    [_rightBtn setTitle:@"管理" forState:UIControlStateNormal];
    [_rightBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    _rightBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    //将leftItem设置为自定义按钮
    UIBarButtonItem *rightItem =[[UIBarButtonItem alloc] initWithCustomView: _rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
}

#pragma mark - 事件监听
- (void)rightBarButtonItemAction:(UIButton *)sender
{
    if(self.isEdit){
        //此处可以调用网络请求，把排序完之后的传给服务端
        NSLog(@"点击了完成按钮");
    }

    self.isEdit = ! self.isEdit;
    self.collectionView.allowsSelection = self.isEdit;

    self.flowlayout.isEdit = self.isEdit;

}

#pragma mark - UICollectionViewDelegate和UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return section == 0 ? self.dataArray.count : self.groupArray.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    XMGridCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:XMGridCollectionCellIde forIndexPath:indexPath];
    //绑定数据
    [cell configureDataArray:self.dataArray groupArray:self.groupArray indexPath:indexPath];
    //编辑状态
    cell.isEdit = self.isEdit;
    //设置代理
    cell.delegate = self;
    return cell;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if([kind isEqualToString:UICollectionElementKindSectionHeader]){
        XMGridSectionHeaderView *sectionHeadView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:XMGridSectionHeaderViewIde forIndexPath:indexPath];
        sectionHeadView.titleLbl.text = indexPath.section ? @"全部功能" : @"便捷标签";
        return sectionHeadView;
    }
    return nil;
}

#pragma mark - XMGridMoveFlowLayoutDelegate
//移动改变数据源
- (void)gridMoveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    XMGridModel *model = self.dataArray[fromIndexPath.item];
    //先把这个model移除
    [self.dataArray removeObject:model];
    //在把它插入到相应的位置
    [self.dataArray insertObject:model atIndex:toIndexPath.item];
}

- (void)gridChangeEditState:(BOOL)isEdit
{
    self.isEdit = isEdit;
    self.rightBtn.selected = isEdit;
    for (XMGridCollectionCell *cell in self.collectionView.visibleCells) {
        cell.isEdit = isEdit;
    }
}

#pragma mark - XMGridCollectionCellDelegate
- (void)gridCollectionCell:(XMGridCollectionCell *)cell deleteGridAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        XMGridModel *model = self.dataArray[indexPath.item];
        XMGridModel *groupM = [self.groupArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"title = %@",model.title]].firstObject;
        groupM.allowDelete = NO;
        [self.dataArray removeObjectAtIndex:indexPath.item];
    }else{
        XMGridModel *model = self.groupArray[indexPath.item];
        model.allowDelete = NO;
        XMGridModel *dataM = [self.dataArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"title = %@",model.title]].firstObject;
        [self.dataArray removeObject:dataM];
    }
    [self.collectionView reloadData];
}

- (void)gridCollectionCell:(XMGridCollectionCell *)cell addGridAtIndexPath:(NSIndexPath *)indexPath
{
    XMGridModel *model = self.groupArray[indexPath.item];
    [self.dataArray addObject:model];
    model.allowDelete = YES;
    [self.collectionView reloadData];
}

#pragma mark - 懒加载
- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) collectionViewLayout:self.flowlayout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        //给集合视图注册一个cell
        [_collectionView registerNib:[UINib nibWithNibName:@"XMGridCollectionCell" bundle:nil] forCellWithReuseIdentifier:XMGridCollectionCellIde];
        //注册一个区头视图
        [_collectionView registerNib:[UINib nibWithNibName:@"XMGridSectionHeaderView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:XMGridSectionHeaderViewIde];
    }
    return _collectionView;
}
- (XMGridMoveFlowLayout *)flowlayout
{
    if(!_flowlayout){
        _flowlayout = [[XMGridMoveFlowLayout alloc] init];
        CGFloat width = (UIScreen.mainScreen.bounds.size.width - 80) / 4;
        _flowlayout.delegate = self;
        //设置每个图片的大小
        _flowlayout.itemSize = CGSizeMake(width, width);
        //设置滚动方向的间距
        _flowlayout.minimumLineSpacing = 10;
        //设置上方的反方向
        _flowlayout.minimumInteritemSpacing = 0;
        //设置collectionView整体的上下左右之间的间距
        _flowlayout.sectionInset = UIEdgeInsetsMake(15, 20, 20, 20);
        _flowlayout.headerReferenceSize = CGSizeMake(UIScreen.mainScreen.bounds.size.width, 30);
        //设置滚动方向
        _flowlayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    return _flowlayout;
}

@end

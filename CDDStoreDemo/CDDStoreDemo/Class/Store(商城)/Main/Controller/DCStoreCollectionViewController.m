//
//  DCStoreCollectionViewController.m
//  CDDStoreDemo
//
//  Created by apple on 2017/4/20.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "DCStoreCollectionViewController.h"
#import "DCCustomViewController.h"
#import "DCWebViewController.h"
#import "DCStoreDetailViewController.h"

#import "DCStoreItem.h"
#import "DCStoreCollectionViewCell.h"

#import "DCConsts.h"
#import "DCSpeedy.h"
#import "DCCustomButton.h"
#import "UIView+DCExtension.h"
#import "XWDrawerAnimator.h"
#import "UIViewController+XWTransition.h"

#import <Masonry.h>
#import <MJRefresh.h>
#import <MJExtension.h>
#import <SVProgressHUD.h>
#import <SDCycleScrollView.h>
#import <TXScrollLabelView.h>

@interface DCStoreCollectionViewController()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
/* 数据 */
@property (strong , nonatomic)NSMutableArray<DCStoreItem *> *storeItem;

/* 视图状态 */
@property (nonatomic, assign) BOOL isGrid;

@end


static NSString *DCStoreCollectionViewCellID = @"DCStoreCollectionViewCell";

@implementation DCStoreCollectionViewController

#pragma mark - 懒加载
- (UICollectionView *)collectionView
{
    if (!_collectionView)
    {
        UICollectionViewFlowLayout *flowlayout = [[UICollectionViewFlowLayout alloc] init];
        //设置滚动方向
        [flowlayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        //上下左右间距
        flowlayout.minimumInteritemSpacing = 2;
        flowlayout.minimumLineSpacing = 2;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(2 , 2 + 50, ScreenW - 4, ScreenH - 4) collectionViewLayout:flowlayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView setBackgroundColor:[UIColor clearColor]];
        //注册cell
        [_collectionView registerClass:[DCStoreCollectionViewCell class] forCellWithReuseIdentifier:DCStoreCollectionViewCellID];
    
    }
    return _collectionView;
}

#pragma mark - 初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpTab];
    
    [self loadStoreDatas];
    
    [self setUpSeachPhoneView:self.view];
}

#pragma mark - 搜索
- (void)setUpSeachPhoneView:(UIView *)view
{
    UIView *seachPhoneView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, ScreenW, 50)];
    seachPhoneView.backgroundColor = [UIColor whiteColor];
    
    UILabel *showNum_Label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, ScreenW * 0.4, 50)];
    [seachPhoneView addSubview:showNum_Label];
    NSString *shopCount = [NSString stringWithFormat:@"%zd",_storeItem.count];
    showNum_Label.text = [NSString stringWithFormat:@"共筛选出 %@ 件商品",shopCount];
    showNum_Label.font = [UIFont systemFontOfSize:12];
    
    [DCSpeedy setSomeOneChangeColor:showNum_Label SetSelectArray:@[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"] SetChangeColor:[UIColor orangeColor]];
    
    DCCustomButton *customButton = [DCCustomButton buttonWithType:UIButtonTypeCustom];
    customButton.frame = CGRectMake(ScreenW - 70, 0 , 60 , 50);
    [customButton setTitle:@"筛选" forState:UIControlStateNormal];
    [customButton setImage:[UIImage imageNamed:@"custom"] forState:UIControlStateNormal];
    customButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [customButton addTarget:self action:@selector(customButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [seachPhoneView addSubview:customButton];
    
    UIButton *swithBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [swithBtn addTarget:self action:@selector(garidButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [swithBtn setImage:[UIImage imageNamed:@"product_list_list_btn"] forState:UIControlStateNormal];
    
    swithBtn.frame = CGRectMake(ScreenW - 120, 0, 50, 50);
    
    [seachPhoneView addSubview:swithBtn];
    
    [view addSubview:seachPhoneView];
}

#pragma mark - 筛选点击
- (void)customButtonClick
{
    XWDrawerAnimatorDirection direction = XWDrawerAnimatorDirectionRight;
    CGFloat distance = ScreenW * 0.8; //分享窗口宽度
    XWDrawerAnimator *animator = [XWDrawerAnimator xw_animatorWithDirection:direction moveDistance:distance];
    animator.toDuration = 0.5;
    animator.backDuration = 0.5;
    animator.parallaxEnable = YES;
    //点击当前界面返回
    DCCustomViewController *shopsCustomVc = [[DCCustomViewController alloc] init];
    shopsCustomVc.sureButtonClickBlock = ^(NSString *attributeViewBrandString,NSString * attributeViewSortString){
        
        NSLog(@"刷选回调 选择的品牌：%@   展示方式：%@",attributeViewBrandString,attributeViewSortString);
    };
    
    [self xw_presentViewController:shopsCustomVc withAnimator:animator];
    __weak typeof(self)weakSelf = self;
    [animator xw_enableEdgeGestureAndBackTapWithConfig:^{
        [weakSelf selfAlterViewback];
    }];
    
}

#pragma 退出界面
- (void)selfAlterViewback{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)garidButtonClick:(UIButton *)btn
{
    _isGrid = !_isGrid;
    [self.collectionView reloadData];
    
    if (_isGrid) {
        [btn setImage:[UIImage imageNamed:@"product_list_grid_btn"] forState:0];
    } else {
        [btn setImage:[UIImage imageNamed:@"product_list_list_btn"] forState:0];
    }
}


- (void)loadStoreDatas
{
    NSArray *storeArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"MallShops.plist" ofType:nil]];
    _storeItem = [DCStoreItem mj_objectArrayWithKeyValuesArray:storeArray];
    
    [self.collectionView reloadData];
}

- (void)setUpTab
{
    self.title = @"商城";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.collectionView];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _storeItem.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DCStoreCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DCStoreCollectionViewCellID forIndexPath:indexPath];
    cell.isGrid = _isGrid;
    cell.storeItem = _storeItem[indexPath.row];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isGrid) {
        return CGSizeMake((ScreenW - 6) / 2, _storeItem[indexPath.row].isGardHeight);
    } else {
        return CGSizeMake(ScreenW - 4, _storeItem[indexPath.row].isCellHeight);
    }
    
//    if (_isGrid) {
//        return CGSizeMake((ScreenW - 6) / 2, (ScreenW - 6) / 2 + 40);
//    } else {
//        return CGSizeMake(ScreenW - 4, (ScreenW - 6) / 4 + 20);
//    }
}

@end

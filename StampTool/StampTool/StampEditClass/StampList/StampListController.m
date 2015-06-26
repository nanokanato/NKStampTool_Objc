//
//  StampToolListController.m
//  StampTool
//
//  Created by t-tazoe on 2015/06/09.
//  Copyright (c) 2015年 t-tazoe. All rights reserved.
//

#import "StampListController.h"
#import "CollectionCell.h"
#import "NewFlowLayout.h"

@interface StampListController () <UICollectionViewDataSource,UICollectionViewDelegate>
@end

/*========================================================
 ; StampListController
 ========================================================*/
@implementation StampListController

/*--------------------------------------------------------
 ; dealloc : 解放
 ;      in :
 ;     out :
 --------------------------------------------------------*/
-(void)dealloc
{
    
}

/*--------------------------------------------------------
 ; viewWillAppear : 画面が開かれる直前
 ;             in : (BOOL)animated
 ;            out :
 --------------------------------------------------------*/
-(void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [super viewWillAppear:animated];
}

/*--------------------------------------------------------
 ; viewDidLoad : UIViewが初回読み込まれた時
 ;          in :
 ;         out :
 --------------------------------------------------------*/
-(void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor colorWithRed:((0xF3F3F3>>16)&0xFF)/255.0 green:((0xF3F3F3>>8)&0xFF)/255.0 blue:(0xF3F3F3&0xFF)/255.0 alpha:1.0];
    
    //ヘッダー
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 45)];
    headerView.backgroundColor = [UIColor colorWithRed:((0xFBFBFB>>16)&0xFF)/255.0 green:((0xFBFBFB>>8)&0xFF)/255.0 blue:(0xFBFBFB&0xFF)/255.0 alpha:1.0];
    [self.view addSubview:headerView];
    UIView *headerLine = [[UIView alloc] initWithFrame:CGRectMake(0, headerView.frame.size.height-1, self.view.frame.size.width, 1)];
    headerLine.backgroundColor = [UIColor colorWithRed:((0xE9E9E9>>16)&0xFF)/255.0 green:((0xE9E9E9>>8)&0xFF)/255.0 blue:(0xE9E9E9&0xFF)/255.0 alpha:1.0];
    [headerView addSubview:headerLine];
    
    //タイトル
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 12, headerView.frame.size.width, headerView.frame.size.height-12)];
    titleLabel.font = [UIFont fontWithName:@"AlNile-Bold" size:18];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"スタンプ";
    titleLabel.textColor = [UIColor colorWithRed:((0x737373>>16)&0xFF)/255.0 green:((0x737373>>8)&0xFF)/255.0 blue:(0x737373&0xFF)/255.0 alpha:1.0];
    [headerView addSubview:titleLabel];
    
    //閉じるボタン
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(6, 4, 38, 38);
    [closeButton setTitle:@"×" forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [closeButton addTarget:self action:@selector(closeButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:closeButton];
    
    //スタンプ一覧
    NewFlowLayout *layout = [[NewFlowLayout alloc] init];
    [layout setItemSize:CGSizeMake(100, 80)];
    [layout setMinimumLineSpacing:1.0f];
    [layout setMinimumInteritemSpacing:1.0f];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, headerView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-headerView.frame.size.height)
                                                          collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor clearColor];
    [collectionView registerClass:[CollectionCell class] forCellWithReuseIdentifier:@ "CollectionCell"];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [self.view addSubview:collectionView];
}

/*--------------------------------------------------------
 ; closeButtonTaped : 閉じるボタンが押された
 ;               in : (UIButton *)button
 ;              out :
 --------------------------------------------------------*/
-(void)closeButtonTaped:(UIButton *)button
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*--------------------------------------------------------
 ; numberOfItemsInSection : UICollectionViewのアイテム数を返す
 ;                     in : (UICollectionView *)collectionView
 ;                        : (NSInteger)section
 ;                    out : (NSInteger)num
 --------------------------------------------------------*/
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 14;
}

/*--------------------------------------------------------
 ; cellForItemAtIndexPath : UICollectionViewのセルを返す
 ;                     in : (UICollectionView *)collectionView
 ;                        : (NSIndexPath *)indexPath
 ;                    out : (UICollectionViewCell *)cell
 --------------------------------------------------------*/
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@ "CollectionCell"
                                                                     forIndexPath:indexPath];
    NSString *fileName;
    if(indexPath.item < 4){
        fileName = [NSString stringWithFormat:@"stamp_%d_%d",1,(int)indexPath.item+1];
    }else if(indexPath.item < 7){
        fileName = [NSString stringWithFormat:@"stamp_%d_%d",2,(int)indexPath.item-3];
    }else{
        fileName = [NSString stringWithFormat:@"stamp_%d_%d",3,(int)indexPath.item-6];
    }
    cell.image = [UIImage imageNamed:fileName];
    return cell;
}

/*--------------------------------------------------------
 ; didSelectItemAtIndexPath : UICollectionViewのセルが押された
 ;                       in : (UICollectionView *)collectionView
 ;                          : (NSIndexPath *)indexPath
 ;                      out :
 --------------------------------------------------------*/
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *fileName;
    if(indexPath.item < 4){
        fileName = [NSString stringWithFormat:@"stamp_%d_%d",1,(int)indexPath.item+1];
    }else if(indexPath.item < 7){
        fileName = [NSString stringWithFormat:@"stamp_%d_%d",2,(int)indexPath.item-3];
    }else{
        fileName = [NSString stringWithFormat:@"stamp_%d_%d",3,(int)indexPath.item-6];
    }
    [self.delegate didSelectStampImage:[UIImage imageNamed:fileName]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
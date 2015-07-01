//
//  ShareController.m
//  NKStampTool
//
//  Created by nanoka____ on 2015/06/09.
//  Copyright (c) 2015年 nanoka____. All rights reserved.
//

#import "ShareController.h"

/*========================================================
 ; ShareController
 ========================================================*/
@implementation ShareController{
    UIImage *shareImage;
}

/*--------------------------------------------------------
 ; dealloc : 解放
 ;      in :
 ;     out :
 --------------------------------------------------------*/
-(void)dealloc
{
    
}

/*--------------------------------------------------------
 ; initWithShareImage : インスタンスの生成
 ;                 in : (UIImage *)image
 ;                out : (instancetype)self
 --------------------------------------------------------*/
-(instancetype)initWithShareImage:(UIImage *)image
{
    self = [super init];
    if(self){
        shareImage = image;
    }
    return self;
}

/*--------------------------------------------------------
 ; viewWillAppear : 画面が開かれる直前
 ;             in : (BOOL)animated
 ;            out :
 --------------------------------------------------------*/
-(void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
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
    
    /*----------------
     ヘッダー
     ----------------*/
    //ヘッダー
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 66)];
    headerView.backgroundColor = [UIColor colorWithRed:((0xFBFBFB>>16)&0xFF)/255.0 green:((0xFBFBFB>>8)&0xFF)/255.0 blue:(0xFBFBFB&0xFF)/255.0 alpha:1.0];
    [self.view addSubview:headerView];
    UIView *headerLine = [[UIView alloc] initWithFrame:CGRectMake(0, headerView.frame.size.height-1, self.view.frame.size.width, 1)];
    headerLine.backgroundColor = [UIColor colorWithRed:((0xE9E9E9>>16)&0xFF)/255.0 green:((0xE9E9E9>>8)&0xFF)/255.0 blue:(0xE9E9E9&0xFF)/255.0 alpha:1.0];
    [headerView addSubview:headerLine];
    
    //タイトル
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height+28,
                                                                    headerView.frame.size.width, headerView.frame.size.height-[UIApplication sharedApplication].statusBarFrame.size.height-28)];
    titleLabel.font = [UIFont fontWithName:@"AlNile-Bold" size:18];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"完成画像";
    titleLabel.textColor = [UIColor colorWithRed:((0x737373>>16)&0xFF)/255.0 green:((0x737373>>8)&0xFF)/255.0 blue:(0x737373&0xFF)/255.0 alpha:1.0];
    [headerView addSubview:titleLabel];
    
    //閉じるボタン
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(10, 24, 38, 38);
    [closeButton setTitle:@"←" forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [closeButton addTarget:self action:@selector(closeButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:closeButton];
    
    //シェア画像
    UIImageView *shareImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, headerView.frame.size.height+10,
                                                                                self.view.frame.size.width-10*2,
                                                                                self.view.frame.size.height-headerView.frame.size.height-10*2)];
    shareImageView.contentMode = UIViewContentModeScaleAspectFit;
    shareImageView.image = shareImage;
    [self.view addSubview:shareImageView];
}

/*--------------------------------------------------------
 ; closeButtonTaped : 閉じるボタンが押された
 ;               in : (UIButton *)button
 ;              out :
 --------------------------------------------------------*/
-(void)closeButtonTaped:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
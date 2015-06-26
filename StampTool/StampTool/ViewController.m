//
//  ViewController.m
//  StampTool
//
//  Created by t-tazoe on 2015/06/08.
//  Copyright (c) 2015年 t-tazoe. All rights reserved.
//

#import "ViewController.h"
#import "EditController.h"

@interface ViewController () <UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@end

/*========================================================
 ; ViewController
 ========================================================*/
@implementation ViewController

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
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 100, 50);
    button.center = self.view.center;
    [button setTitle:@"アルバム" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(buttonTaped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

/*--------------------------------------------------------
 ; buttonTaped : ボタンが押された
 ;          in : (UIButton *)button
 ;         out :
 --------------------------------------------------------*/
-(void)buttonTaped:(UIButton *)button
{
    // インタフェース使用可能なら
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] ) {
        // UIImageControllerの初期化
        UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
        ipc.delegate = self;
        ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        ipc.allowsEditing = NO;
        [self presentViewController:ipc animated:YES completion:nil];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You can not use the PhotoLibrary"
                                                        message:@"フォトライブラリが使用できません。"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

/*========================================================
 ; UIImagePickerControllerDelegate
 ========================================================*/
/*--------------------------------------------------------
 ; didFinishPickingMediaWithInfo : ライブラリの画像が選択された
 ;                            in : (UIImagePickerController *)picker
 ;                               : (NSDictionary *)info
 ;                           out :
 --------------------------------------------------------*/
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // 選択したイメージをimageにセットする
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:^(void){
        //加工画面へ
        EditController *oEditController = [[EditController alloc] initWithBackgroundImage:image];
        [self.navigationController pushViewController:oEditController animated:YES];
    }];
}

/*--------------------------------------------------------
 ; imagePickerControllerDidCancel : ライブラリのキャンセルボタンが押された
 ;                             in : (UIImagePickerController *)picker
 ;                            out :
 --------------------------------------------------------*/
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    // フォトライブラリを閉じる
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

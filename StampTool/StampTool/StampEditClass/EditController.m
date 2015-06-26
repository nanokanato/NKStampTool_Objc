//
//  EditController.m
//  StampTool
//
//  Created by t-tazoe on 2015/06/08.
//  Copyright (c) 2015年 t-tazoe. All rights reserved.
//

#import "EditController.h"
#import "StampListController.h"
#import "ShareController.h"
#import "StampView.h"
#import "UIImage+Resize.h"
#import "UIImage+Transform.h"

#define __DELETE_LONGPRESS_ALERT 9999

@interface EditController () <StampListControllerDelegate,StampViewDelegate>
@end

/*========================================================
 ; EditController
 ========================================================*/
@implementation EditController{
    UIImageView *canvasView;
    UIImage *backgroundImage;
    UIButton *addStampButton;
    UIButton *closeButton;
    UIButton *deleteButton;
    UIButton *saveButton;
    UIButton *detailButton;
    UIView *detailView;
    UIButton *detailCloseButton;
    UIButton *detailResetButton;
    UIButton *detailReverseButton;
    UISlider *alphaSlider;
    UISlider *brightnessSlider;
    UISlider *saturationSlider;
    UISlider *hueSlider;
    UIButton *layerButton;
    UIView *moLayerView;
    UIButton *layerUpButton;
    UIButton *layerDownButton;
    StampView *selectStamp;
    BOOL deleteLongPressFlag;
}

/*--------------------------------------------------------
 ; dealloc : 解放
 ;      in :
 ;     out :
 --------------------------------------------------------*/
-(void)dealloc
{
    canvasView = nil;
    backgroundImage = nil;
    addStampButton = nil;
    deleteButton = nil;
    saveButton = nil;
    closeButton = nil;
    detailButton = nil;
    detailView = nil;
    detailCloseButton = nil;
    detailResetButton = nil;
    detailReverseButton = nil;
    alphaSlider = nil;
    brightnessSlider = nil;
    saturationSlider = nil;
    hueSlider = nil;
    layerButton = nil;
    moLayerView = nil;
    layerUpButton = nil;
    layerDownButton = nil;
    selectStamp = nil;
}

/*--------------------------------------------------------
 ; initWithBackgroundImage : インスタンスの生成
 ;                      in : (UIImage *)image
 ;                     out : (instancetype)self
 --------------------------------------------------------*/
-(instancetype)initWithBackgroundImage:(UIImage *)image
{
    self = [super init];
    if(self){
        backgroundImage = image;
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
    
    /*----------------
     キャンバスの作成
     ----------------*/
    //キャンバス
    float margin,width,height;
    margin = 10;
    if(backgroundImage.size.width > backgroundImage.size.height){
        width = self.view.frame.size.width-margin*2;
        height = (width*backgroundImage.size.height)/backgroundImage.size.width;
        if(height > self.view.frame.size.height-margin*2){
            width = ((self.view.frame.size.height-margin*2)*width)/height;
            height = self.view.frame.size.height-margin*2;
        }
    }else{
        height = self.view.frame.size.height-50-margin*2;
        width = (height*backgroundImage.size.width)/backgroundImage.size.height;
        if(width > self.view.frame.size.width-margin*2){
            height = ((self.view.frame.size.width-margin*2)*height)/width;
            width = self.view.frame.size.width-margin*2;
        }
    }
    
    canvasView = [[UIImageView alloc] initWithFrame:CGRectMake(margin+((self.view.frame.size.width-margin*2)-width)/2,
                                                               margin+((self.view.frame.size.height-50-margin*2)-height)/2, width, height)];
    canvasView.image = backgroundImage;
    canvasView.backgroundColor = [UIColor clearColor];
    canvasView.userInteractionEnabled = YES;
    [self.view addSubview:canvasView];
    
    /*----------------
     キャンバス上のツール
     ----------------*/
    //閉じるボタン
    closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(8, 8, 31, 31);
    [closeButton setTitle:@"×" forState:UIControlStateNormal];
    closeButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    closeButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
    closeButton.layer.borderWidth = 1.0;
    [closeButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [closeButton addTarget:self action:@selector(closeButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    
    //詳細ボタン
    detailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    detailButton.frame = CGRectMake(self.view.frame.size.width-8-60, (self.view.frame.size.height-50)-8-31, 60, 31);
    [detailButton setTitle:@"詳細" forState:UIControlStateNormal];
    detailButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    detailButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
    detailButton.layer.borderWidth = 1.0;
    [detailButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [detailButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [detailButton addTarget:self action:@selector(detailButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    detailButton.alpha = 0.0;
    [self.view addSubview:detailButton];
    
    //階層変更ボタン
    layerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    layerButton.frame = CGRectMake(8, (self.view.frame.size.height-50)-8-31, 44, 31);
    [layerButton setTitle:@"階層" forState:UIControlStateNormal];
    layerButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    layerButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
    layerButton.layer.borderWidth = 1.0;
    [layerButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [layerButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [layerButton addTarget:self action:@selector(layerButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    layerButton.alpha = 0.0;
    [self.view addSubview:layerButton];
    
    //階層ビュー
    moLayerView = [[UIView alloc] initWithFrame:CGRectMake(8, layerButton.frame.origin.y-3-75, layerButton.frame.size.width, 75)];
    moLayerView.backgroundColor = [UIColor clearColor];
    moLayerView.alpha = 0.0;
    [self.view addSubview:moLayerView];
    
    //階層アップボタン
    layerUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    layerUpButton.frame = CGRectMake(0, 0.5, moLayerView.frame.size.width, moLayerView.frame.size.height/2);
    [layerUpButton setTitle:@"↑" forState:UIControlStateNormal];
    layerUpButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    layerUpButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
    layerUpButton.layer.borderWidth = 1.0;
    [layerUpButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [layerUpButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [layerUpButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [layerUpButton addTarget:self action:@selector(layerUpButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    [moLayerView addSubview:layerUpButton];
    
    //階層ダウンボタン
    layerDownButton = [UIButton buttonWithType:UIButtonTypeCustom];
    layerDownButton.frame = CGRectMake(0, moLayerView.frame.size.height/2-0.5, moLayerView.frame.size.width, moLayerView.frame.size.height/2);
    [layerDownButton setTitle:@"↓" forState:UIControlStateNormal];
    layerDownButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    layerDownButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
    layerDownButton.layer.borderWidth = 1.0;
    [layerDownButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [layerDownButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [layerDownButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [layerDownButton addTarget:self action:@selector(layerDownButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    [moLayerView addSubview:layerDownButton];
    
    /*----------------
     詳細ビュー
     ----------------*/
    //詳細ビュー
    detailView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-50, self.view.frame.size.width, 150)];
    detailView.backgroundColor = [UIColor clearColor];
    detailView.alpha = 0.0;
    [self.view addSubview:detailView];
    //詳細画面
    UIView *detailArea = [[UIView alloc] initWithFrame:CGRectMake(0, 35, detailView.frame.size.width, detailView.frame.size.height-35)];
    detailArea.backgroundColor = [UIColor whiteColor];
    [detailView addSubview:detailArea];
    //境界線
    UIView *detailLine = [[UIView alloc] initWithFrame:CGRectMake(0, detailArea.frame.size.height-1, detailArea.frame.size.width, 1)];
    detailLine.backgroundColor = [UIColor colorWithRed:((0xF3F3F3>>16)&0xFF)/255.0 green:((0xF3F3F3>>8)&0xFF)/255.0 blue:(0xF3F3F3&0xFF)/255.0 alpha:1.0];
    [detailArea addSubview:detailLine];
    //閉じるボタン
    detailCloseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    detailCloseButton.frame = CGRectMake(detailView.frame.size.width-60, 0, 60, 35);
    detailCloseButton.backgroundColor = [UIColor whiteColor];
    [detailCloseButton setTitle:@"×" forState:UIControlStateNormal];
    [detailCloseButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [detailCloseButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [detailCloseButton addTarget:self action:@selector(detailCloseButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    [detailView addSubview:detailCloseButton];
    //リセットボタン
    detailResetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    detailResetButton.frame = CGRectMake(5, 0, 80, 30);
    [detailResetButton setTitle:@"リセット" forState:UIControlStateNormal];
    detailResetButton.backgroundColor = [UIColor whiteColor];
    [detailResetButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [detailResetButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [detailResetButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [detailResetButton addTarget:self action:@selector(detailResetButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    [detailView addSubview:detailResetButton];
    //反転ボタン
    detailReverseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    detailReverseButton.frame = CGRectMake(detailResetButton.frame.origin.x*2+detailResetButton.frame.size.width, 0, 60, 30);
    [detailReverseButton setTitle:@"反転" forState:UIControlStateNormal];
    detailReverseButton.backgroundColor = [UIColor whiteColor];
    [detailReverseButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [detailReverseButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [detailReverseButton addTarget:self action:@selector(detailReverseButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    [detailView addSubview:detailReverseButton];
    //透過度スライダー
    alphaSlider = [[UISlider alloc] initWithFrame:CGRectMake(10, detailView.frame.size.height-40, (detailView.frame.size.width-10*3)/2, 40)];
    [alphaSlider addTarget:self action:@selector(alphaSliderChanged:) forControlEvents:UIControlEventValueChanged];
    alphaSlider.minimumValue = 0.0;
    alphaSlider.maximumValue = 100.0;
    alphaSlider.minimumTrackTintColor = [UIColor blackColor];
    alphaSlider.maximumTrackTintColor = [UIColor lightGrayColor];
    [detailView addSubview:alphaSlider];
    UILabel *alphaLabel = [[UILabel alloc] initWithFrame:CGRectMake(alphaSlider.frame.origin.x, alphaSlider.frame.origin.y-20, alphaSlider.frame.size.width, 30)];
    alphaLabel.textAlignment = NSTextAlignmentLeft;
    alphaLabel.font = [UIFont boldSystemFontOfSize:12];
    alphaLabel.textColor = [UIColor lightGrayColor];
    alphaLabel.text = @"透明度";
    [detailView addSubview:alphaLabel];
    //明るさスライダー
    brightnessSlider = [[UISlider alloc] initWithFrame:CGRectMake(10+(detailView.frame.size.width-10*3)/2+10, detailView.frame.size.height-40, (detailView.frame.size.width-10*3)/2, 40)];
    [brightnessSlider addTarget:self action:@selector(brightnessSliderChanged:) forControlEvents:UIControlEventValueChanged];
    brightnessSlider.minimumValue = -100.0;
    brightnessSlider.maximumValue = 100.0;
    brightnessSlider.minimumTrackTintColor = [UIColor blackColor];
    brightnessSlider.maximumTrackTintColor = [UIColor lightGrayColor];
    [detailView addSubview:brightnessSlider];
    UILabel *brightnessLabel = [[UILabel alloc] initWithFrame:CGRectMake(brightnessSlider.frame.origin.x, brightnessSlider.frame.origin.y-20, brightnessSlider.frame.size.width, 30)];
    brightnessLabel.textAlignment = NSTextAlignmentLeft;
    brightnessLabel.font = [UIFont boldSystemFontOfSize:12];
    brightnessLabel.textColor = [UIColor lightGrayColor];
    brightnessLabel.text = @"明るさ";
    [detailView addSubview:brightnessLabel];
    //色相スライダー
    hueSlider = [[UISlider alloc] initWithFrame:CGRectMake(10, brightnessLabel.frame.origin.y-40, (detailView.frame.size.width-10*3)/2, 40)];
    [hueSlider addTarget:self action:@selector(hueSliderChanged:) forControlEvents:UIControlEventValueChanged];
    hueSlider.minimumValue = 0.0;
    hueSlider.maximumValue = 100.0;
    hueSlider.minimumTrackTintColor = [UIColor blackColor];
    hueSlider.maximumTrackTintColor = [UIColor lightGrayColor];
    [detailView addSubview:hueSlider];
    UILabel *hueLabel = [[UILabel alloc] initWithFrame:CGRectMake(hueSlider.frame.origin.x, hueSlider.frame.origin.y-20, hueSlider.frame.size.width, 30)];
    hueLabel.textAlignment = NSTextAlignmentLeft;
    hueLabel.font = [UIFont boldSystemFontOfSize:12];
    hueLabel.textColor = [UIColor lightGrayColor];
    hueLabel.text = @"色相";
    [detailView addSubview:hueLabel];
    //彩度スライダー
    saturationSlider = [[UISlider alloc] initWithFrame:CGRectMake(10+(detailView.frame.size.width-10*3)/2+10, brightnessLabel.frame.origin.y-40, (detailView.frame.size.width-10*3)/2, 40)];
    [saturationSlider addTarget:self action:@selector(saturationSliderChanged:) forControlEvents:UIControlEventValueChanged];
    saturationSlider.minimumValue = -100.0;
    saturationSlider.maximumValue = 100.0;
    saturationSlider.minimumTrackTintColor = [UIColor blackColor];
    saturationSlider.maximumTrackTintColor = [UIColor lightGrayColor];
    [detailView addSubview:saturationSlider];
    UILabel *saturationLabel = [[UILabel alloc] initWithFrame:CGRectMake(saturationSlider.frame.origin.x, saturationSlider.frame.origin.y-20, saturationSlider.frame.size.width, 30)];
    saturationLabel.textAlignment = NSTextAlignmentLeft;
    saturationLabel.font = [UIFont boldSystemFontOfSize:12];
    saturationLabel.textColor = [UIColor lightGrayColor];
    saturationLabel.text = @"彩度";
    [detailView addSubview:saturationLabel];
    
    /*----------------
     ツールビュー
     ----------------*/
    //ツールビュー
    UIView *toolView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-50, self.view.frame.size.width, 50)];
    toolView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:toolView];
    
    //スタンプ追加ボタン
    addStampButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addStampButton.frame = CGRectMake(((toolView.frame.size.width/3)-40)/2, 0, 40, 50);
    [addStampButton setTitle:@"追加" forState:UIControlStateNormal];
    [addStampButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [addStampButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [addStampButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [addStampButton addTarget:self action:@selector(addStampButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    [toolView addSubview:addStampButton];
    
    //スタンプ消去ボタン
    deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteButton.enabled = NO;
    deleteButton.frame = CGRectMake(toolView.frame.size.width/3+((toolView.frame.size.width/3)-50)/2, 0, 50, 50);
    [deleteButton setTitle:@"消去" forState:UIControlStateNormal];
    [deleteButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [deleteButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [deleteButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [deleteButton addTarget:self action:@selector(deleteButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    [toolView addSubview:deleteButton];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deleteButtonLongPress:)];
    longPress.minimumPressDuration = 1.0;
    longPress.allowableMovement = 10.0;
    [deleteButton addGestureRecognizer:longPress];
    longPress = nil;
    
    //保存ボタン
    saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    saveButton.frame = CGRectMake(toolView.frame.size.width/3*2+((toolView.frame.size.width/3)-50)/2,
                                  (toolView.frame.size.height-50)/2, 50, 50);
    [saveButton setTitle:@"完成" forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [saveButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [saveButton addTarget:self action:@selector(saveButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    [toolView addSubview:saveButton];
}

/*--------------------------------------------------------
 ; saveButtonTaped : 保存ボタンが押された
 ;              in : (UIButton *)button
 ;             out :
 --------------------------------------------------------*/
-(void)saveButtonTaped:(UIButton *)button
{
    UIImage *image = [self createShareImage];
    ShareController *oShareController = [[ShareController alloc] initWithShareImage:image];
    [self.navigationController pushViewController:oShareController animated:YES];
    oShareController = nil;
}

/*--------------------------------------------------------
 ; createShareImage : 保存用画像の作成
 ;               in :
 ;              out : (UIImage *)image
 --------------------------------------------------------*/
-(UIImage *)createShareImage
{
    UIImage *image = nil;
    CGSize size;
    //元画像が小さい場合はcanvasViewのサイズを使用する
    if(backgroundImage.size.width > canvasView.frame.size.width){
        size = backgroundImage.size;
    }else{
        size = canvasView.frame.size;
    }
    
    //サイズ補正用の倍率
    float saveScale = size.width / canvasView.frame.size.width;
    
    
    //描画領域を確保
    UIGraphicsBeginImageContextWithOptions(size, 0.f, 0);
    
    //元画像を描画
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    [backgroundImage drawInRect:rect];
    
    //スタンプの描画
    for(UIView *view in [canvasView subviews]){
        if([view isKindOfClass:[StampView class]]){
            StampView *stampView = (StampView *)view;
            
            CGSize stampSize = [stampView getStampImageView].image.size;
            
            //
            CGAffineTransform t = [stampView getStampImageView].transform;
            [[stampView getStampImageView] setTransform:CGAffineTransformIdentity];
            float stampBaseScale = [stampView getStampImageView].frame.size.width / stampSize.width;
            [[stampView getStampImageView] setTransform:t];
            
            float changeScale = 1 * stampBaseScale * saveScale * [stampView getSize];
            
            UIImage *tmpImage = [UIImage getResizedImage:[stampView getStampImageView].image width:stampSize.width * changeScale  height:stampSize.height * changeScale];
            tmpImage = [tmpImage getTransformedImageWithAngle:M_PI / 180.0f * [stampView getAngle]];
            
            
            float width = tmpImage.size.width ;
            float height = tmpImage.size.height ;
            
            float stampXRate = stampView.center.x / canvasView.frame.size.width;
            float stampYRate = stampView.center.y / canvasView.frame.size.height;
            
            [tmpImage drawInRect:CGRectMake(size.width * stampXRate - width / 2,
                                            size.height * stampYRate - height / 2,
                                            width,
                                            height)];
            
        }
    }
    
    // 現在のグラフィックスコンテキストの画像を取得する
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    // 現在のグラフィックスコンテキストへの編集を終了
    // (スタックの先頭から削除する)
    UIGraphicsEndImageContext();
    
    return image;
}

/*--------------------------------------------------------
 ; addStampButtonTaped : スタンプ追加ボタンが押された
 ;                  in : (UIButton *)button
 ;                 out :
 --------------------------------------------------------*/
-(void)addStampButtonTaped:(UIButton *)button
{
    StampListController *oStampListController = [[StampListController alloc] init];
    oStampListController.delegate = self;
    [self presentViewController:oStampListController animated:YES completion:nil];
    oStampListController = nil;
}

/*--------------------------------------------------------
 ; didSelectStampImage : スタンプリストより使用するスタンプが選択された
 ;                  in : (UIImage *)image
 ;                 out :
 --------------------------------------------------------*/
-(void)didSelectStampImage:(UIImage *)image
{
    StampView *layerStamp = [[StampView alloc] initWithImage:image];
    layerStamp.delegate = self;
    [canvasView addSubview:layerStamp];
}

/*--------------------------------------------------------
 ; touchesEnded : UIViewがタップされ指が離された
 ;           in :
 ;          out :
 --------------------------------------------------------*/
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(detailView.alpha == 0.0){
        [self moveBeganStamp:nil];
    }
}

/*--------------------------------------------------------
 ; deleteButtonTaped : スタンプ消去ボタンが押された
 ;                in : (UIButton *)button
 ;               out :
 --------------------------------------------------------*/
-(void)deleteButtonTaped:(UIButton *)button
{
    if(selectStamp){
        [UIView animateWithDuration:0.2
                         animations:^{
                             closeButton.alpha = 0.0;
                             detailButton.alpha = 0.0;
                             layerButton.alpha = 0.0;
                         }
                         completion:^(BOOL finished){
                             [self.view bringSubviewToFront:canvasView];
                             [UIView animateWithDuration:0.3
                                              animations:^{
                                                  selectStamp.frame = CGRectMake(deleteButton.superview.frame.origin.x+deleteButton.frame.origin.x-selectStamp.superview.frame.origin.x,
                                                                                 deleteButton.superview.frame.origin.y+deleteButton.frame.origin.y-selectStamp.superview.frame.origin.y,
                                                                                 deleteButton.frame.size.width,
                                                                                 deleteButton.frame.size.height);
                                                  selectStamp.alpha = 0.0;
                                              }
                                              completion:^(BOOL finished){
                                                  [self.view sendSubviewToBack:canvasView];
                                                  [selectStamp removeFromSuperview];
                                                  selectStamp.delegate = nil;
                                                  selectStamp = nil;
                                                  StampView *layerStamp = [[canvasView subviews] lastObject];
                                                  [self moveBeganStamp:layerStamp];
                                              }
                              ];
                         }
         ];
    }
}

/*--------------------------------------------------------
 ; allDelete : スタンプの全件消去
 ;        in :
 ;       out :
 --------------------------------------------------------*/
-(void)allDelete
{
    selectStamp.delegate = nil;
    selectStamp = nil;
    [UIView animateWithDuration:0.2
                     animations:^{
                         closeButton.alpha = 0.0;
                         detailButton.alpha = 0.0;
                         layerButton.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                         [self.view bringSubviewToFront:canvasView];
                         [UIView animateWithDuration:0.3
                                          animations:^{
                                              NSLog(@"%lu",(unsigned long)[[canvasView subviews] count]);
                                              for(int i = 0; i < [[canvasView subviews] count]; i++) {
                                                  StampView *layerStamp = [[canvasView subviews] objectAtIndex:i];
                                                  layerStamp.frame = CGRectMake(deleteButton.superview.frame.origin.x+deleteButton.frame.origin.x-layerStamp.superview.frame.origin.x,
                                                                                 deleteButton.superview.frame.origin.y+deleteButton.frame.origin.y-layerStamp.superview.frame.origin.y,
                                                                                 deleteButton.frame.size.width,
                                                                                 deleteButton.frame.size.height);
                                                  layerStamp.alpha = 0.0;
                                              }
                                          }
                                          completion:^(BOOL finished){
                                              NSLog(@"%lu",(unsigned long)[[canvasView subviews] count]);
                                              [self.view sendSubviewToBack:canvasView];
                                              for(int i = 0; i < [[canvasView subviews] count]; i++) {
                                                  StampView *layerStamp = [[canvasView subviews] objectAtIndex:i];
                                                  [layerStamp removeFromSuperview];
                                                  layerStamp.delegate = nil;
                                                  layerStamp = nil;
                                              }
                                              [self moveBeganStamp:nil];
                                          }
                          ];
                     }
     ];
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

/*--------------------------------------------------------
 ; detailButtonTaped : 詳細ボタンが押された
 ;                in : (UIButton *)button
 ;               out :
 --------------------------------------------------------*/
-(void)detailButtonTaped:(UIButton *)button
{
    detailView.alpha = 1.0;
    canvasView.clipsToBounds = NO;
    [alphaSlider setValue:100-selectStamp.fAlpha*100 animated:NO];
    [brightnessSlider setValue:selectStamp.fBrightness*100 animated:NO];
    [saturationSlider setValue:(selectStamp.fSaturation-1)*100 animated:NO];
    [hueSlider setValue:((selectStamp.fHue+180)/360)*100 animated:NO];
    if(moLayerView.alpha == 1.0){
        [self layerButtonTaped:nil];
    }
    [UIView animateWithDuration:0.2
                     animations:^{
                         canvasView.userInteractionEnabled = NO;
                         detailView.frame = CGRectMake(0, self.view.frame.size.height-50-detailView.frame.size.height, detailView.frame.size.width,detailView.frame.size.height);
                         [selectStamp setDetailLayout:YES];
                         selectStamp.center = CGPointMake(canvasView.center.x, detailView.frame.origin.y/2-canvasView.frame.origin.y);
                         closeButton.alpha = 0.0;
                         detailButton.alpha = 0.0;
                         layerButton.alpha = 0.0;
                         addStampButton.enabled = NO;
                         deleteButton.enabled = NO;
                         saveButton.enabled = NO;
                     }
                     completion:^(BOOL finished){
                     }
     ];
}

/*--------------------------------------------------------
 ; detailCloseButtonTaped : 詳細ボタンの閉じるボタンが押された
 ;                     in : (UIButton *)button
 ;                    out :
 --------------------------------------------------------*/
-(void)detailCloseButtonTaped:(UIButton *)button
{
    [UIView animateWithDuration:0.2
                     animations:^{
                         canvasView.userInteractionEnabled = YES;
                         detailView.frame = CGRectMake(0, self.view.frame.size.height-50, detailView.frame.size.width,detailView.frame.size.height);
                         [selectStamp setDetailLayout:NO];
                         closeButton.alpha = 1.0;
                         detailButton.alpha = 1.0;
                         layerButton.alpha = 1.0;
                         addStampButton.enabled = YES;
                         deleteButton.enabled = YES;
                         saveButton.enabled = YES;
                     }
                     completion:^(BOOL finished){
                         detailView.alpha = 0.0;
                         canvasView.clipsToBounds = YES;
                     }
     ];
}

/*--------------------------------------------------------
 ; detailResetButtonTaped : 詳細ボタンのリセットボタンが押された
 ;                     in : (UIButton *)button
 ;                    out :
 --------------------------------------------------------*/
-(void)detailResetButtonTaped:(UIButton *)button
{
    [selectStamp setStampImageReset];
    [alphaSlider setValue:100-selectStamp.fAlpha*100 animated:YES];
    [brightnessSlider setValue:selectStamp.fBrightness*100 animated:YES];
    [saturationSlider setValue:(selectStamp.fSaturation-1)*100 animated:YES];
    [hueSlider setValue:((selectStamp.fHue+180)/360)*100 animated:YES];
    [detailCloseButton setTitle:@"×" forState:UIControlStateNormal];
    [detailCloseButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
}

/*--------------------------------------------------------
 ; detailReverseButtonTaped : 詳細ボタンの反転ボタンが押された
 ;                       in : (UIButton *)button
 ;                      out :
 --------------------------------------------------------*/
-(void)detailReverseButtonTaped:(UIButton *)button
{
    [selectStamp setStampImageReverse];
    if(selectStamp.bReverse || selectStamp.fAlpha != 1.0 || selectStamp.fBrightness != 0.0 || selectStamp.fSaturation != 1.0 || selectStamp.fHue != 0.0){
        //なんらかの加工がされている
        [detailCloseButton setTitle:@"√" forState:UIControlStateNormal];
        [detailCloseButton setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
    }else{
        //なんらかの加工がされていない
        [detailCloseButton setTitle:@"×" forState:UIControlStateNormal];
        [detailCloseButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    }
}

/*--------------------------------------------------------
 ; alphaSliderChanged : 透過度変更のスライダーが操作された
 ;                 in : (UISlider *)slider
 ;                out :
 --------------------------------------------------------*/
-(void)alphaSliderChanged:(UISlider *)slider
{
    [selectStamp setStampImageAlpha:(100-slider.value)/100];
    if(selectStamp.bReverse || selectStamp.fAlpha != 1.0 || selectStamp.fBrightness != 0.0 || selectStamp.fSaturation != 1.0 || selectStamp.fHue != 0.0){
        //なんらかの加工がされている
        [detailCloseButton setTitle:@"√" forState:UIControlStateNormal];
        [detailCloseButton setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
    }else{
        //なんらかの加工がされていない
        [detailCloseButton setTitle:@"×" forState:UIControlStateNormal];
        [detailCloseButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    }
}

/*--------------------------------------------------------
 ; brightnessSliderChanged : 明るさ変更のスライダーが操作された
 ;                      in : (UISlider *)slider
 ;                     out :
 --------------------------------------------------------*/
-(void)brightnessSliderChanged:(UISlider *)slider
{
    [selectStamp setStampImageBrightness:slider.value/100];
    if(selectStamp.bReverse || selectStamp.fAlpha != 1.0 || selectStamp.fBrightness != 0.0 || selectStamp.fSaturation != 1.0 || selectStamp.fHue != 0.0){
        //なんらかの加工がされている
        [detailCloseButton setTitle:@"√" forState:UIControlStateNormal];
        [detailCloseButton setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
    }else{
        //なんらかの加工がされていない
        [detailCloseButton setTitle:@"×" forState:UIControlStateNormal];
        [detailCloseButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    }
}

/*--------------------------------------------------------
 ; hueSliderChanged : 色相変更のスライダーが操作された
 ;               in : (UISlider *)slider
 ;              out :
 --------------------------------------------------------*/
-(void)hueSliderChanged:(UISlider *)slider
{
    float slider4 = (slider.value/100)*360-180;
    if(slider4 < 0){
        slider4 = 360+slider4;
    }
    [selectStamp setStampImageHue:slider4];
    if(selectStamp.bReverse || selectStamp.fAlpha != 1.0 || selectStamp.fBrightness != 0.0 || selectStamp.fSaturation != 1.0 || selectStamp.fHue != 0.0){
        //なんらかの加工がされている
        [detailCloseButton setTitle:@"√" forState:UIControlStateNormal];
        [detailCloseButton setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
    }else{
        //なんらかの加工がされていない
        [detailCloseButton setTitle:@"×" forState:UIControlStateNormal];
        [detailCloseButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    }
}

/*--------------------------------------------------------
 ; saturationSliderChanged : 彩度変更のスライダーが操作された
 ;                      in : (UISlider *)slider
 ;                     out :
 --------------------------------------------------------*/
-(void)saturationSliderChanged:(UISlider *)slider
{
    [selectStamp setStampImageSaturation:slider.value/100+1];
    if(selectStamp.bReverse || selectStamp.fAlpha != 1.0 || selectStamp.fBrightness != 0.0 || selectStamp.fSaturation != 1.0 || selectStamp.fHue != 0.0){
        //なんらかの加工がされている
        [detailCloseButton setTitle:@"√" forState:UIControlStateNormal];
        [detailCloseButton setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
    }else{
        //なんらかの加工がされていない
        [detailCloseButton setTitle:@"×" forState:UIControlStateNormal];
        [detailCloseButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    }
}

/*--------------------------------------------------------
 ; layerButtonTaped : 階層変更ボタンが押された
 ;               in : (UIButton *)button
 ;              out :
 --------------------------------------------------------*/
-(void)layerButtonTaped:(UIButton *)button
{
    if(selectStamp){
        if(moLayerView.alpha == 0.0){
            //階層変更ビューを表示
            for(int i = 0; i < [[canvasView subviews] count]; i++) {
                StampView *layerStamp = [[canvasView subviews] objectAtIndex:i];
                if(layerStamp.alpha == 0.0){
                    [layerStamp removeFromSuperview];
                    layerStamp.delegate = nil;
                    layerStamp = nil;
                }
            }
            [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            layerUpButton.enabled = YES;
            layerDownButton.enabled = YES;
            if([[canvasView subviews] firstObject] == selectStamp){
                layerDownButton.enabled = NO;
            }
            if([[canvasView subviews] lastObject] == selectStamp){
                layerUpButton.enabled = NO;
            }
            [UIView animateWithDuration:0.2
                             animations:^{
                                 moLayerView.alpha = 1.0;
                             }
             ];
        }else{
            //階層変更ビューを非表示
            [UIView animateWithDuration:0.2
                             animations:^{
                                 moLayerView.alpha = 0.0;
                             }
                             completion:^(BOOL finished){
                                 [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
                             }
             ];
        }
    }
}

/*--------------------------------------------------------
 ; layerUpButtonTaped : 階層アップボタンが押された
 ;                 in : (UIButton *)button
 ;                out :
 --------------------------------------------------------*/
-(void)layerUpButtonTaped:(UIButton *)button
{
    NSArray *subViews = [canvasView subviews];
    int selectNum = 0;
    for(int i = 0; i < [subViews count]; i++) {
        StampView *layerStamp = [[canvasView subviews] objectAtIndex:i];
        if(selectStamp == layerStamp){
            selectNum = i;
            break;
        }
    }
    StampView *layerStamp = [subViews objectAtIndex:selectNum];
    [canvasView bringSubviewToFront:layerStamp];
    for(int i = selectNum+2; i < [subViews count]; i++) {
        StampView *layerStamp = [subViews objectAtIndex:i];
        [canvasView bringSubviewToFront:layerStamp];
    }
    if(selectNum >= [subViews count]-2){
        layerUpButton.enabled = NO;
    }else{
        layerUpButton.enabled = YES;
    }
    layerDownButton.enabled = YES;
    CGAffineTransform transform = layerStamp.transform;
    [UIView animateWithDuration:0.1
                     animations:^{
                         layerStamp.transform = CGAffineTransformScale(transform, 0.8, 0.8);
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.1
                                          animations:^{
                                              layerStamp.transform = transform;
                                          }
                                          completion:^(BOOL finished){
                                              
                                          }
                          ];
                     }
     ];
}

/*--------------------------------------------------------
 ; layerDownButtonTaped : 階層ダウンボタンが押された
 ;                   in : (UIButton *)button
 ;                  out :
 --------------------------------------------------------*/
-(void)layerDownButtonTaped:(UIButton *)button
{
    NSArray *subViews = [canvasView subviews];
    int selectNum = 0;
    for(int i = 0; i < [subViews count]; i++) {
        StampView *layerStamp = [[canvasView subviews] objectAtIndex:i];
        if(selectStamp == layerStamp){
            selectNum = i;
            break;
        }
    }
    StampView *layerStamp = [subViews objectAtIndex:selectNum];
    [canvasView sendSubviewToBack:layerStamp];
    for(int i = selectNum-2; i >= 0; i--) {
        StampView *layerStamp = [subViews objectAtIndex:i];
        [canvasView sendSubviewToBack:layerStamp];
    }
    layerUpButton.enabled = YES;
    if(selectNum <= 1){
        layerDownButton.enabled = NO;
    }else{
        layerDownButton.enabled = YES;
    }
    CGAffineTransform transform = layerStamp.transform;
    [UIView animateWithDuration:0.1
                     animations:^{
                         layerStamp.transform = CGAffineTransformScale(transform, 0.8, 0.8);
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.1
                                          animations:^{
                                              layerStamp.transform = transform;
                                          }
                                          completion:^(BOOL finished){
                                              
                                          }
                          ];
                     }
     ];
}

/*========================================================
 ; UILongPressGestureRecognizerSelector
 ========================================================*/
/*--------------------------------------------------------
 ; deleteButtonLongPress : 消去ボタンが長押しされた
 ;                    in : (UILongPressGestureRecognizer *)gesture
 ;                   out :
 --------------------------------------------------------*/
-(void)deleteButtonLongPress:(UILongPressGestureRecognizer *)gesture
{
    if(!deleteLongPressFlag){
        deleteLongPressFlag = YES;
        if([UIAlertController class]){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                           message:@"全て消去してもよろしいですか？"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"キャンセル"
                                                      style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction *action){
                                                        deleteLongPressFlag = NO;
                                                    }
                              ]
             ];
            [alert addAction:[UIAlertAction actionWithTitle:@"消去する"
                                                      style:UIAlertActionStyleDestructive
                                                    handler:^(UIAlertAction *action){
                                                        deleteLongPressFlag = NO;
                                                        [self allDelete];
                                                    }
                              ]
             ];
            [self presentViewController:alert animated:YES completion:nil];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"全て消去してもよろしいですか？"
                                                           delegate:self
                                                  cancelButtonTitle:@"キャンセル"
                                                  otherButtonTitles:@"消去する", nil];
            alert.tag = __DELETE_LONGPRESS_ALERT;
            [alert show];
            alert = nil;
        }
    }
}

/*========================================================
 ; UIAlertViewDelegate
 ========================================================*/
/*--------------------------------------------------------
 ; clickedButtonAtIndex : UIAlertViewのボタンが押された
 ;                   in : (UIAlertView *)alertView
 ;                      : (NSInteger)buttonIndex
 ;                  out :
 --------------------------------------------------------*/
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == __DELETE_LONGPRESS_ALERT){
        deleteLongPressFlag = NO;
        if(buttonIndex == 1){
            [self allDelete];
        }
    }
}

/*========================================================
 ; StampViewDelegate
 ========================================================*/
/*--------------------------------------------------------
 ; moveBeganStamp : スタンプの移動開始
 ;             in : (StampView *)stampView
 ;            out :
 --------------------------------------------------------*/
-(void)moveBeganStamp:(StampView *)stampView
{
    for(StampView *layerStamp in [canvasView subviews]) {
        //スタンプの選択の解除
        [layerStamp selectFlag:NO];
    }
    [layerButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    moLayerView.alpha = 0.0;
    if(stampView){
        canvasView.clipsToBounds = NO;
        selectStamp = stampView;
        [selectStamp selectFlag:YES];
        [UIView animateWithDuration:0.2
                         animations:^{
                             closeButton.alpha = 1.0;
                             detailButton.alpha = 1.0;
                             layerButton.alpha = 1.0;
                             deleteButton.enabled = YES;
                         }
         ];
    }else{
        canvasView.clipsToBounds = YES;
        selectStamp = nil;
        [UIView animateWithDuration:0.2
                         animations:^{
                             closeButton.alpha = 1.0;
                             detailButton.alpha = 0.0;
                             layerButton.alpha = 0.0;
                             deleteButton.enabled = NO;
                         }
         ];
    }
}

/*--------------------------------------------------------
 ; moveMidstStamp : スタンプの移動中
 ;             in : (StampView *)stampView
 ;            out :
 --------------------------------------------------------*/
-(void)moveMidstStamp:(StampView *)stampView
{
    [UIView animateWithDuration:0.2
                     animations:^{
                         closeButton.alpha = 0.0;
                         detailButton.alpha = 0.0;
                         layerButton.alpha = 0.0;
                     }
     ];
}

/*--------------------------------------------------------
 ; moveEndedStamp : スタンプの移動終了
 ;             in : (StampView *)stampView
 ;            out :
 --------------------------------------------------------*/
-(void)moveEndedStamp:(StampView *)stampView
{
    if(stampView.center.x < 0 || stampView.center.x > canvasView.frame.size.width || stampView.center.y < 0 || stampView.center.y > canvasView.frame.size.height){
        //Canvas外にスタンプが移動された
        selectStamp = stampView;
        [self deleteButtonTaped:nil];
    }else{
        [UIView animateWithDuration:0.2
                         animations:^{
                             closeButton.alpha = 1.0;
                             detailButton.alpha = 1.0;
                             layerButton.alpha = 1.0;
                         }
         ];
    }
}

@end

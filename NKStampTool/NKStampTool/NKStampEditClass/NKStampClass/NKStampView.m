//
//  NKStampView.m
//  NKStampTool
//
//  Created by nanoka____ on 2015/06/08.
//  Copyright (c) 2015年 nanoka____. All rights reserved.
//

#import "NKStampView.h"
#import "GPUImagePicture.h"
#import "GPUImageBrightnessFilter.h"
#import "GPUImageSaturationFilter.h"
#import "GPUImageHueFilter.h"

typedef NS_ENUM(NSInteger, EditMode) {
    EditModeDefault = 1,
    EditModeTool,
};

#define ITEM_TOUCH_MARGIN 10
#define MIN_TOUCH_WIDTH   (self.superview ? MIN(150, MIN(self.superview.frame.size.width, self.superview.frame.size.height)) : 150)
#define MAX_DRAW_WIDTH    [UIScreen mainScreen].bounds.size.height*1.5
#define MIN_DRAW_WIDTH    30

@interface NKStampView () <UIGestureRecognizerDelegate>
@property (nonatomic, readwrite) BOOL bReverse;
@property (nonatomic, readwrite) float fAlpha;
@property (nonatomic, readwrite) float fBrightness;
@property (nonatomic, readwrite) float fSaturation;
@property (nonatomic, readwrite) float fHue;
@end

/*========================================================
 ; NKStampView
 ========================================================*/
@implementation NKStampView {
    UIImage *originImage;
    UIImageView *stampImageView;
    UIView *drawAreaView;
    UIImageView *touchAreaView;
    UIImageView *toolEditView;
    BOOL selected;
    EditMode editMode;
}

/*--------------------------------------------------------
 ; dealloc : 解放
 ;      in :
 ;     out :
 --------------------------------------------------------*/
-(void)dealloc
{
    originImage = nil;
    stampImageView = nil;
    drawAreaView = nil;
    touchAreaView = nil;
    toolEditView = nil;
}

/*--------------------------------------------------------
 ; initWithImage : インスタンスの生成
 ;            in : (UIImage *)image
 ;           out : (instancetype)self
 --------------------------------------------------------*/
-(instancetype)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        // Initialization code
        //初期化
        originImage = image;
        angle = 0;
        befAngle = 0;
        posX = 0;
        posY = 0;
        befSize = 1.0;
        scale = 1.0;
        _bReverse = NO;
        _fAlpha = 1.0;
        _fBrightness = 0.0;
        _fSaturation = 1.0;
        _fHue = 0.0;
        bTouch = NO;
        [self setMultipleTouchEnabled:NO];
        [self setTransform:CGAffineTransformIdentity];
        [self setTransform:CGAffineTransformMakeScale(scale, scale)];
        [self setTransform:CGAffineTransformRotate(self.transform, befAngle * M_PI / 180)];
        [self setUserInteractionEnabled:YES];
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin |
        UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        //拡大縮小
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
        [self addGestureRecognizer:pinch];
        [pinch setDelegate:self];
        //回転
        UIRotationGestureRecognizer *rotate = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotate:)];
        [self addGestureRecognizer:rotate];
        [rotate setDelegate:self];
        
        //スタンプ画像
        stampImageView = [[UIImageView alloc] initWithFrame:CGRectMake(__ITEM_WIDTH/2, __ITEM_WIDTH/2,
                                                                       self.frame.size.width-__ITEM_WIDTH,
                                                                       self.frame.size.height-__ITEM_WIDTH)];
        stampImageView.contentMode = UIViewContentModeScaleAspectFit;
        stampImageView.image = originImage;
        stampImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin |
        UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:stampImageView];
        
        //操作エリアサイズ
        touchAreaView = [[UIImageView alloc] initWithFrame:CGRectMake(__ITEM_WIDTH/2, __ITEM_WIDTH/2,
                                                                      self.frame.size.width-__ITEM_WIDTH,
                                                                      self.frame.size.height-__ITEM_WIDTH)];
        touchAreaView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin |
                                         UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin |
                                         UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        touchAreaView.alpha = 0.0;
        [self addSubview:touchAreaView];
        
        //描画サイズ
        drawAreaView = [[UIView alloc] initWithFrame:CGRectMake(__ITEM_WIDTH/2, __ITEM_WIDTH/2,
                                                                self.frame.size.width-__ITEM_WIDTH,
                                                                self.frame.size.height-__ITEM_WIDTH)];
        drawAreaView.layer.borderWidth = 2.0;
        drawAreaView.layer.borderColor = [UIColor whiteColor].CGColor;
        drawAreaView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin |
                                        UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin |
                                        UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        drawAreaView.alpha = 0.0;
        [self addSubview:drawAreaView];
        
        //リサイズアイテム
        toolEditView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-__ITEM_WIDTH, 0, __ITEM_WIDTH, __ITEM_WIDTH)];
        toolEditView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin |
                                        UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin |
                                        UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        toolEditView.backgroundColor = [UIColor whiteColor];
        toolEditView.layer.borderWidth = 1.0;
        toolEditView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        toolEditView.layer.cornerRadius = __ITEM_WIDTH/2;
        toolEditView.alpha = 0.0;
        [self addSubview:toolEditView];
    }
    return self;
}

/*--------------------------------------------------------
 ; drawRect : Viewに図を記入する
 ;       in :
 ;      out :
 --------------------------------------------------------*/
-(void)drawRect:(CGRect)rect
{
    //選択中で操作可能な状態
    if(selected && self.userInteractionEnabled){
        //最小サイズより小さい
        if(self.bounds.size.width*scale < MIN_TOUCH_WIDTH){
            // Drawing code
            UIBezierPath *path = [UIBezierPath bezierPath];
            // 線の色を設定
            [[UIColor whiteColor] set];
            // 線の太さを設定
            [path setLineWidth:1.5f];
            // 点線のパターンを設定
            // この場合、5px線を描き、7px空白にする
            CGFloat dashPattern[] = {5.0f, 7.0f};
            [path setLineDash:dashPattern count:2 phase:0];
            // 始点に移動
            [path moveToPoint:CGPointMake(touchAreaView.frame.origin.x, touchAreaView.frame.origin.y)];
            // 以下、→↓←↑の順に点線を描いていく
            [path addLineToPoint:CGPointMake(touchAreaView.frame.origin.x+touchAreaView.frame.size.width, touchAreaView.frame.origin.y)];
            [path addLineToPoint:CGPointMake(touchAreaView.frame.origin.x+touchAreaView.frame.size.width, touchAreaView.frame.origin.y+touchAreaView.frame.size.height)];
            [path addLineToPoint:CGPointMake(touchAreaView.frame.origin.x, touchAreaView.frame.origin.y+touchAreaView.frame.size.height)];
            [path addLineToPoint:CGPointMake(touchAreaView.frame.origin.x, touchAreaView.frame.origin.y)];
            [path stroke];
        }
    }
}

/*--------------------------------------------------------
 ; didMoveToSuperview : superviewが変更されたとき
 ;                 in :
 ;                out :
 --------------------------------------------------------*/
-(void)didMoveToSuperview
{
    self.frame = CGRectMake(0, 0, MIN_TOUCH_WIDTH, MIN_TOUCH_WIDTH);
    self.center = CGPointMake(self.superview.frame.size.width/2, self.superview.frame.size.height/2);
    self.backgroundColor = [UIColor clearColor];
    stampImageView.frame = CGRectMake(__ITEM_WIDTH/2, __ITEM_WIDTH/2,
                                      self.frame.size.width-__ITEM_WIDTH,
                                      self.frame.size.height-__ITEM_WIDTH);
    drawAreaView.frame = CGRectMake(__ITEM_WIDTH/2, __ITEM_WIDTH/2,
                                    self.frame.size.width-__ITEM_WIDTH,
                                    self.frame.size.height-__ITEM_WIDTH);
    touchAreaView.frame = CGRectMake(__ITEM_WIDTH/2, __ITEM_WIDTH/2,
                                     self.frame.size.width-__ITEM_WIDTH,
                                     self.frame.size.height-__ITEM_WIDTH);
    toolEditView.frame = CGRectMake(self.frame.size.width-__ITEM_WIDTH, 0, __ITEM_WIDTH, __ITEM_WIDTH);
    posX = self.frame.origin.x;
    posY = self.frame.origin.y;
    [self changeTransform];
    CGAffineTransform transform = self.transform;
    [UIView animateWithDuration:0.1
                     animations:^{
                         self.transform = CGAffineTransformScale(transform, 0.8, 0.8);
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.1
                                          animations:^{
                                              self.transform = transform;
                                          }
                                          completion:^(BOOL finished){
                                              
                                          }
                          ];
                     }
     ];
}

/*========================================================
 ; スタンプ操作
 ========================================================*/
/*--------------------------------------------------------
 ; pinch : 拡大縮小
 ;    in : (UIPinchGestureRecognizer*)pinch
 ;   out :
 --------------------------------------------------------*/
-(void)pinch:(UIPinchGestureRecognizer*)pinch
{
    if(selected){
        scale *= (1 + pinch.scale - befSize);
        befSize = pinch.scale;
        [self changeTransform];
        toolEditView.backgroundColor = [UIColor lightGrayColor];
    }
}

/*--------------------------------------------------------
 ; rotate : 回転
 ;     in : (UIRotationGestureRecognizer*)rotate
 ;    out :
 --------------------------------------------------------*/
-(void)rotate:(UIRotationGestureRecognizer*)rotate
{
    if(selected){
        befAngle = angle + (rotate.rotation / M_PI*180);
        [self changeTransform];
        toolEditView.backgroundColor = [UIColor whiteColor];
    }
}

/*--------------------------------------------------------
 ; touchesBegan : タッチ開始時
 ;           in : (NSSet *)touches
 ;              : (UIEvent *)event
 ;          out :
 --------------------------------------------------------*/
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch *touch in touches){
        CGPoint tool = [touch locationInView:toolEditView];
        if(tool.x > -ITEM_TOUCH_MARGIN && tool.x < toolEditView.frame.size.width+ITEM_TOUCH_MARGIN && tool.y > -ITEM_TOUCH_MARGIN && tool.y < toolEditView.frame.size.height+ITEM_TOUCH_MARGIN){
            //回転アイテム
            editMode = EditModeTool;
            toolEditView.backgroundColor = [UIColor lightGrayColor];
            drawAreaView.layer.borderColor = [UIColor whiteColor].CGColor;
        }else{
            //その他
            editMode = EditModeDefault;
            angle = befAngle;
            befSize = 1.0;
            befPoint = [touch locationInView:self.superview];
        }
        break;
    }
    [self.delegate moveBeganStamp:self];
}

/*--------------------------------------------------------
 ; touchesMoved : タッチされたまま動いている時
 ;           in : (NSSet *)touches
 ;              : (UIEvent *)event
 ;          out :
 --------------------------------------------------------*/
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(selected){
        if(!touches && !event){
            posX = self.frame.origin.x;
            posY = self.frame.origin.y;
            befPoint = CGPointZero;
            [self changeTransform];
        }else{
            for(UITouch *touch in touches){
                if(editMode == EditModeTool){
                    //回転アイテム
                    //前回のタッチ位置
                    CGPoint prevPoint = toolEditView.center;
                    //現在のタッチ位置
                    CGPoint movePoint = [touch locationInView:self];
                    //スタンプの中央位置
                    CGPoint center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
                    //中央との差分
                    CGFloat prevX = prevPoint.x - center.x;
                    CGFloat prevY = prevPoint.y - center.y;
                    CGFloat moveX = movePoint.x - center.x;
                    CGFloat moveY = movePoint.y - center.y;
                    CGFloat prevAtan = atan2(prevX, prevY);
                    CGFloat moveAtan = atan2(moveX, moveY);
                    //角度
                    float rotate = (prevAtan - moveAtan) * 180 / M_PI;
                    if (rotate > 180){
                        rotate -= 360;
                    }else if (rotate < -180){
                        rotate += 360;
                    }
                    // sum up single steps
                    angle += rotate;
                    if(angle > 360){
                        angle -= 360;
                    }else if(angle < 0){
                        angle += 360;
                    }
                    toolEditView.backgroundColor = [UIColor lightGrayColor];
                    drawAreaView.layer.borderColor = [UIColor whiteColor].CGColor;
                    befAngle = angle;
                    float margin = 1;
                    if(angle > 360-margin || angle < 0+margin){
                        befAngle = 0;
                        drawAreaView.layer.borderColor = [UIColor cyanColor].CGColor;
                    }else if(angle > 90-margin && angle < 90+margin){
                        befAngle = 90;
                        drawAreaView.layer.borderColor = [UIColor cyanColor].CGColor;
                    }else if(angle > 180-margin && angle < 180+margin){
                        befAngle = 180;
                        drawAreaView.layer.borderColor = [UIColor cyanColor].CGColor;
                     }else if(angle > 270-margin && angle < 270+margin){
                        befAngle = 270;
                       drawAreaView.layer.borderColor = [UIColor cyanColor].CGColor;
                    }
                    //サイズ
                    CGFloat prevDistance = sqrtf(prevX*prevX + prevY*prevY);
                    CGFloat moveDistance = sqrtf(moveX*moveX + moveY*moveY);
                    scale *= moveDistance/prevDistance;
                }else if(editMode == EditModeDefault){
                    //その他
                    CGPoint move = [touch locationInView:self.superview];
                    posX += (move.x - befPoint.x);
                    posY += (move.y - befPoint.y);
                    befPoint = move;
                    [self.delegate moveMidstStamp:self];
                }
                [self changeTransform];
                break;
            }
        }
    }
}

/*--------------------------------------------------------
 ; touchesEnded : タッチが終了された時
 ;           in : (NSSet *)touches
 ;              : (UIEvent *)event
 ;          out :
 --------------------------------------------------------*/
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(selected){
        if(editMode == EditModeTool){
            //回転アイテム
            toolEditView.backgroundColor = [UIColor whiteColor];
            drawAreaView.layer.borderColor = [UIColor whiteColor].CGColor;
        }
        editMode = EditModeDefault;
        [self.delegate moveEndedStamp:self];
    }
}

/*--------------------------------------------------------
 ; touchesCancelled : タッチがキャンセルされた時
 ;               in : (NSSet *)touches
 ;                  : (UIEvent *)event
 ;              out :
 --------------------------------------------------------*/
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

/*========================================================
 ; スタンプ状態変更
 ========================================================*/
/*--------------------------------------------------------
 ; changeTransform : アフィンを変更する
 ;              in :
 ;             out :
 --------------------------------------------------------*/
-(void)changeTransform
{
    self.transform = CGAffineTransformIdentity;
    self.frame = CGRectMake(posX, posY, self.bounds.size.width, self.bounds.size.height);
    //最小サイズの判定
    if(self.bounds.size.width*scale < MIN_DRAW_WIDTH){
        scale = MIN_DRAW_WIDTH/self.bounds.size.width;
    }
    //最大サイズの判定
    if(self.bounds.size.width*scale > MAX_DRAW_WIDTH){
        scale = MAX_DRAW_WIDTH/self.bounds.size.width;
    }
    //最小タッチ領域の判定
    if(self.bounds.size.width*scale >= MIN_TOUCH_WIDTH){
        //最小タッチ領域より大きい
        self.transform = CGAffineTransformMakeScale(scale, scale);
        stampImageView.transform = CGAffineTransformIdentity;
        drawAreaView.transform = CGAffineTransformIdentity;
        if(selected){
            drawAreaView.alpha = 1.0;
        }
    }else{
        //最小タッチ領域より小さい
        float touchScale = MIN_TOUCH_WIDTH/self.bounds.size.width;
        float minScale = (self.bounds.size.width*scale)/MIN_TOUCH_WIDTH;
        self.transform = CGAffineTransformMakeScale(touchScale, touchScale);
        stampImageView.transform = CGAffineTransformMakeScale(minScale,minScale);
        drawAreaView.transform = CGAffineTransformMakeScale(minScale,minScale);
        if(selected){
            drawAreaView.alpha = 1.0;
        }
    }
    drawAreaView.layer.borderWidth = 2/scale;
    //角度を設定
    self.transform = CGAffineTransformRotate(self.transform, befAngle * M_PI / 180);
    //操作アイテムの設定
    CGPoint toolCenter = toolEditView.center;
    toolEditView.transform = CGAffineTransformInvert(self.transform);
    toolEditView.bounds = CGRectMake(0, 0, __ITEM_WIDTH, __ITEM_WIDTH);
    toolEditView.center = toolCenter;
    [self setNeedsDisplay];
}

/*--------------------------------------------------------
 ; selectFlag : 選択状態が変化した時
 ;         in :
 ;        out :
 --------------------------------------------------------*/
-(void)selectFlag:(BOOL)select
{
    selected = select;
    if(selected){
        drawAreaView.alpha = 1.0;
        touchAreaView.alpha = 0.0;
        toolEditView.alpha = 1.0;
        [self changeTransform];
    }else{
        drawAreaView.alpha = 0.0;
        touchAreaView.alpha = 0.0;
        toolEditView.alpha = 0.0;
        [self setNeedsDisplay];
    }
}

/*--------------------------------------------------------
 ; setDetailLayout : スタンプの詳細設定時のレイアウトモード切り替え
 ;              in : (BOOL)flag
 ;             out :
 --------------------------------------------------------*/
-(void)setDetailLayout:(BOOL)flag
{
    if(flag){
        self.userInteractionEnabled = NO;
        [self setNeedsDisplay];
        [UIView animateWithDuration:0.1
                         animations:^{
                             toolEditView.alpha = 0.0;
                             drawAreaView.layer.borderWidth = 2;
                             drawAreaView.layer.borderColor = [UIColor cyanColor].CGColor;
                             self.transform = CGAffineTransformIdentity;
                             stampImageView.transform = CGAffineTransformIdentity;
                             drawAreaView.transform = CGAffineTransformIdentity;
                         }
                         completion:^(BOOL finished){
                             
                         }
         ];
    }else{
        self.userInteractionEnabled = YES;
        [UIView animateWithDuration:0.1
                         animations:^{
                             toolEditView.alpha = 1.0;
                             drawAreaView.layer.borderColor = [UIColor whiteColor].CGColor;
                             [self changeTransform];
                         }
                         completion:^(BOOL finished){
                             
                         }
         ];
    }
}

/*--------------------------------------------------------
 ; setReverse : スタンプの画像の反転
 ;         in :
 ;        out :
 --------------------------------------------------------*/
-(void)setStampImageReverse
{
    //スタンプ画像を反転
    if(_bReverse){
        //通常に戻す
        _bReverse = NO;
    }else{
        //左右反転させる
        _bReverse = YES;
    }
    [self changeStampImage];
}

/*--------------------------------------------------------
 ; setStampImageAlpha : スタンプの画像の透明度の設定
 ;                 in : (float)alpha
 ;                out :
 --------------------------------------------------------*/
-(void)setStampImageAlpha:(float)alpha
{
    _fAlpha = alpha;
    [self changeStampImage];
}

/*--------------------------------------------------------
 ; setStampImageBrightness : スタンプの画像の明るさの設定
 ;                      in : (float)brightness
 ;                     out :
 --------------------------------------------------------*/
-(void)setStampImageBrightness:(float)brightness
{
    _fBrightness = brightness;
    [self changeStampImage];
}

/*--------------------------------------------------------
 ; setStampImageSaturation : スタンプの画像の彩度の設定
 ;                      in : (float)saturation
 ;                     out :
 --------------------------------------------------------*/
-(void)setStampImageSaturation:(float)saturation
{
    _fSaturation = saturation;
    [self changeStampImage];
}

/*--------------------------------------------------------
 ; setStampImageHue : スタンプの画像の色相の設定
 ;               in : (float)hue
 ;              out :
 --------------------------------------------------------*/
-(void)setStampImageHue:(float)hue
{
    _fHue = hue;
    [self changeStampImage];
}

/*--------------------------------------------------------
 ; setStampImageReset : スタンプの画像のリセット
 ;                 in :
 ;                out :
 --------------------------------------------------------*/
-(void)setStampImageReset
{
    //通常に戻す
    _bReverse = NO;
    _fAlpha = 1.0;
    _fBrightness = 0.0;
    _fSaturation = 1.0;
    _fHue = 0.0;
    [self changeStampImage];
}

/*--------------------------------------------------------
 ; changeStampImage : スタンプの画像を作成する
 ;               in :
 ;              out :
 --------------------------------------------------------*/
-(void)changeStampImage
{
    UIImage *image = originImage;
    //色相
    if(_fHue != 90.0){
        GPUImagePicture *imagePicture = [[GPUImagePicture alloc] initWithImage:image];
        GPUImageHueFilter *hueFilter = [[GPUImageHueFilter alloc] init];
        // Hue ranges from 0.0 (fully desaturated) to 360.0 (max hue), with 90.0 as the normal level
        [hueFilter setHue:_fHue];
        [imagePicture addTarget:hueFilter];
        [imagePicture processImage];
        image = [hueFilter imageFromCurrentlyProcessedOutput];
        imagePicture = nil;
        hueFilter = nil;
    }
    //彩度
    if(_fSaturation != 1.0){
        GPUImagePicture *imagePicture = [[GPUImagePicture alloc] initWithImage:image];
        GPUImageSaturationFilter *saturationFilter = [[GPUImageSaturationFilter alloc] init];
        // Saturation ranges from 0.0 (fully desaturated) to 2.0 (max saturation), with 1.0 as the normal level
        [saturationFilter setSaturation:_fSaturation];
        [imagePicture addTarget:saturationFilter];
        [imagePicture processImage];
        image = [saturationFilter imageFromCurrentlyProcessedOutput];
        imagePicture = nil;
        saturationFilter = nil;
    }
    //明るさ
    if(_fBrightness != 0.0){
        GPUImagePicture *imagePicture = [[GPUImagePicture alloc] initWithImage:image];
        GPUImageBrightnessFilter *brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
        // Brightness ranges from -1.0 to 1.0, with 0.0 as the normal level
        [brightnessFilter setBrightness:_fBrightness];
        [imagePicture addTarget:brightnessFilter];
        [imagePicture processImage];
        image = [brightnessFilter imageFromCurrentlyProcessedOutput];
        imagePicture = nil;
        brightnessFilter = nil;
    }
    //透過度
    if(_fAlpha != 1.0){
        CGRect rect = CGRectMake(0.0f,0.0f,image.size.width,image.size.height);
        UIGraphicsBeginImageContextWithOptions(image.size,NO,0);
        [image drawInRect:rect blendMode:kCGBlendModeDifference alpha:_fAlpha];
        UIImage *blendedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        image = blendedImage;
    }
    //左右反転
    if(_bReverse){
        CGImageRef imageRef = [image CGImage];
        UIGraphicsBeginImageContext(image.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM( context, image.size.width,image.size.height);
        CGContextScaleCTM( context, -1.0, -1.0);
        CGContextDrawImage( context, CGRectMake( 0, 0,image.size.width, image.size.height), imageRef);
        UIImage *alphaImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        image = alphaImage;
    }
    stampImageView.image = image;
}

/*========================================================
 ; スタンプ状態を返す
 ========================================================*/
/*--------------------------------------------------------
 ; getAngle : スタンプの角度を返す
 ;       in :
 ;      out : (float)beAngle
 --------------------------------------------------------*/
-(float)getAngle
{
    return befAngle;
}

/*--------------------------------------------------------
 ; getSize : スタンプの拡大率を返す
 ;      in :
 ;     out : (float)scale
 --------------------------------------------------------*/
-(float)getSize
{
    //    float toolScale = self.bounds.size.width/(self.bounds.size.width-__ITEM_WIDTH);
    //    return scale*toolScale;
    return scale;
}

/*--------------------------------------------------------
 ; getStampImageView : スタンプ画像のImageViewを返す
 ;                in :
 ;               out : (UIImageView *)stampImageView
 --------------------------------------------------------*/
-(UIImageView *)getStampImageView
{
    return stampImageView;
}

/*--------------------------------------------------------
 ; getTouchAreaView : スタンプの最大タッチ領域表示Viewを返す
 ;               in :
 ;              out : (UIView *)touchAreaView
 --------------------------------------------------------*/
-(UIView *)getTouchAreaView
{
    return touchAreaView;
}

/*========================================================
 ; UIGestureRecognizerDelegate
 ========================================================*/
/*--------------------------------------------------------
 ; shouldRecognizeSimultaneouslyWithGestureRecognizer : 複数のジェスチャーを検知した
 ;                                                 in : (UIGestureRecognizer *)gestureRecognizer
 ;                                                    : (UIGestureRecognizer *)otherGestureRecognizer
 ;                                                out : (BOOL)flag
 --------------------------------------------------------*/
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    /* 無条件に、すべてのジェスチャを同時に認識します。 */
    return YES;
}

@end
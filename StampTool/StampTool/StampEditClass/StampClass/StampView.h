//
//  StampToolView.h
//  StampTool
//
//  Created by t-tazoe on 2015/06/08.
//  Copyright (c) 2015年 t-tazoe. All rights reserved.
//

#import <UIKit/UIKit.h>

#define __ITEM_WIDTH 30
@class StampView;

@protocol StampViewDelegate <NSObject>
-(void)moveBeganStamp:(StampView *)stampView;
-(void)moveMidstStamp:(StampView *)stampView;
-(void)moveEndedStamp:(StampView *)stampView;
@end

@interface StampView : UIView{
    CGPoint befPoint;
    float posX;
    float posY;
    float angle;
    float befAngle;
    float befSize;
    float scale;
    BOOL bTouch;
}
@property (nonatomic, weak) id <StampViewDelegate> delegate;
@property (nonatomic, readonly) BOOL bReverse;
@property (nonatomic, readonly) float fAlpha;
@property (nonatomic, readonly) float fBrightness;
@property (nonatomic, readonly) float fSaturation;
@property (nonatomic, readonly) float fHue;

-(void)setStampImageReverse;
-(void)setStampImageAlpha:(float)alpha;
-(void)setStampImageBrightness:(float)brightness;
-(void)setStampImageSaturation:(float)saturation;
-(void)setStampImageHue:(float)hue;
-(void)setStampImageReset;

-(instancetype)initWithImage:(UIImage *)image;
-(void)setDetailLayout:(BOOL)flag;
-(void)selectFlag:(BOOL)select;
-(float)getAngle;
-(float)getSize;
-(UIImageView *)getStampImageView;
@end

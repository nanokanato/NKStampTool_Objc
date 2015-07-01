//
//  CollectionCell.m
//  NKStampTool
//
//  Created by nanoka____ on 2015/06/09.
//  Copyright (c) 2015年 nanoka____. All rights reserved.
//

#import "CollectionCell.h"

/*========================================================
 ; CollectionCell
 ========================================================*/
@implementation CollectionCell{
    UIImageView *imageView;
}

/*--------------------------------------------------------
 ; dealloc : 解放
 ;      in :
 ;     out :
 --------------------------------------------------------*/
-(void)dealloc
{
    imageView = nil;
    self.image = nil;
}

/*--------------------------------------------------------
 ; initWithFrame : インスタンスの生成
 ;            in : (CGRect)frame
 ;           out : (instancetype)self
 --------------------------------------------------------*/
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, self.frame.size.width-10*2, self.frame.size.height-10*2)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.autoresizesSubviews = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:imageView];
    }
    return self;
}

/*--------------------------------------------------------
 ; setImage : 画像の設定
 ;       in : (UIImage *)image
 ;      out :
 --------------------------------------------------------*/
-(void)setImage:(UIImage *)image
{
    imageView.image = image;
}

@end

//
//  UIImage+Resize.h
//  NKStampTool
//
//  Created by nanoka____ on 2015/06/09.
//  Copyright (c) 2015年 nanoka____. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Resize)

+ (UIImage *)getResizedImage:(UIImage *)image width:(CGFloat)width height:(CGFloat)height;
+ (UIImage *)getResizedImage:(UIImage *)image size:(CGSize)size;
+ (UIImage *)getResizedImage:(UIImage *)image scale:(float)scale;

@end
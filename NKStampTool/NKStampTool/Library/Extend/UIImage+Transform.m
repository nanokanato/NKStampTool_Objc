//
//  UIImage+Transform.m
//  NKStampTool
//
//  Created by nanoka____ on 2015/06/09.
//  Copyright (c) 2015年 nanoka____. All rights reserved.
//

#import "UIImage+Transform.h"

@implementation UIImage (Transform)

- (UIImage*) getTransformedImageWithAngle:(float)angle
{
    float newWidth = (fabsf((float)(sinf(angle) * self.size.height)) + fabsf((float)(cos(angle) * self.size.width)));
    float newHeight = (fabsf((float)(sinf(angle) * self.size.width)) + fabsf((float)(cos(angle) * self.size.height)));
    
    
    CGSize newSize = CGSizeMake(newWidth, newHeight);
    NSLog(@"view frame = %@\n", NSStringFromCGSize(newSize));


    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, newSize.width/2, newSize.height/2);
    
    CGContextRotateCTM(context, angle);
    
    // (3)
    CGContextTranslateCTM(context, 0, -newSize.height/2);
    // (4)
    CGContextTranslateCTM(context, -newSize.width/2, 0);
    
    
    [self drawInRect:CGRectMake((newWidth - self.size.width) / 2, (newHeight - self.size.height) / 2, self.size.width, self.size.height)];
    UIImage *final_img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return final_img;
}


@end

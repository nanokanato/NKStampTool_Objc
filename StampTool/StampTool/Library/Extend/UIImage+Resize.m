#import "UIImage+Resize.h"

@implementation UIImage (Resize)

+ (UIImage *)getResizedImage:(UIImage *)image width:(CGFloat)width height:(CGFloat)height
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), NO, [[UIScreen mainScreen] scale]);

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh); // 高品質リサイズ
    
    [image drawInRect:CGRectMake(0.0, 0.0, width, height)];
    
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

+ (UIImage *)getResizedImage:(UIImage *)image size:(CGSize)size
{
    return [UIImage getResizedImage:image width:size.width height:size.height];
}

+ (UIImage *)getResizedImage:(UIImage *)image scale:(float)scale
{
    return [UIImage getResizedImage:image width:image.size.width * scale height:image.size.height * scale];
}

@end
#import <UIKit/UIKit.h>

@interface UIImage (Resize)

+ (UIImage *)getResizedImage:(UIImage *)image width:(CGFloat)width height:(CGFloat)height;
+ (UIImage *)getResizedImage:(UIImage *)image size:(CGSize)size;
+ (UIImage *)getResizedImage:(UIImage *)image scale:(float)scale;

@end
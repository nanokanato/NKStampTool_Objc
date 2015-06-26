#import <UIKit/UIKit.h>

@interface NewFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, retain) NSIndexPath *selectedPath;
-(void)setColumnCount:(int)cnt;
-(void)setHeaderHeight:(float)height;
-(void)setFooterHeight:(float)height;

@end
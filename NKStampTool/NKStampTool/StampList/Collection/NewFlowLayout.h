//
//  NewFlowLayout.h
//  NKStampTool
//
//  Created by nanoka____ on 2015/06/09.
//  Copyright (c) 2015年 nanoka____. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, retain) NSIndexPath *selectedPath;
-(void)setColumnCount:(int)cnt;
-(void)setHeaderHeight:(float)height;
-(void)setFooterHeight:(float)height;

@end
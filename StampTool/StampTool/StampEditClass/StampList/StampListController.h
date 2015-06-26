//
//  StampToolListController.h
//  StampTool
//
//  Created by t-tazoe on 2015/06/09.
//  Copyright (c) 2015年 t-tazoe. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StampListControllerDelegate <NSObject>
-(void)didSelectStampImage:(UIImage *)image;
@end

@interface StampListController : UIViewController
@property (nonatomic, weak) id <StampListControllerDelegate> delegate;
@end

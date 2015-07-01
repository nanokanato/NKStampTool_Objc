//
//  NewFlowLayout.m
//  NKStampTool
//
//  Created by nanoka____ on 2015/06/09.
//  Copyright (c) 2015年 nanoka____. All rights reserved.
//

#import "NewFlowLayout.h"

@implementation NewFlowLayout
{
    NSMutableArray *attributesArray;
    int columnCount;
    float contentHeight;
    float headerHeight;
    float footerHeight;
}

-(void)dealloc
{
    
}

-(id)init
{
    self = [super init];
    if(self){
        attributesArray = [[NSMutableArray alloc] init];
        columnCount = 4;
        headerHeight = 0;
        footerHeight = 0;
        contentHeight = self.collectionView.frame.size.height;
        self.sectionInset = UIEdgeInsetsZero;
    }
    return self;
}

-(void)setColumnCount:(int)cnt
{
    columnCount = cnt;
}

-(void)setHeaderHeight:(float)height
{
    headerHeight = height;
}

-(void)setFooterHeight:(float)height
{
    footerHeight = height;
}

- (CGSize)collectionViewContentSize
{
    CGSize size = CGSizeMake(self.collectionView.bounds.size.width, contentHeight);
    return size;
}

- (void)prepareLayout{
    [super prepareLayout];
    NSInteger itemCount = [[self collectionView] numberOfItemsInSection:0];
    //各セルの余白
    float space = self.sectionInset.left;
    //各セルの横サイズ
    float width = (self.collectionView.frame.size.width-space*(columnCount+1))/columnCount;
    float height = width;
    float x = space;
    float y = space+headerHeight;
    for (int i = 0; i < itemCount; i++) {
        //セルの番号の参照パス
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        //セルのレイアウトを作成
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.frame = CGRectMake(x, y, width, height);
        [attributesArray addObject:attributes];
        x = x+width+space;
        if(x > self.collectionView.frame.size.width-width/2){
            y = y+height+space;
            x = space;
        }
    }
    if(x != space){
        y = y+height+space;
    }
    y = y+footerHeight;
    contentHeight = y;
}

//レイアウトの作成
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    return [attributesArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *evaluatedObject, NSDictionary *bindings) {
        return CGRectIntersectsRect(rect, [evaluatedObject frame]);
    }]];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return (attributesArray)[indexPath.item];
}

@end
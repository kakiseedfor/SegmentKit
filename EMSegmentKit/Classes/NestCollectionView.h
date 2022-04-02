//
//  NestTableView.h
//  FormaxSecurity
//
//  Created by LIYINGPENG on 2018/6/14.
//  Copyright © 2018年 Formax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NestViewHeader.h"

@interface NestCollectionView : UICollectionView<NestScrollViewDelegate>
@property (nonatomic) CGFloat maxOffsetPoint;
@property (nonatomic) BOOL canRefresh;

@end

//
//  NestScrollView.h
//  CFX
//
//  Created by kakiYen on 2019/6/30.
//  Copyright © 2019年 taojinzhe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NestViewHeader.h"

@interface NestScrollView : UIScrollView<NestScrollViewDelegate>
@property (strong, readonly, nonatomic) UIView *contentView;
@property (nonatomic) CGFloat maxOffsetPoint;
@property (nonatomic) BOOL canRefresh;

@end

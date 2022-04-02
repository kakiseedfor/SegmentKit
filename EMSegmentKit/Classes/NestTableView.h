//
//  NestTableView.h
//  FormaxSecurity
//
//  Created by kakiYen on 2018/6/14.
//  Copyright © 2018年 Formax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NestViewHeader.h"

@interface NestTableView : UITableView<NestScrollViewDelegate>
@property (nonatomic) CGFloat maxOffsetPoint;
@property (nonatomic) BOOL canRefresh;

@end

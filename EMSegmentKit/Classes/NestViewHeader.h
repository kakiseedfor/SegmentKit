//
//  NestViewHeader.h
//  CFX
//
//  Created by kakiYen on 2019/10/14.
//  Copyright © 2019 taojinzhe. All rights reserved.
//

#ifndef NestViewHeader_h
#define NestViewHeader_h

@protocol NestScrollViewDelegate <NSObject>
@property (readonly, nonatomic) CGFloat restOffset;
@property (readonly, nonatomic) BOOL canMinOffset;
@property (readonly, nonatomic) BOOL isTop;
@property (nonatomic) CGFloat maxOffsetPoint;
@property (nonatomic) BOOL canRefresh;

@end

#endif /* NestViewHeader_h */

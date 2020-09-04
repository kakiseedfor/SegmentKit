//
//  CFDSegmentContainView.h
//  globalwin
//
//  Created by kakiYen on 2018/7/31.
//  Copyright © 2018年 taojinzhe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SegmentProtocol.h"

@interface SegmentContainView : UIView
@property (weak, nonatomic) id<SegmentContainProtocol> delegate;
@property (weak, readonly, nonatomic) UIView<SegmentViewProtocol> *currentView;

- (void)reloadData;

- (void)scrollToItemAtIndexPath:(NSInteger)index;

- (void)scrollToItemAtIndexPath:(NSInteger)index animation:(BOOL)animation;

@end

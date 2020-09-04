//
//  SegmentProtocol.h
//  globalwin
//
//  Created by kakiYen on 2018/7/31.
//  Copyright © 2018年 taojinzhe. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SegmentTagProtocol <NSObject>

- (NSInteger)numberOfSegmentTags;

- (NSString *)stringForItemAtIndexPath:(NSInteger)index;

@end

@protocol SegmentViewProtocol <NSObject>

- (void)didDisplaying;

- (void)willDisplaying;

- (void)didEndDisplaying;

@end

@protocol SegmentContainProtocol <NSObject>

- (NSInteger)numberOfSegmentViews;

- (UIView<SegmentViewProtocol> *)segmentContainForCellAtIndex:(NSInteger)index;

@end

//
//  SegmentTagView.h
//  globalwin
//
//  Created by kakiYen on 2018/7/31.
//  Copyright © 2018年 taojinzhe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SegmentProtocol.h"

@protocol SegmentTagCollectionViewDelegate <UICollectionViewDelegate>

- (void)scrollViewDidEndScrollingWith:(NSIndexPath *)indexPath animated:(BOOL)animated;

- (void)scrollViewDidScrollWith:(UICollectionView *)collectionView;

@end

@interface SegmentTagView : UIView<SegmentTagCollectionViewDelegate>
@property (weak, nonatomic) id<SegmentTagProtocol> delegate;

- (void)reloadData;

@end

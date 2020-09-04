//
//  CFDSegmentContainView.m
//  globalwin
//
//  Created by kakiYen on 2018/7/31.
//  Copyright © 2018年 taojinzhe. All rights reserved.
//

#import <objc/runtime.h>
#import "SegmentContainView.h"
#import "SegmentTagView.h"

extern NSHashTable<SegmentTagView *> *SegmentTagViews;

#pragma mark - SegmentContainCollectionView

@interface SegmentContainCollectionView : UICollectionView<UIGestureRecognizerDelegate, CALayerDelegate>
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (copy, nonatomic) void(^displayLayerCallBack)(void);
@property (nonatomic) UICollectionViewScrollPosition scrollPosition;
@property (nonatomic) BOOL animated;

@end

@implementation SegmentContainCollectionView

- (void)dealloc
{
    NSLog(@"%s",__FUNCTION__);
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    
    if (self) {
        self.layer.delegate = self;
    }
    
    return self;
}

- (void)scrollToItemAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UICollectionViewScrollPosition)scrollPosition animated:(BOOL)animated
{
    if (self.contentSize.width > 0.f) {
        NSInteger count = [self numberOfItemsInSection:0];
        if (indexPath.row > count) {
            return;
        }
        
        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
        if (animated && self.contentSize.width > CGRectGetMinX(attributes.frame)) {
            [super scrollToItemAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated];
            return;
        }
        
        _animated = animated;
        _indexPath = indexPath;
        _scrollPosition = scrollPosition;
        [self.layer setNeedsDisplay];
    }else{
        _animated = indexPath.row ? animated : NO;
        _indexPath = indexPath;
        _scrollPosition = scrollPosition;
        [self.layer setNeedsDisplay];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return [otherGestureRecognizer isKindOfClass:UIScreenEdgePanGestureRecognizer.class];
}

- (void)displayLayer:(CALayer *)layer{
    NSInteger count = [self numberOfItemsInSection:0];
    
    if (!(count > 0)) {
        return;
    }
    
    if (_indexPath.row > count) {
        return;
    }
    
    [super scrollToItemAtIndexPath:_indexPath atScrollPosition:_scrollPosition animated:_animated];
    _animated ?: dispatch_async(dispatch_get_main_queue(), ^{
        !self.displayLayerCallBack ?: self.displayLayerCallBack();
    });
}

@end

#pragma mark - SegmentContainView

@interface SegmentContainView ()<UICollectionViewDelegate, UICollectionViewDataSource, CALayerDelegate>
@property (strong, nonatomic) SegmentContainCollectionView *collectionView;
@property (weak, nonatomic) SegmentTagView *tagView;

@end

@implementation SegmentContainView

- (void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.layer.delegate = self;
        
        _collectionView = ({
            UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
            flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            
            SegmentContainCollectionView *tempCollection = [[SegmentContainCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
            tempCollection.translatesAutoresizingMaskIntoConstraints = NO;
            tempCollection.showsHorizontalScrollIndicator = NO;
            tempCollection.backgroundColor = UIColor.whiteColor;
            tempCollection.pagingEnabled = YES;
            tempCollection.dataSource = self;
            tempCollection.delegate = self;
            
            [tempCollection registerClass:UICollectionViewCell.class forCellWithReuseIdentifier:NSStringFromClass(UICollectionViewCell.class)];
            
            tempCollection;
        });
        __weak typeof(self) weakSelf = self;
        _collectionView.displayLayerCallBack = ^(){
            __strong typeof(weakSelf) self = weakSelf;
            [self scrollViewDidEndScrolling:self.collectionView animated:self.collectionView.animated];
        };
        
        [self setUpContentView];
        [self scrollToItemAtIndexPath:0];
        [self.layer setNeedsDisplay];
    }
    return self;
}

- (void)setUpContentView{
    [self addSubview:_collectionView];
    [self setUpLayoutContraint:_collectionView view2:self];
}

- (void)setUpLayoutContraint:(UIView *)view1 view2:(UIView *)view2{
    NSLayoutConstraint *leftLayoutConstraint = [NSLayoutConstraint constraintWithItem:view1 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view2 attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f];
    NSLayoutConstraint *topLayoutConstraint = [NSLayoutConstraint constraintWithItem:view1 attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:view2 attribute:NSLayoutAttributeLeft multiplier:1.f constant:0.f];
    NSLayoutConstraint *rightLayoutConstraint = [NSLayoutConstraint constraintWithItem:view1 attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:view2 attribute:NSLayoutAttributeRight multiplier:1.f constant:0.f];
    NSLayoutConstraint *bottomLayoutConstraint = [NSLayoutConstraint constraintWithItem:view1 attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:view2 attribute:NSLayoutAttributeBottom multiplier:1.f constant:0.f];
    [view2 addConstraint:topLayoutConstraint];
    [view2 addConstraint:leftLayoutConstraint];
    [view2 addConstraint:rightLayoutConstraint];
    [view2 addConstraint:bottomLayoutConstraint];
}

- (void)reloadData{
    [_collectionView reloadData];
    
    NSInteger count = [_collectionView numberOfItemsInSection:0];
    NSInteger index = MIN(_collectionView.indexPath.row, count ? count - 1 : 0);
    [self scrollToItemAtIndexPath:index animation:NO];
}

- (void)scrollToItemAtIndexPath:(NSInteger)index{
    [self scrollToItemAtIndexPath:index animation:YES];
}

- (void)scrollToItemAtIndexPath:(NSInteger)index animation:(BOOL)animation{
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:animation];
}

- (void)matchSegmentTagView{
    void (*cImp)(id, SEL, NSInteger) = (void (*)(id, SEL, NSInteger))class_getMethodImplementation(SegmentTagView.superclass, @selector(setTag:));
    SegmentTagView *tempView = [[SegmentTagView alloc] initWithFrame:CGRectZero];
    !cImp ?: cImp(tempView, @selector(setTag:), self.tag);
    
    SegmentTagView *matchTagView = [SegmentTagViews member:tempView];
    [matchTagView setValue:self forKey:@"containView"];
    self.tagView = matchTagView;
}

#pragma mark - CALayerDelegate

- (void)displayLayer:(CALayer *)layer{
    [self matchSegmentTagView];
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [_delegate respondsToSelector:@selector(numberOfSegmentViews)] ? _delegate.numberOfSegmentViews : 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UIView *indexView = [self indexView:indexPath.row];
    indexView.translatesAutoresizingMaskIntoConstraints = NO;
    
    __block BOOL hasAdd = NO;
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(UICollectionViewCell.class) forIndexPath:indexPath];
    !indexView ?: [cell.contentView.subviews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        hasAdd = [obj isEqual:indexView];
        *stop = hasAdd;
    }];
    
    if (indexView) {
        if (hasAdd) {
            [cell.contentView bringSubviewToFront:indexView];
        }else{
            [cell.contentView addSubview:indexView];
            [self setUpLayoutContraint:indexView view2:cell.contentView];
        }
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return self.frame.size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0.f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0.f;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIView<SegmentViewProtocol> *indexView = [self indexView:indexPath.row];
    [self willDisplaying:indexView];
}

- (void)scrollViewDidEndDecelerating:(UICollectionView *)collectionView{
    [self scrollViewDidEndScrollingAnimation:collectionView];
}

- (void)scrollViewDidEndScrollingAnimation:(SegmentContainCollectionView *)collectionView{
    [self scrollViewDidEndScrolling:collectionView animated:YES];
}

- (void)scrollViewDidEndScrolling:(SegmentContainCollectionView *)collectionView animated:(BOOL)animated{
    NSIndexPath *indexPath = [collectionView indexPathForItemAtPoint:collectionView.contentOffset];
    UIView<SegmentViewProtocol> *nextView = [self indexView:indexPath.row];
    
    if ([nextView isEqual:_currentView]) {
        return;
    }
    
    [self didEndDisplaying:_currentView];
    _collectionView.indexPath = indexPath;
    _currentView = nextView;
    [self didDisplaying:_currentView];
    
    [self.tagView scrollViewDidEndScrollingWith:indexPath animated:animated];
}

- (void)scrollViewDidScroll:(UICollectionView *)collectionView{
    if (collectionView.contentOffset.x < 0.f || collectionView.contentOffset.x > collectionView.contentSize.width - CGRectGetWidth(collectionView.bounds)) {
        return;
    }
    
    NSIndexPath *leftIndexPath = [collectionView indexPathForItemAtPoint:collectionView.contentOffset];
    UICollectionViewLayoutAttributes *leftAttributes = [collectionView layoutAttributesForItemAtIndexPath:leftIndexPath];
    if (!(CGRectGetMinX(leftAttributes.frame) < collectionView.contentOffset.x)) {
        return;
    }
    
    [self.tagView scrollViewDidScrollWith:collectionView];
}

- (void)didDisplaying:(UIView<SegmentViewProtocol> *)indexView{
    ![indexView respondsToSelector:@selector(didDisplaying)] ?: [indexView didDisplaying];
}

- (void)willDisplaying:(UIView<SegmentViewProtocol> *)indexView{
    ![indexView respondsToSelector:@selector(willDisplaying)] ?: [indexView willDisplaying];
}

- (void)didEndDisplaying:(UIView<SegmentViewProtocol> *)indexView{
    ![indexView respondsToSelector:@selector(didEndDisplaying)] ?: [indexView didEndDisplaying];
}

- (UIView<SegmentViewProtocol> *)indexView:(NSInteger)index{
    return [_delegate respondsToSelector:@selector(segmentContainForCellAtIndex:)] ? [_delegate segmentContainForCellAtIndex:index] : nil;
}

@end

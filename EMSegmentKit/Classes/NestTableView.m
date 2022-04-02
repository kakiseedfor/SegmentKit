//
//  NestTableView.m
//  FormaxSecurity
//
//  Created by LIYINGPENG on 2018/6/14.
//  Copyright © 2018年 Formax. All rights reserved.
//

#import "UIScrollView+Segment.h"
#import "NestCollectionView.h"
#import "NestViewHeader.h"
#import "NestScrollView.h"
#import "NestTableView.h"

@interface NestTableView () <UIGestureRecognizerDelegate, CALayerDelegate>
@property (weak, nonatomic) UIScrollView<NestScrollViewDelegate> *scrollDelegate;
@property (nonatomic) CGFloat originalOffset;
@property (nonatomic) CGFloat originalPoint;
@property (nonatomic) BOOL finishLayout;
@property (nonatomic) BOOL canMinOffset;
@property (nonatomic) BOOL removeFix;

@end

@implementation NestTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.backgroundColor = UIColor.whiteColor;
        self.showsVerticalScrollIndicator = NO;
        self.alwaysBounceVertical = YES;
        self.layer.delegate = self;
        
        _removeFix = YES;
        _canRefresh = YES;
        _canMinOffset = YES;
        _originalOffset = 0.f;
        _maxOffsetPoint = CGFLOAT_MAX;
        
        [self.layer setNeedsDisplay];
    }
    return self;
}

- (void)displayLayer:(CALayer *)layer{
    if (_finishLayout) {
        return;
    }
    _finishLayout = YES;
    
    UIView *superView = self.superview;
    if (!superView) {
        return;
    }
    
    do {
        if ([superView isKindOfClass:NestScrollView.class] ||
            [superView isKindOfClass:NestTableView.class] ||
            [superView isKindOfClass:NestCollectionView.class])
        {
            _scrollDelegate = (UIScrollView<NestScrollViewDelegate> *)superView;
            break;
        }
        
        superView = superView.superview;
    } while (superView);
    
    _originalOffset = self.contentOffset.y;
    _originalPoint = _scrollDelegate ? CGRectGetMinY([self convertRect:self.bounds toView:_scrollDelegate]) : 0.f;    //无导航栏高度
}

- (void)setContentOffset:(CGPoint)contentOffset{
    CGPoint point = self.contentOffset;
    [super setContentOffset:contentOffset];
    
    if (!_finishLayout) {
        return;
    }
    
    CGFloat offset = self.contentOffset.y;
    CGFloat maxOffsetY = _maxOffsetPoint + _originalOffset;
    if (offset > point.y) { //上拉情况
        if (offset > maxOffsetY) { //超过最大滑动距离
            [super setContentOffset:CGPointMake(point.x, maxOffsetY)];
            _removeFix = NO;
        }else if (offset < _maxOffsetPoint) {   //未超过最大滑动距离
            if (_removeFix) {   //滑动标志已打开
                if (self.currentPoint > self.restOffset) {   //当前位置未到达可滑动位置
                    if (offset < _originalOffset) { //下拉回弹时偏移位置小于原始偏移
                        if (_scrollDelegate.isTop) {    //父View已在原始位置或小于原始偏移
                            [self setDelegateRemoveFix:NO]; //关闭父View的滑动标志
                        }
                    }else{  //下拉时偏移位置大于或等于原始偏移
                        [super setContentOffset:point];
                        [self setDelegateRemoveFix:YES];
                        [self setDelegateCanMinOffset:YES];
                    }
                }
            }else{   //滑动标志已关闭
                [super setContentOffset:CGPointMake(point.x, _originalOffset)];
            }
        }else{
            [super setContentOffset:point];
        }
    }else if (offset < point.y){    //下拉情况
        if (offset > _originalOffset) { //偏移位置大于原始偏移
            if (_removeFix) {   //滑动标志已打开
                if (_scrollDelegate.isTop) {    //父View已在原始位置或小于原始偏移
                    [self setDelegateRemoveFix:NO]; //关闭父View的滑动标志
                }
            }else{   //滑动标志已关闭
                [super setContentOffset:CGPointMake(point.x, maxOffsetY)];
            }
        }else if (offset < _originalOffset){    //下拉偏移位置小于原始偏移
            if (self.currentPoint < _originalPoint) {   //当前位置小于原始位置
                [self setDelegateRemoveFix:YES];    //打开父View的滑动标志
                [super setContentOffset:CGPointMake(point.x, _originalOffset)]; //固定在原始偏移
            }else if (self.currentPoint > _originalPoint){  //当前位置大于原始位置
                if (_removeFix) {   //滑动标志已打开
                    if (_canRefresh) {  //可以下拉刷新
                        if (_originalOffset > offset) { //当前偏移小于原始偏移
                            if (_scrollDelegate.isTop) {    //父View已在原始位置或小于原始偏移
                                [self setDelegateRemoveFix:NO]; //关闭父View的滑动标志
                            }else{
                                [super setContentOffset:CGPointMake(point.x, _originalOffset)];  //固定在原始偏移
                            }
                        }
                    }else{  //不可下拉刷新
                        [self setDelegateRemoveFix:YES];    //打开父View的滑动标志
                        [super setContentOffset:CGPointMake(point.x, _originalOffset)];  //固定在原始偏移
                    }
                }else{  //滑动标志已关闭
                    [self setDelegateRemoveFix:YES];    //打开父View的滑动标志
                    [super setContentOffset:CGPointMake(point.x, _originalOffset)]; //固定在原始偏移
                }
            }else{
                if (_removeFix) {   //滑动标志已打开
                    if (_canRefresh) {  //可以下拉刷新
                        if (_canMinOffset) {
                            
                        }else{
                            [super setContentOffset:CGPointMake(point.x, _originalOffset)];
                        }
                    }else{
                        [self setDelegateCanMinOffset:YES];
                        [super setContentOffset:CGPointMake(point.x, _originalOffset)];
                    }
                }else{  //滑动标志已关闭
                    [super setContentOffset:CGPointMake(point.x, _originalOffset)];
                }
            }
        }else{
            [super setContentOffset:point];
        }
    }else{
        [super setContentOffset:point];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    UIView *otherView = otherGestureRecognizer.view;
    if ([otherView isKindOfClass:UICollectionView.class]) {
        return NO;
    }
    
    if ([otherView isKindOfClass:NestCollectionView.class]) {
        NestCollectionView *collectionView = (NestCollectionView *)otherGestureRecognizer.view;
        UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionView.collectionViewLayout;
        return flowLayout.scrollDirection == UICollectionViewScrollDirectionVertical;
    }
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return [otherGestureRecognizer isKindOfClass:UIScreenEdgePanGestureRecognizer.class];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    [self setDelegateCanMinOffset:NO];
    return YES;
}

- (void)setDelegateCanMinOffset:(BOOL)canMinOffset{
    [_scrollDelegate setValue:@(canMinOffset) forKey:@"canMinOffset"];
}

- (void)setDelegateRemoveFix:(BOOL)removeFix{
    [_scrollDelegate setValue:@(removeFix) forKey:@"removeFix"];
}

- (CGFloat)navigationBarHeight{
    return CGRectGetHeight(self.currentVC.navigationController.navigationBar.frame) + CGRectGetHeight(UIApplication.sharedApplication.statusBarFrame);
}

//在父View的偏移
- (CGFloat)restOffset{
    return _originalPoint - _scrollDelegate.maxOffsetPoint + _scrollDelegate.restOffset;
}

/**
包含导航栏高度
*/
- (CGFloat)currentPoint{
    CGRect rect = [self convertRect:self.bounds toView:UIApplication.sharedApplication.keyWindow];
    return roundf(CGRectGetMinY(rect)) - (ABS(_originalOffset) > 0.f ? 0.f : self.navigationBarHeight);
}

- (BOOL)isTop{
    return !(self.contentOffset.y > _originalOffset) && (_scrollDelegate ? _scrollDelegate.isTop : YES);
}

@end

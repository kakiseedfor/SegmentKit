//
//  SegmentTagView.m
//  globalwin
//
//  Created by kakiYen on 2018/7/31.
//  Copyright © 2018年 taojinzhe. All rights reserved.
//

#import "SegmentContainView.h"
#import "SegmentTagView.h"

#define SEGMENT_EdgeInsets UIEdgeInsetsMake(0.f, 8.f, 0.f, 8.f)
#define SEGMENT_TEXT_FONT_16 [UIFont systemFontOfSize:16.f]
#define UNDER_LINE_HEIGHT 4.f
#define UNDER_LINE_WIDTH 20.f

NSHashTable<SegmentTagView *> *SegmentTagViews = nil;

#pragma mark - SegmentTagCell

@interface SegmentTagCell : UICollectionViewCell
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIColor *normalColor;
@property (strong, nonatomic) UIColor *selectedColor;

@end

@implementation SegmentTagCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        _selectedColor = [UIColor colorWithRed:221.f / 255.f green:0.f blue:15.f / 255.f alpha:1.f];
        _normalColor = [UIColor colorWithRed:152.f / 255.f green:156.f / 255.f blue:163.f / 255.f alpha:1.f];
        _titleLabel = ({
            UILabel *temp = [[UILabel alloc] init];
            temp.translatesAutoresizingMaskIntoConstraints = NO;
            temp.textAlignment = NSTextAlignmentCenter;
            temp.textColor = _normalColor;
            temp.font = SEGMENT_TEXT_FONT_16;
            temp;
        });
        [self setContentView];
        
        self.selected = NO;
    }
    
    return self;
}

- (void)setContentView{
    [self.contentView addSubview:_titleLabel];
    NSLayoutConstraint *leftLayoutConstraint = [NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f];
    NSLayoutConstraint *topLayoutConstraint = [NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.f constant:0.f];
    NSLayoutConstraint *rightLayoutConstraint = [NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.f constant:0.f];
    NSLayoutConstraint *bottomLayoutConstraint = [NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.f constant:0.f];
    [self.contentView addConstraint:topLayoutConstraint];
    [self.contentView addConstraint:leftLayoutConstraint];
    [self.contentView addConstraint:rightLayoutConstraint];
    [self.contentView addConstraint:bottomLayoutConstraint];
}

- (void)setTheSelected:(BOOL)selected{
    _titleLabel.textColor = selected ? _selectedColor : _normalColor;
}

@end

#pragma mark - SegmentTagCollectionView

@interface SegmentTagCollectionView : UICollectionView
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) UIView *undelLineView;
@property (nonatomic) BOOL animated;

@end

@implementation SegmentTagCollectionView

- (void)dealloc
{
    NSLog(@"%s",__FUNCTION__);
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    
    if (self) {
        _undelLineView = ({
            UIView *temp = [[UIView alloc] init];
            temp.backgroundColor = [UIColor colorWithRed:221.f / 255.f green:0.f blue:15.f / 255.f alpha:1.f];
            temp;
        });
        [self addSubview:_undelLineView];
    }
    
    return self;
}

- (void)scrollToItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
    CGFloat offset = attributes.center.x - CGRectGetWidth(self.bounds) / 2;
    CGFloat rest = self.contentSize.width - CGRectGetWidth(self.bounds);
    [self setContentOffset:CGPointMake(offset > 0 ? (rest > offset ? offset : (rest > 0 ? rest : self.contentOffset.x)) : 0.f, 0.f) animated:animated];
    
    NSInteger count = [self numberOfItemsInSection:0];
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:2];
    if (_indexPath && _indexPath.row < count && ![_indexPath isEqual:indexPath]) {
        [tempArray addObject:_indexPath];
    }
    [tempArray addObject:indexPath];
    _indexPath = indexPath;
    [self reloadItemsAtIndexPaths:tempArray];
    animated ?: [self updateUndelLineViewPoint:attributes.center.x - UNDER_LINE_WIDTH / 2];
}

- (void)updateUndelLineViewPoint:(CGFloat)xPoint{
    _undelLineView.frame = CGRectMake(xPoint, CGRectGetHeight(self.bounds) - UNDER_LINE_HEIGHT, UNDER_LINE_WIDTH, UNDER_LINE_HEIGHT);
}

@end

#pragma mark - SegmentTagView

@interface SegmentTagView ()<UICollectionViewDataSource>
@property (weak, nonatomic) SegmentContainView *containView;
@property (strong, nonatomic) SegmentTagCollectionView *collectionView;
@property (strong, nonatomic) NSArray<NSNumber *> *sizeArray;

@end

@implementation SegmentTagView

- (void)dealloc{
    NSLog(@"%s",__FUNCTION__);
    [SegmentTagViews removeObject:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        if (!SegmentTagViews) {
            SegmentTagViews = NSHashTable.weakObjectsHashTable;
        }
        self.tag = 0;
        
        _collectionView = ({
            UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
            flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            
            SegmentTagCollectionView *tempCollection = [[SegmentTagCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
            tempCollection.translatesAutoresizingMaskIntoConstraints = NO;
            tempCollection.showsHorizontalScrollIndicator = NO;
            tempCollection.backgroundColor = UIColor.clearColor;
            tempCollection.dataSource = self;
            tempCollection.delegate = self;
            
            [tempCollection registerClass:SegmentTagCell.class forCellWithReuseIdentifier:NSStringFromClass(SegmentTagCell.class)];
            tempCollection;
        });
        
        [self setUpContentView];
    }
    return self;
}

- (void)setUpContentView{
    [self addSubview:_collectionView];
    NSLayoutConstraint *leftLayoutConstraint = [NSLayoutConstraint constraintWithItem:_collectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f];
    NSLayoutConstraint *topLayoutConstraint = [NSLayoutConstraint constraintWithItem:_collectionView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.f constant:0.f];
    NSLayoutConstraint *rightLayoutConstraint = [NSLayoutConstraint constraintWithItem:_collectionView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.f constant:0.f];
    NSLayoutConstraint *bottomLayoutConstraint = [NSLayoutConstraint constraintWithItem:_collectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.f constant:0.f];
    [self addConstraint:topLayoutConstraint];
    [self addConstraint:leftLayoutConstraint];
    [self addConstraint:rightLayoutConstraint];
    [self addConstraint:bottomLayoutConstraint];
}

- (void)reloadData{
    _sizeArray = nil;
    [_collectionView reloadData];
}

- (NSArray<NSNumber *> *)sizeArray{
    if (!_sizeArray) {
        NSInteger count = [_collectionView numberOfItemsInSection:0];
        if (!count) {
            return nil;
        }
        
        CGFloat wholeLength = 0.f;
        NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:count];
        for (NSInteger i = 0; i < count; i++) {
            NSString *text = [self stringForItemAtIndexPath:i];
            CGSize size = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : SEGMENT_TEXT_FONT_16} context:NULL].size;
            wholeLength += size.width;
            
            [tempArray addObject:@(size.width + 16.f)];
        }
        
        if (wholeLength < CGRectGetWidth(_collectionView.bounds)) {
            [tempArray removeAllObjects];
            
            CGFloat offset = (CGRectGetWidth(_collectionView.bounds) - wholeLength - SEGMENT_EdgeInsets.left - SEGMENT_EdgeInsets.right) / count;
            for (NSInteger i = 0; i < count; i++) {
                NSString *text = [self stringForItemAtIndexPath:i];
                CGSize size = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : SEGMENT_TEXT_FONT_16} context:NULL].size;
                [tempArray addObject:@(size.width + offset)];
            }
        }
        
        _sizeArray = tempArray.copy;
    }
    return _sizeArray;
}

#pragma mark - Hash

- (void)setTag:(NSInteger)tag{
    [SegmentTagViews removeObject:self];
    [super setTag:tag];
    [SegmentTagViews addObject:self];
}

- (BOOL)isEqual:(id)other
{
    if (![other isKindOfClass:SegmentTagView.class]) {
        return NO;
    }
    return self.tag == [other tag];
}

- (NSUInteger)hash
{
    return self.tag;
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [_delegate respondsToSelector:@selector(numberOfSegmentTags)] ? _delegate.numberOfSegmentTags : 0;
}

- (UICollectionViewCell *)collectionView:(SegmentTagCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SegmentTagCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(SegmentTagCell.class) forIndexPath:indexPath];
    cell.titleLabel.text = [self stringForItemAtIndexPath:indexPath.row];
    [cell setTheSelected:[indexPath isEqual:collectionView.indexPath]];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.sizeArray[indexPath.row].floatValue, CGRectGetHeight(collectionView.bounds));
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return SEGMENT_EdgeInsets;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0.f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0.f;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [_containView scrollToItemAtIndexPath:indexPath.row];
}

- (void)scrollViewDidEndScrollingWith:(NSIndexPath *)indexPath animated:(BOOL)animated{
    NSInteger count = [_collectionView numberOfItemsInSection:0];
    if (count && indexPath.row < count) {
        [_collectionView scrollToItemAtIndexPath:indexPath animated:animated];
    }
}

- (void)scrollViewDidScrollWith:(UICollectionView *)collectionView{
    NSInteger count = [_collectionView numberOfItemsInSection:0];
    if (!count) {
        return;
    }
    
    NSIndexPath *leftIndexPath = [collectionView indexPathForItemAtPoint:collectionView.contentOffset];
    NSIndexPath *rightIndexPath = [NSIndexPath indexPathForRow:leftIndexPath.row + 1 inSection:leftIndexPath.section];
    UICollectionViewLayoutAttributes *theLeftAttributes = [collectionView layoutAttributesForItemAtIndexPath:leftIndexPath];
    CGFloat ratio = (CGRectGetMaxX(theLeftAttributes.frame) - collectionView.contentOffset.x) / CGRectGetWidth(theLeftAttributes.frame);
    
    UICollectionViewLayoutAttributes *leftAttributes = [_collectionView layoutAttributesForItemAtIndexPath:leftIndexPath];
    UICollectionViewLayoutAttributes *rightAttributes = [_collectionView layoutAttributesForItemAtIndexPath:rightIndexPath] ?: leftAttributes;
    CGFloat offset = rightAttributes.center.x - leftAttributes.center.x;
    [_collectionView updateUndelLineViewPoint:leftAttributes.center.x + offset * (1.f - ratio) - UNDER_LINE_WIDTH / 2];
}

- (NSString *)stringForItemAtIndexPath:(NSInteger)index{
    return [_delegate respondsToSelector:@selector(stringForItemAtIndexPath:)] ? [_delegate stringForItemAtIndexPath:index] : @"";
}

@end

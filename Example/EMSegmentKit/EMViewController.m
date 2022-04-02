//
//  EMViewController.m
//  EMSegmentKit
//
//  Created by kakiYen on 06/22/2020.
//  Copyright (c) 2020 kakiYen. All rights reserved.
//

#import <EMSegmentKit/SegmentContainView.h>
#import <EMSegmentKit/NestCollectionView.h>
#import <EMSegmentKit/SegmentTagView.h>
#import <EMSegmentKit/NestScrollView.h>
#import <EMSegmentKit/NestTableView.h>
#import <EMSegmentKit/AnimationLayer.h>
#import <Masonry/Masonry.h>
#import "EMViewController.h"

#pragma mark - EMLayerView

@interface EMLayerView : UIView

@end

@implementation EMLayerView

+ (Class)layerClass{
    return AnimationLayer.class;
}

@end

#pragma mark - EMTiledLayer

@interface EMTiledLayer : CATiledLayer<CALayerDelegate>
@property (strong, nonatomic) NSString *imagePath;

@end

@implementation EMTiledLayer

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.delegate = self;
    }
    return self;
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx{
    NSString *imageName = _imagePath.stringByDeletingPathExtension.lastPathComponent;
    
    CGRect clipRect = CGContextGetClipBoundingBox(ctx);
    NSInteger row = floor(CGRectGetMinY(clipRect) / self.tileSize.height);
    NSInteger col = floor(CGRectGetMinX(clipRect) / self.tileSize.width);
    
    NSString *sandBoxDocumentpath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *filePath = [NSString stringWithFormat:@"%@/%@_%02lu_%02lu.JPG",sandBoxDocumentpath, imageName, row, col];
    UIImage *tiledImage = [UIImage imageWithContentsOfFile:filePath];
    
    UIGraphicsPushContext(ctx);
    [tiledImage drawInRect:clipRect];
    UIGraphicsPopContext();
}

- (void)setImagePath:(NSString *)imagePath{
    _imagePath = imagePath;
    
    UIImage *image = [UIImage imageWithContentsOfFile:_imagePath];
    self.frame = CGRectMake(0.f, 0.f, image.size.width, image.size.height);
    
    NSString *sandBoxDocumentpath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *imageName = imagePath.stringByDeletingPathExtension.lastPathComponent;
    NSString *oneOfImagePath = [NSString stringWithFormat:@"%@/%@_00_00.JPG",sandBoxDocumentpath, imageName];
    if ([NSFileManager.defaultManager fileExistsAtPath:oneOfImagePath]) {
        [self setNeedsDisplay];
        return;
    }
    
    CGSize tiledSize = self.tileSize;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGImageRef imageRef = image.CGImage;
        NSUInteger rows = ceil(image.size.height / tiledSize.height);
        NSUInteger cols = ceil(image.size.width / tiledSize.width);

        for (NSUInteger row = 0; row < rows; row++) {
            for (NSUInteger col = 0; col < cols; col++) {
                CGRect tilesRect = CGRectMake(tiledSize.width * col, tiledSize.height * row, tiledSize.width, tiledSize.height);
                CGImageRef tiledImageRef = CGImageCreateWithImageInRect(imageRef, tilesRect);
                UIImage *tiledImage = [UIImage imageWithCGImage:tiledImageRef scale:image.scale orientation:image.imageOrientation];
                NSData *tiledData = UIImageJPEGRepresentation(tiledImage, 1);

                NSString *filePath = [NSString stringWithFormat:@"%@/%@_%02lu_%02lu.JPG",sandBoxDocumentpath, imageName, row, col];
                [tiledData writeToFile:filePath atomically:YES];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setNeedsDisplay];
        });
    });
}

@end

#pragma mark - EMScrollSegmentView

@interface EMScrollSegmentView : UIView<SegmentViewProtocol>
@property (strong, nonatomic) NestScrollView *scrollView;

@end

@implementation EMScrollSegmentView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addSubviews];
        [self makeViewConstraints];
    }
    return self;
}

- (void)addSubviews{
    _scrollView = ({
        NestScrollView *scrollView = [[NestScrollView alloc] init];
        scrollView.showsVerticalScrollIndicator = YES;
        scrollView;
    });
    EMTiledLayer *tileLayer = ({
        EMTiledLayer *tmpTiledLayer = [[EMTiledLayer alloc] init];
        tmpTiledLayer.imagePath = [NSBundle.mainBundle pathForResource:@"RicePaddy" ofType:@"JPG"];
        tmpTiledLayer;
    });
    [_scrollView.contentView.layer addSublayer:tileLayer];
    
    UIView *tempView = [[UIView alloc] init];
    [_scrollView.contentView addSubview:tempView];
    [tempView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView.contentView);
        make.height.mas_equalTo(CGRectGetHeight(tileLayer.frame));
        make.width.mas_equalTo(CGRectGetWidth(tileLayer.frame));
    }];
    
    [self addSubview:_scrollView];
}

- (void)makeViewConstraints{
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)didDisplaying{
    NSLog(@"%s",__FUNCTION__);
}

- (void)willDisplaying{
    NSLog(@"%s",__FUNCTION__);
}

- (void)didEndDisplaying{
    NSLog(@"%s",__FUNCTION__);
}

@end

#pragma mark - EMCollectSegmentView

@interface EMCollectSegmentCell : UICollectionViewCell
@property (strong, nonatomic) UILabel *textLabel;
@property (strong, nonatomic) UILabel *detailTextLabel;

@end

@implementation EMCollectSegmentCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = UIColor.whiteColor;
        [self addSubviews];
        [self makeViewConstraints];
    }
    return self;
}

- (void)addSubviews{
    _textLabel = ({
        UILabel *temp = [[UILabel alloc] init];
        temp.font = [UIFont systemFontOfSize:16.f];
        temp;
    });
    _detailTextLabel = ({
        UILabel *temp = [[UILabel alloc] init];
        temp.font = [UIFont systemFontOfSize:12.f];
        temp;
    });
    [self.contentView addSubview:_textLabel];
    [self.contentView addSubview:_detailTextLabel];
}

- (void)makeViewConstraints{
    [_textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(16.f);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    [_detailTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-16.f);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
}

@end

@interface EMCollectSegmentView : UIView<SegmentViewProtocol, UICollectionViewDelegate, UICollectionViewDataSource>
@property (strong, nonatomic) NestCollectionView *collectionView;

@end

@implementation EMCollectSegmentView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addSubviews];
        [self makeViewConstraints];
    }
    return self;
}

- (void)addSubviews{
    _collectionView = ({
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        NestCollectionView *collectionView = [[NestCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        collectionView.showsVerticalScrollIndicator = YES;
        collectionView.dataSource = self;
        collectionView.delegate = self;
        [collectionView registerClass:EMCollectSegmentCell.class forCellWithReuseIdentifier:NSStringFromClass(EMCollectSegmentCell.class)];
        collectionView;
    });
    [self addSubview:_collectionView];
}

- (void)makeViewConstraints{
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)didDisplaying{
    NSLog(@"%s",__FUNCTION__);
}

- (void)willDisplaying{
    NSLog(@"%s",__FUNCTION__);
}

- (void)didEndDisplaying{
    NSLog(@"%s",__FUNCTION__);
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0.f;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(CGRectGetWidth(collectionView.bounds), 44.f);
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    EMCollectSegmentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(EMCollectSegmentCell.class) forIndexPath:indexPath];
    cell.textLabel.text = @"CollectionView";
    cell.detailTextLabel.text = [NSString stringWithFormat:@"第%ld个",(long)indexPath.row];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 64;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

@end

#pragma mark - EMTableSegmentCell

@interface EMTableSegmentCell : UITableViewCell<SegmentTagProtocol, SegmentContainProtocol>
@property (strong, nonatomic) SegmentContainView *segmentContainView;
@property (strong, nonatomic) SegmentTagView *segmentTagView;
@property (strong, nonatomic) NSArray *titleArray;
@property (strong, nonatomic) NSArray *viewArray;

@end

@implementation EMTableSegmentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        _titleArray = @[@"UIScrollView", @"UICollectionView"];
        _viewArray = @[[[EMScrollSegmentView alloc] init],
                       [[EMCollectSegmentView alloc] init]];
        
        [self addSubviews];
        [self makeViewConstraints];
    }
    
    return self;
}

- (void)addSubviews{
    _segmentTagView = ({
        SegmentTagView *tagView = [[SegmentTagView alloc] init];
        tagView.delegate = self;
        tagView.tag = 101;
        tagView;
    });
    _segmentContainView = ({
        SegmentContainView *containView = [[SegmentContainView alloc] init];
        containView.delegate = self;
        containView.tag = 101;
        containView;
    });
    [self.contentView addSubview:_segmentTagView];
    [self.contentView addSubview:_segmentContainView];
}

- (void)makeViewConstraints{
    [_segmentTagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.contentView);
        make.height.mas_equalTo(48.f);
    }];
    
    [_segmentContainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.contentView);
        make.top.equalTo(self.segmentTagView.mas_bottom);
    }];
}

#pragma mark - SegmentTagProtocol

- (NSInteger)numberOfSegmentTags{
    return _titleArray.count;
}

- (NSString *)stringForItemAtIndexPath:(NSInteger)index{
    return _titleArray[index];
}

#pragma mark - SegmentContainProtocol

- (NSInteger)numberOfSegmentViews{
    return _viewArray.count;
}

- (UIView<SegmentViewProtocol> *)segmentContainForCellAtIndex:(NSInteger)index{
    return _viewArray[index];
}

@end

#pragma mark - EMTableSegmentView

@interface EMTableSegmentView : UIView<SegmentViewProtocol, UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) NestTableView *tableView;

@end

@implementation EMTableSegmentView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addSubviews];
        [self makeViewConstraints];
    }
    return self;
}

- (void)addSubviews{
    _tableView = ({
        NestTableView *tableView = [[NestTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, CGRectGetWidth(self.bounds), 128.f)];
        tableView.tableHeaderView.backgroundColor = UIColor.cyanColor;
        tableView.showsVerticalScrollIndicator = YES;
        tableView.maxOffsetPoint = 128.f;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.canRefresh = NO;
        [tableView registerClass:EMTableSegmentCell.class forCellReuseIdentifier:NSStringFromClass(EMTableSegmentCell.class)];
        tableView;
    });
    [self addSubview:_tableView];
}

- (void)makeViewConstraints{
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)didDisplaying{
    NSLog(@"%s",__FUNCTION__);
}

- (void)willDisplaying{
    NSLog(@"%s",__FUNCTION__);
}

- (void)didEndDisplaying{
    NSLog(@"%s",__FUNCTION__);
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    EMTableSegmentCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(EMTableSegmentCell.class) forIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CGRectGetHeight(tableView.bounds);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

@end

#pragma mark - EMViewController

@interface EMViewController ()<SegmentTagProtocol, SegmentContainProtocol>
@property (strong, nonatomic) SegmentContainView *segmentContainView;
@property (strong, nonatomic) SegmentTagView *segmentTagView;
@property (strong, nonatomic) NestScrollView *scrollView;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) NSArray *titleArray;
@property (strong, nonatomic) NSArray *viewArray;

@end

@implementation EMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self layoutSubviews];
    [self makeViewConstraints];
}

- (void)layoutSubviews{
    _scrollView = ({
        NestScrollView *scrollView = [[NestScrollView alloc] init];
        scrollView.maxOffsetPoint = 256.f;
        scrollView;
    });
    _contentView = ({
        UILabel *label = [[UILabel alloc] init];
        label.text = @"NestScrollView";
        
        EMLayerView *tempView= [[EMLayerView alloc] init];
        tempView.backgroundColor = UIColor.redColor;
        [tempView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(tempView);
        }];
        
        tempView;
    });
    _segmentTagView = ({
        SegmentTagView *tagView = [[SegmentTagView alloc] init];
        tagView.delegate = self;
        tagView;
    });
    _segmentContainView = ({
        SegmentContainView *containView = [[SegmentContainView alloc] init];
        containView.delegate = self;
        containView;
    });
    
    [_scrollView.contentView addSubview:_contentView];
    [_scrollView.contentView addSubview:_segmentTagView];
    [_scrollView.contentView addSubview:_segmentContainView];
    [self.view addSubview:_scrollView];
}

- (void)makeViewConstraints{
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.scrollView.contentView);
        make.height.mas_equalTo(256.f);
    }];
    
    [_segmentTagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.scrollView.contentView);
        make.top.equalTo(self.contentView.mas_bottom);
        make.height.mas_equalTo(48.f);
    }];
    
    CGFloat navStatusHeight = CGRectGetHeight(self.navigationController.navigationBar.frame) + CGRectGetHeight(UIApplication.sharedApplication.statusBarFrame);
    [_segmentContainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(CGRectGetHeight(UIScreen.mainScreen.bounds) - 48.f - navStatusHeight);
        make.bottom.equalTo(self.scrollView.contentView.mas_bottom);
        make.left.right.equalTo(self.scrollView.contentView);
        make.top.equalTo(self.segmentTagView.mas_bottom);
    }];
}

- (IBAction)refreshAction:(id)sender {
    _titleArray = @[@"UIScrollView", @"UITableView", @"UICollectionView"];
    _viewArray = @[[[EMScrollSegmentView alloc] init],
                   [[EMTableSegmentView alloc] init],
                   [[EMCollectSegmentView alloc] init]];
    [_segmentTagView reloadData];
    [_segmentContainView reloadData];
}

- (IBAction)stopAction:(id)sender {
    _titleArray = @[@"UICollectionView"];
    _viewArray = @[[[EMCollectSegmentView alloc] init]];
    [_segmentTagView reloadData];
    [_segmentContainView reloadData];
}

- (IBAction)composeAction:(id)sender {
    [(AnimationLayer *)_contentView.layer setHidden:!_contentView.layer.isHidden animation:YES];
}

#pragma mark - SegmentTagProtocol

- (NSInteger)numberOfSegmentTags{
    return _titleArray.count;
}

- (NSString *)stringForItemAtIndexPath:(NSInteger)index{
    return _titleArray[index];
}

#pragma mark - SegmentContainProtocol

- (NSInteger)numberOfSegmentViews{
    return _viewArray.count;
}

- (UIView<SegmentViewProtocol> *)segmentContainForCellAtIndex:(NSInteger)index{
    return _viewArray[index];
}

@end

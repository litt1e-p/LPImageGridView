// The MIT License (MIT)
//
// Copyright (c) 2017-2018 litt1e-p ( https://github.com/litt1e-p )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import "LPImageGridView.h"
#import "LPImageGridLayout.h"
#import "LPImageGridViewCell.h"

@interface LPImageGridView ()<UICollectionViewDelegate, UICollectionViewDataSource, LPCollectionViewItemSizeLayoutDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) LPImageGridLayout *layout;


@end

@implementation LPImageGridView

static NSString * const kLPImageGridViewCellID = @"kLPImageGridViewCellID";

- (instancetype)initWithImages:(NSArray *)images
{
    if (self = [super init]) {
        self.images = [images copy];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initViews];
}

- (void)initViews
{
    [self.view addSubview:self.collectionView];
    [self.collectionView registerClass:[LPImageGridViewCell class] forCellWithReuseIdentifier:kLPImageGridViewCellID];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.images.count > 0 ? 1 : 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LPImageGridViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kLPImageGridViewCellID forIndexPath:indexPath];
    cell.enableEditState      = self.enableEditState;
    cell.btnTintColor         = self.btnTintColor;
    if ([self.images[indexPath.item] isKindOfClass:[NSString class]]) {
        [cell assignCellWithImageUrl:self.images[indexPath.item]];
    } else if ([self.images[indexPath.item] isKindOfClass:[UIImage class]]) {
        [cell assignCellWithImage:self.images[indexPath.item]];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat length = (collectionView.bounds.size.width - 5) / 4.f;
    return CGSizeMake(length, length);
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.enableEditState) {
        [self respondsToDelegate];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.enableEditState) {
        [self respondsToDelegate];
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(imageGridView:didSelectedImageWithIndex:)]) {
            [self.delegate imageGridView:self didSelectedImageWithIndex:indexPath.item];
        }
    }
}

- (void)respondsToDelegate
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageGridView:didPickedImagesWithIndexes:)]) {
        NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
        NSMutableArray *indexes = [NSMutableArray array];
        for (NSIndexPath *idx in indexPaths) {
            [indexes addObject:@(idx.item)];
        }
        [self.delegate imageGridView:self didPickedImagesWithIndexes:indexes];
    }
}

- (void)setBtnTintColor:(UIColor *)btnTintColor
{
    if (btnTintColor && btnTintColor != _btnTintColor) {
        _btnTintColor = btnTintColor;
    }
}

- (void)setEnableEditState:(BOOL)enableEditState
{
    if (enableEditState != _enableEditState) {
        _enableEditState = enableEditState;
        if (!enableEditState) {
            NSArray *selectedIndexPaths = [self.collectionView indexPathsForSelectedItems];
            for (NSIndexPath *indexPath in selectedIndexPaths) {
                [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
            }
            [self respondsToDelegate];
        }
        [self refreshViews];
    }
}

- (void)refreshViews
{
    __weak typeof(self)ws = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [ws.collectionView reloadData];
    });
}

- (LPImageGridLayout *)layout
{
    if (!_layout) {
        _layout          = [[LPImageGridLayout alloc] init];
        _layout.delegate = self;
    }
    return _layout;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        _collectionView                         = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.layout];
        _collectionView.backgroundColor         = [UIColor whiteColor];
        _collectionView.alwaysBounceVertical    = YES;
        _collectionView.allowsMultipleSelection = YES;
        _collectionView.delegate                = self;
        _collectionView.dataSource              = self;
    }
    return _collectionView;
}

@end

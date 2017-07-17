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

#import "LPImageGridLayout.h"
#define IsEmptyRect(_ref) (CGRectIsEmpty(_ref) || CGRectIsNull(_ref) || (CGRectEqualToRect((_ref), CGRectZero)))

@interface LPImageGridLayout()

@property (nonatomic, strong) NSMutableArray *attrs;
@property (nonatomic, assign) CGFloat contentY;
@property (nonatomic, assign) CGSize newBoundsSize;
@end

@implementation LPImageGridLayout

static CGFloat const kItemsMargin = 1;

- (void)prepareLayout
{
    [super prepareLayout];
    [self.attrs removeAllObjects];
    self.contentY = 0;
    UICollectionViewLayoutAttributes *prevAttr;
    NSUInteger n = self.collectionView.numberOfSections;
    for (int i = 0; i < n; i++) {
        NSUInteger c = [self.collectionView numberOfItemsInSection:i];
        prevAttr = [[UICollectionViewLayoutAttributes alloc] init];
        for (int j = 0; j < c; j++) {
            if (j == 0) {
                NSIndexPath *headerIndexPath = [NSIndexPath indexPathForItem:j inSection:i];
                UICollectionViewLayoutAttributes *headerAttr = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:headerIndexPath];
                [self.attrs addObject:headerAttr];
                self.contentY += headerAttr.frame.size.height + kItemsMargin;
            }
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:i];
            CGSize s = [self evaluatedItemSize:indexPath];
            CGFloat x = kItemsMargin;
            UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            CGFloat pMaxX = IsEmptyRect(prevAttr.frame) ? x : CGRectGetMaxX(prevAttr.frame) + kItemsMargin;
            if (pMaxX + s.width + kItemsMargin > self.collectionView.frame.size.width) {
                self.contentY += s.height + kItemsMargin;
            } else {
                x = pMaxX;
            }
            CGFloat y = self.contentY;
            attr.frame = CGRectMake(x, y, s.width, s.height);
            [self.attrs addObject:attr];
            prevAttr = attr;
            if (j == c - 1) {
                self.contentY += s.height;
                UICollectionViewLayoutAttributes *footerAttr = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter atIndexPath:indexPath];
                [self.attrs addObject:footerAttr];
                self.contentY += footerAttr.frame.size.height + kItemsMargin;
            }
        }
    }
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:elementKind withIndexPath:indexPath];
    CGSize size = [self evaluateSupplementaryElementSizeForKind:elementKind AtIndexPath:indexPath];
    attr.frame = CGRectMake(0, _contentY, size.width, size.height);
    return attr;
}

- (CGSize)evaluatedItemSize:(NSIndexPath *)indexPath
{
    if (!self.delegate || ![self.delegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)]) {
        return self.itemSize;
    }
    return [self.delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];
}

- (CGSize)evaluateSupplementaryElementSizeForKind:(NSString *)kind AtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.delegate) {
        return [kind isEqualToString:UICollectionElementKindSectionHeader] ? self.headerReferenceSize : self.footerReferenceSize;
    }
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForHeaderInSection:)]) {
            return [self.delegate collectionView:self.collectionView layout:self referenceSizeForHeaderInSection:indexPath.section];
        }
        return self.headerReferenceSize;
    } else {
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForFooterInSection:)]) {
            return [self.delegate collectionView:self.collectionView layout:self referenceSizeForFooterInSection:indexPath.section];
        }
        return self.footerReferenceSize;
    }
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return self.attrs;
}

- (CGSize)collectionViewContentSize
{
    [super collectionViewContentSize];
    return CGSizeMake(0, self.contentY);
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    if (CGSizeEqualToSize(newBounds.size, _newBoundsSize)) {
        return NO;
    }
    _newBoundsSize = newBounds.size;
    return YES;
}

- (NSMutableArray *)attrs
{
    if (!_attrs) {
        _attrs = [[NSMutableArray alloc] init];
    }
    return _attrs;
}

@end

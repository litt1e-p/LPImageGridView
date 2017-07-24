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

#import "LPImageGridViewCell.h"
#import "Masonry.h"
#import "FLAnimatedImageView.h"
#import "UIImageView+WebCache.h"

@interface UIImage (MyBundle)

+ (UIImage *)imageNamedFromMyBundle:(NSString *)name;

@end

@implementation UIImage (MyBundle)

//+ (UIImage *)imageNamedFromMyBundle:(NSString *)name {
//    UIImage *image = [UIImage imageNamed:[@"LPImageGridView.bundle" stringByAppendingPathComponent:name]];
//    if (image) {
//        return image;
//    } else {
//        image = [UIImage imageNamed:[@"Frameworks/LPImageGridView.framework/LPImageGridView.bundle" stringByAppendingPathComponent:name]];
//        if (!image) {
//            image = [UIImage imageNamed:name];
//        }
//        return image;
//    }
//}

+ (UIImage *)imageNamedFromMyBundle:(NSString *)imageName
{
    NSBundle *bundle = [NSBundle bundleForClass:[LPImageGridView class]];
    NSURL *bundleUrl = [bundle URLForResource:@"LPImageGridView" withExtension:@"bundle"];
    NSBundle *defaultBundle = [NSBundle bundleWithURL:bundleUrl];
    return [UIImage imageWithContentsOfFile:[defaultBundle pathForResource:imageName ofType:"png"]];
}

- (UIImage *)imageMaskedWithColor:(UIColor *)maskColor
{
    NSParameterAssert(maskColor != nil);
    CGRect imageRect = CGRectMake(0.0f, 0.0f, self.size.width, self.size.height);
    UIImage *newImage = nil;
    UIGraphicsBeginImageContextWithOptions(imageRect.size, NO, self.scale);
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(context, 1.0f, -1.0f);
        CGContextTranslateCTM(context, 0.0f, -(imageRect.size.height));
        CGContextClipToMask(context, imageRect, self.CGImage);
        CGContextSetFillColorWithColor(context, maskColor.CGColor);
        CGContextFillRect(context, imageRect);
        newImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    return newImage;
}

@end

@interface LPImageGridViewCell()

@property (nonatomic, strong) UIButton *checkBtn;
@property (nonatomic, strong) FLAnimatedImageView *imageView;

@end

@implementation LPImageGridViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initSubViews];
    }
    return self;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (_enableEditState) {
        self.checkBtn.selected = selected;
        self.imageView.alpha = selected ? 0.8 : 1.f;
    }
}

- (void)setEnableEditState:(BOOL)enableEditState
{
    _enableEditState = enableEditState;
    self.checkBtn.hidden = !enableEditState;
}

- (void)setBtnTintColor:(UIColor *)btnTintColor
{
    _btnTintColor = btnTintColor;
    [self configThemeWithColor:btnTintColor];
}

- (void)assignCellWithImageUrl:(NSString *)imageUrl
{
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (cacheType == SDImageCacheTypeNone) {
            self.imageView.alpha = 0;
            [UIView animateWithDuration:0.25 animations:^{
                self.imageView.alpha = 1;
            }];
        } else {
            self.imageView.alpha = 1;
        }
        if ([imageUrl hasSuffix:@".gif"]) {
            [self.imageView startAnimating];
        }
    }];
}

- (void)assignCellWithImage:(UIImage *)image
{
    self.imageView.image = image;
}

- (void)configThemeWithColor:(UIColor *)color
{
    UIImage *defaultImg  = [UIImage imageNamedFromMyBundle:@"select_default@2x"];
    UIImage *selectedImg = [UIImage imageNamedFromMyBundle:@"select_selected@2x"];
    if (color) {
        selectedImg = [defaultImg imageMaskedWithColor:color];
    }
    [self.checkBtn setImage:defaultImg forState:UIControlStateNormal];
    [self.checkBtn setImage:selectedImg forState:UIControlStateSelected];
}

- (void)initSubViews
{
    self.contentView.layer.borderColor = [UIColor colorWithRed:227/255.f green:227/255.f blue:227/255.f alpha:1.f].CGColor;
    self.contentView.layer.borderWidth = 0.5f;
    
    self.imageView               = [[FLAnimatedImageView alloc] init];
    self.imageView.contentMode   = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    [self.contentView addSubview:self.imageView];
    
    self.checkBtn        = [UIButton buttonWithType:UIButtonTypeCustom];
    [self configThemeWithColor:nil];
    self.checkBtn.hidden = YES;
    [self.contentView addSubview:self.checkBtn];

    [self.checkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(2);
        make.trailing.equalTo(self.contentView).offset(-2);
        make.width.equalTo(@30);
        make.height.equalTo(@30);
    }];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

@end

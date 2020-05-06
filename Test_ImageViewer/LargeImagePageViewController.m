//
//  LargeImagePageViewController.m
//  Test_ImageViewer
//
//  Created by Doby on 2020/5/6.
//  Copyright © 2020 Doby. All rights reserved.
//

#import "LargeImagePageViewController.h"

@import SDWebImage;

@implementation ImageInfo



@end


@interface LargeImagePageViewController ()<TestTransitionDelegate, UIViewControllerTransitioningDelegate, UIPageViewControllerDataSource>

@property (strong, nonatomic) NSArray<ImageInfo*> *arrImgInfos;
@property (assign, nonatomic) NSInteger currentIdx;

@end

@implementation LargeImagePageViewController

- (instancetype)initWithImages:(NSArray<ImageInfo*>*)imgs idx:(NSInteger)idx
{
    self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:@{
        UIPageViewControllerOptionInterPageSpacingKey: @20
    }];
    if (self) {
        self.transitioningDelegate = self;
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.dataSource = self;
        self.arrImgInfos = imgs;
        self.currentIdx = idx;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    LargeImageContentViewController *vc = [[LargeImageContentViewController alloc] initWithIndex:self.currentIdx image:self.arrImgInfos[self.currentIdx]];
    vc.pageVC = self;
    [self setViewControllers:@[vc] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
    
}

- (void)updateBGColor:(UIColor*)color {
    self.view.backgroundColor = color;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    LargeImageContentViewController *currentVC = (LargeImageContentViewController*)self.viewControllers[0];
    if (currentVC.idx - 1 >= 0) {
        LargeImageContentViewController *nextVC = [[LargeImageContentViewController alloc] initWithIndex:currentVC.idx - 1 image:self.arrImgInfos[currentVC.idx - 1]];
        nextVC.pageVC = self;
        return nextVC;
    }
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    LargeImageContentViewController *currentVC = (LargeImageContentViewController*)self.viewControllers[0];
    if (currentVC.idx + 1 < self.arrImgInfos.count) {
        LargeImageContentViewController *nextVC = [[LargeImageContentViewController alloc] initWithIndex:currentVC.idx + 1 image:self.arrImgInfos[currentVC.idx + 1]];
        nextVC.pageVC = self;
        return nextVC;
    }
    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    TestTransition *trans = [TestTransition new];
    trans.isPresenting = YES;
    return trans;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    TestTransition *trans = [TestTransition new];
    trans.isPresenting = NO;
    return trans;
}

- (UIView *)targetView {
    return [((id<TestTransitionDelegate>)self.viewControllers[0]) targetView];
}

- (UIImage *)targetImage {
    return [((id<TestTransitionDelegate>)self.viewControllers[0]) targetImage];
}


@end


@interface LargeImageContentViewController() <UIScrollViewDelegate, UIGestureRecognizerDelegate, TestTransitionDelegate>

@property (strong, nonatomic) ImageInfo *imgInfo;

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imgView;


@property (assign, nonatomic) CGPoint preCenter;
@property (assign, nonatomic) CGAffineTransform preTransform;

@end

@implementation LargeImageContentViewController

- (instancetype)initWithIndex:(NSInteger)idx image:(ImageInfo *)imgInfo
{
    self = [super init];
    if (self) {
        self.idx = idx;
        self.imgInfo = imgInfo;
    }
    return self;
}

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor clearColor];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.scrollView.minimumZoomScale = 1;
    self.scrollView.maximumZoomScale = 2;
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    
    self.imgView = [UIImageView new];
    self.imgView.sd_imageIndicator = [SDWebImageActivityIndicator grayIndicator];
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:self.imgInfo.strImg] placeholderImage:self.imgInfo.placeholder completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        [self resizeImageView];
    }];
    [self resizeImageView];
    [self.scrollView addSubview:self.imgView];
    
    
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGes:)];
    pan.delegate = self;
    [self.view addGestureRecognizer:pan];
}

- (void)resizeImageView {
    UIImage *img = self.imgView.image;
    if (!img) {
        return;
    }
    CGFloat scale = MAX(img.size.width / self.scrollView.frame.size.width, img.size.height / self.scrollView.frame.size.height);
    self.imgView.frame = CGRectMake(0, 0, img.size.width / scale, img.size.height / scale);
    self.imgView.center = self.scrollView.center;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (void)panGes:(UIPanGestureRecognizer*)pan {
    switch (pan.state) {
        case UIGestureRecognizerStateBegan: {
            self.preCenter = self.imgView.center;
            self.preTransform = self.imgView.transform;
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint offset = [pan translationInView:self.view];
            if (offset.y > 0) {
                CGFloat scale = 1 - (offset.y / 400);
                self.imgView.transform = CGAffineTransformScale(self.preTransform, scale, scale);
                [self.pageVC updateBGColor:[UIColor colorWithWhite:0 alpha:scale]];
            }
            else {
                self.imgView.transform = self.preTransform;
            }
            self.imgView.center = CGPointMake(self.preCenter.x + offset.x, self.preCenter.y + offset.y);
            break;
        }
        case UIGestureRecognizerStateEnded: {
            CGPoint offset = [pan translationInView:self.view];
            if (offset.y > 200) {
                [self dismissViewControllerAnimated:YES completion:NULL];
            }
            else {
                [UIView animateWithDuration:0.35 animations:^{
                    self.imgView.transform = self.preTransform;
                    self.imgView.center = self.preCenter;
                    [self.pageVC updateBGColor:UIColor.blackColor];
                }];
            }
            break;
        }
        default:
            break;
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat xoff = (scrollView.bounds.size.width - self.imgView.frame.size.width) / 2;
    xoff = MAX(0, xoff);
    CGFloat yoff = (scrollView.bounds.size.height - self.imgView.frame.size.height) / 2;
    yoff = MAX(0, yoff);
    CGRect rc = self.imgView.frame;
    rc.origin.x = xoff;
    rc.origin.y = yoff;
    self.imgView.frame = rc;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imgView;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [gestureRecognizer.view isEqual:self.view]) {
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer*)gestureRecognizer;
        CGPoint vector = [pan velocityInView:self.view];
        if (vector.y > 0 && fabs(vector.y) > fabs(vector.x)) {
            if (self.scrollView.contentOffset.y == 0) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [gestureRecognizer.view isEqual:self.view]
        && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer.view isEqual:self.scrollView]) {
        return YES;
    }
    
    return NO;
}

- (UIView *)targetView {
    return self.imgView;
}

- (UIImage *)targetImage {
    return self.imgView.image;
}

@end

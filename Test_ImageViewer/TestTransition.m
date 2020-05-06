//
//  TestTransition.m
//  Test_ImageViewer
//
//  Created by Doby on 2020/5/6.
//  Copyright © 2020 Doby. All rights reserved.
//

#import "TestTransition.h"

@interface TestTransition ()



@end

@implementation TestTransition

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.35;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *container = transitionContext.containerView;
    
    CGRect fromTargetRC = CGRectZero;
    CGRect toTargetRC = CGRectZero;
    UIImage *animationImage = nil;
    
    id<TestTransitionDelegate> fDelegate = [self findTransitionDelegate:fromVC];
    id<TestTransitionDelegate> tDelegate = [self findTransitionDelegate:toVC];
    
    if ([fDelegate targetView]) {
        UIView *tv = [fDelegate targetView];
        fromTargetRC = [fromVC.view convertRect:tv.frame fromView:tv.superview];
        if ([fDelegate targetImage]) {
            animationImage = [fDelegate targetImage];
        }
    }
    if ([tDelegate targetView]) {
        UIView *tv = [tDelegate targetView];
        toTargetRC = [toVC.view convertRect:tv.frame fromView:tv.superview];
        if ([tDelegate targetImage]) {
            animationImage = [tDelegate targetImage];
        }
    }
    
    if (CGRectEqualToRect(fromTargetRC, CGRectZero)
        || animationImage == nil) {
        [self simpleVerticalTransition:transitionContext];
        return;
    }
    if (CGRectEqualToRect(toTargetRC, CGRectZero)) {
        CGRect toViewRC = toVC.view.bounds;
        CGFloat scale = MAX(fromTargetRC.size.width / toViewRC.size.width, fromTargetRC.size.height / toViewRC.size.height);
        toTargetRC = CGRectMake(0, 0, fromTargetRC.size.width / scale, fromTargetRC.size.height / scale);
        toTargetRC.origin.x = (toViewRC.size.width - toTargetRC.size.width) / 2;
        toTargetRC.origin.y = (toViewRC.size.height - toTargetRC.size.height) / 2;
    }
    
    if (self.isPresenting) {
        
        UIImageView *thumbImage = [[UIImageView alloc] initWithFrame:toTargetRC];
        thumbImage.image = animationImage;
        CGFloat scale = MAX(fromTargetRC.size.width / toTargetRC.size.width, fromTargetRC.size.height / toTargetRC.size.height);
        UIView *mask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, fromTargetRC.size.width / scale, fromTargetRC.size.height / scale)];
        mask.backgroundColor = [UIColor blackColor];
        mask.center = CGPointMake(toTargetRC.size.width / 2, toTargetRC.size.height / 2);
        
        thumbImage.maskView = mask;
        [container addSubview:toVC.view];
        [container addSubview:thumbImage];
        toVC.view.hidden = YES;
        container.backgroundColor = [UIColor clearColor];
        thumbImage.center = CGPointMake(CGRectGetMidX(fromTargetRC), CGRectGetMidY(fromTargetRC));
        thumbImage.transform = CGAffineTransformMakeScale(scale, scale);
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            mask.bounds = thumbImage.bounds;
            thumbImage.transform = CGAffineTransformIdentity;
            thumbImage.center = CGPointMake(CGRectGetMidX(toTargetRC), CGRectGetMidY(toTargetRC));
            container.backgroundColor = [UIColor blackColor];
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:finished];
            if (finished) {
                [thumbImage removeFromSuperview];
                toVC.view.hidden = NO;
                container.backgroundColor = [UIColor clearColor];
            }
        }];
    }
    else {
        
        UIImageView *thumbImage = [[UIImageView alloc] initWithFrame:fromTargetRC];
        thumbImage.image = animationImage;
        CGFloat scale = MAX(toTargetRC.size.width / fromTargetRC.size.width, toTargetRC.size.height / fromTargetRC.size.height);
        UIView *mask = [[UIView alloc] initWithFrame:thumbImage.bounds];
        mask.backgroundColor = [UIColor blackColor];
        
        thumbImage.maskView = mask;
        [container addSubview:thumbImage];
        fromVC.view.hidden = YES;
        container.backgroundColor = fromVC.view.backgroundColor;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            mask.bounds = CGRectMake(0, 0, toTargetRC.size.width / scale, toTargetRC.size.height / scale);
            mask.center = CGPointMake(fromTargetRC.size.width / 2, fromTargetRC.size.height / 2);
            thumbImage.transform = CGAffineTransformMakeScale(scale, scale);
            thumbImage.center = CGPointMake(CGRectGetMidX(toTargetRC), CGRectGetMidY(toTargetRC));
            container.backgroundColor = [UIColor clearColor];
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:finished];
            if (finished) {
                [fromVC.view removeFromSuperview];
                [thumbImage removeFromSuperview];
                [container removeFromSuperview];
            }
        }];
        
    }
}

- (void)simpleVerticalTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *container = transitionContext.containerView;
    if (self.isPresenting) {
        
        [container addSubview:toVC.view];
        CGRect rc = container.bounds;
        rc.origin.y = rc.size.height;
        toVC.view.frame = rc;
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            toVC.view.frame = toVC.view.bounds;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:finished];
        }];
    }
    else {
        CGRect rc = container.bounds;
        rc.origin.y = rc.size.height;
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            fromVC.view.frame = rc;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:finished];
            if (finished) {
                [fromVC.view removeFromSuperview];
                [container removeFromSuperview];
            }
        }];
    }
}

- (nullable id<TestTransitionDelegate>)findTransitionDelegate:(UIViewController*)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        vc = ((UINavigationController*)vc).topViewController;
    }
    else {
        if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = ((UITabBarController*)vc).selectedViewController;
        }
    }
    if ([vc conformsToProtocol:@protocol(TestTransitionDelegate)]) {
        return (id<TestTransitionDelegate>)vc;
    }
    else {
        for (UIViewController *childVC in vc.childViewControllers) {
            id<TestTransitionDelegate> hit = [self findTransitionDelegate:childVC];
            if (hit) {
                return hit;
            }
        }
    }
    return nil;
    
}

@end

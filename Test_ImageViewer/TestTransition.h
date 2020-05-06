//
//  TestTransition.h
//  Test_ImageViewer
//
//  Created by Doby on 2020/5/6.
//  Copyright © 2020 Doby. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TestTransitionDelegate <NSObject>

@optional
- (nullable UIView*)targetView;
- (nullable UIImage*)targetImage;

@end

@interface TestTransition : NSObject<UIViewControllerAnimatedTransitioning>

@property (assign, nonatomic) BOOL isPresenting;

@end

NS_ASSUME_NONNULL_END

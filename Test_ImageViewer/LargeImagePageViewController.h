//
//  LargeImagePageViewController.h
//  Test_ImageViewer
//
//  Created by Doby on 2020/5/6.
//  Copyright © 2020 Doby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestTransition.h"

NS_ASSUME_NONNULL_BEGIN

@interface ImageInfo : NSObject

@property (strong, nonatomic) UIImage *placeholder;
@property (strong, nonatomic) NSString *strImg;

@end

@interface LargeImagePageViewController : UIPageViewController

- (instancetype)initWithImages:(NSArray<ImageInfo*>*)imgs idx:(NSInteger)idx;

@end


@interface LargeImageContentViewController : UIViewController

@property (weak, nonatomic) LargeImagePageViewController *pageVC;
@property (assign, nonatomic) NSInteger idx;

- (instancetype)initWithIndex:(NSInteger)idx image:(ImageInfo*)imgInfo;

@end

NS_ASSUME_NONNULL_END

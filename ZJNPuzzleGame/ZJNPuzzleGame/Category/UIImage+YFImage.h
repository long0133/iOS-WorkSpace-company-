//
//  UIImage+YFImage.h
//  自家扩展
//
//  Created by  张亚飞 on 16/7/16.
//  Copyright © 2016年  张亚飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (YFImage)

#pragma mark -- 图片切割 --
/**
 *  切割成正方形
 */
+ (UIImage *)clipImageWithImage:(UIImage *)image;

/**
 *  切割成指定尺寸 
 *  这里切割的是图片的尺寸 不要和控制器的尺寸弄混了
 */
+ (UIImage *)clipImageWithImage:(UIImage *)image
                      withFrame:(CGRect)frame;

/**
 *  将图片 平分成m行 n列的 m*n个小图片
 */
+ (NSMutableArray *)clipImageWithImage:(UIImage *)image
                    withConuntM:(NSInteger)countM
                     withCountN:(NSInteger)countN;
@end

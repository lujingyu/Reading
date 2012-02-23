//
//  NSString+Extra.h
//  Per
//
//  Created by 陆敬宇 jingyu on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extra)

/**
 * array里的元素必须为NSString类型
 **/
+ (NSString *)stringFromArraySeparatedByCommas:(NSArray *)array;

/**
 * 直接读取Resource文件
 **/
+ (NSString *)stringFromFileNamed:(NSString *)bundleFileName;

/**
 * 毫秒数转换为类似新浪微博的时间显示方式
 **/
+ (NSString *)stringFromIntervalSinceNow:(long long)theDate;

@end

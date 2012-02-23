//
//  NSString+Extra.m
//  Per
//
//  Created by 陆敬宇 jingyu on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NSString+Extra.h"

@implementation NSString (Extra)

+ (NSString *)stringFromArraySeparatedByCommas:(NSArray *)array {
	if ([array count] == 0 || array == nil) {
		return nil;
	}
	else {
		NSMutableString *string = [NSMutableString stringWithCapacity:0];
		for (NSString *subString in array) {
			[string appendFormat:@"%@,", subString];
		}
		[string deleteCharactersInRange:NSMakeRange([string length] - 1, 1)];
		return string;
	}
}

+ (NSString *)stringFromFileNamed:(NSString *)bundleFileName {
	NSArray *sep = [bundleFileName componentsSeparatedByString:@"."];
    NSString *path = [[NSBundle mainBundle] pathForResource:[sep objectAtIndex:0] ofType:[sep objectAtIndex:1]];
    NSString *text = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    return text;
}

+ (NSString *)stringFromIntervalSinceNow:(long long)theDate {
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now = [dat timeIntervalSince1970] * 1;
    NSString *timeString = @"";
    
    NSTimeInterval cha = now - (theDate/1000.0f);
    
	if (cha<0) {
		timeString = @"1分钟之前";
	}	
    else if (cha/3600<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/60];
        timeString = [timeString substringToIndex:timeString.length-7];
		if ([timeString isEqualToString:@"-0"] || [timeString isEqualToString:@"0"] || [timeString isEqualToString:@"-1"]) {
			timeString = @"1";
		}
        timeString = [NSString stringWithFormat:@"%@分钟前", timeString];
    }
	else if (cha/3600>1&&cha/86400<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/3600];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString =[NSString stringWithFormat:@"%@小时前", timeString];
    }
    else if (cha/86400>1) {
        timeString = [NSString stringWithFormat:@"%f", cha/86400];
        timeString = [timeString substringToIndex:timeString.length-7];
		if ([timeString isEqualToString:@"1"]) {
			timeString = @"昨天";
		}
		else if ([timeString isEqualToString:@"2"]) {
			timeString = @"前天";
		}
		else {
			NSDate *date = [NSDate dateWithTimeIntervalSince1970:theDate/1000];
			NSDateFormatter *inform = [[NSDateFormatter alloc] init];
			[inform setDateFormat:@"yyyy-MM-dd"];
			timeString = [inform stringFromDate:date];
			[inform release];			
		}
    }
	
    return timeString;
}

@end

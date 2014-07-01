//
//  CommonUtils.h
//  onenumber
//
//  Created by garyliumac on 14-5-25.
//  Copyright (c) 2014年 zlot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonUtils : NSObject

+ (BOOL)isOnSound;
+ (BOOL)connectedToNetwork;
+ (void)showNoNetworkAlert;
+ (NSString *)getPackageNameByRank:(int) r;
+ (BOOL)isLevelPackLocked;

@end

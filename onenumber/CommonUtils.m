//
//  CommonUtils.m
//  onenumber
//
//  Created by garyliumac on 14-5-25.
//  Copyright (c) 2014年 zlot. All rights reserved.
//

#import "CommonUtils.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <netdb.h>
#import <SystemConfiguration/SCNetworkReachability.h>

@implementation CommonUtils

+ (BOOL)isOnSound
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *sound = [defaults objectForKey:@"onsound"];
    BOOL onsound = [sound intValue] != 0 ? YES : NO;
    return (onsound || !sound);
}

+ (BOOL)connectedToNetwork
{
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags)
    {
        return NO;
    }
    
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    return (isReachable && !needsConnection) ? YES : NO;
}


+ (void)showNoNetworkAlert
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"No Internet Connection"
                          message:@"Please make sure your device has internet connectivity."
                          delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}


+ (NSString *)getPackageNameByRank:(int) r
{
    NSString *s = [[NSString alloc]init];
    switch (r) {
        case 0:
            s = @"STARTER";
            break;
        case 1:
            s = @"MEDIUM";
            break;
        case 2:
            s = @"HARD";
            break;
        case 3:
            s = @"EXTREME";
            break;
        default:
            s = @"";
            break;
    }
    return s;
}

+ (BOOL)isLevelPackLocked
{
    BOOL locked = YES;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *packLocked = [defaults objectForKey:@"packLocked"];
    if (packLocked) {
        locked = ([packLocked intValue] == 0) ? NO : YES;
    } else {
        locked = YES;
    }
    return locked;
}

@end

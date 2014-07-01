//
//  StoreKitManager.h
//  onenumber
//
//  Created by garyliumac on 14-5-27.
//  Copyright (c) 2014年 zlot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import <StoreKit/StoreKit.h>

@class ViewController;
@interface StoreKitManager : NSObject<SKPaymentTransactionObserver, SKProductsRequestDelegate>
{
    UIAlertView *_loadingAlert;
    BOOL isUnlockLevelPack;
}

@property (nonatomic, readwrite, strong) ViewController* viewController;
+ (StoreKitManager *)getInstance;

/**
 init iap
 */
- (void)initStoreKit;

/**
 purchase item by id
 */
- (void)purchaseItem: (NSString*)identifier;

- (void)restorePurchases;

- (BOOL)getIsUnlockLevelPack;


@end

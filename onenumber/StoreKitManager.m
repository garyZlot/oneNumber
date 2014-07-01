//
//  StoreKitManager.m
//  onenumber
//
//  Created by garyliumac on 14-5-27.
//  Copyright (c) 2014年 zlot. All rights reserved.
//


#import "StoreKitManager.h"
#import "MainLayer.h"
#import "IntroLayer.h"

@implementation StoreKitManager

+ (StoreKitManager *)getInstance
{
    static StoreKitManager *mgr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mgr = [[self alloc] init];
    });
    return mgr;
}

- (id)init
{
    self = [super init];
    if (self) {
        isUnlockLevelPack = NO;
        return self;
    }
    return nil;
}


- (void)showMessage:(NSString *)title Message:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)showLoadingView:(NSString *)title
{
    _loadingAlert= [[UIAlertView alloc] initWithTitle:title message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [_loadingAlert show];
}

- (void)removeLoadingView
{
    [_loadingAlert dismissWithClickedButtonIndex:0 animated:YES];
}


#pragma mark - IAP
- (BOOL)canProcessPayments
{
    if ([SKPaymentQueue canMakePayments]) {
        return YES;
    } else {
        return NO;
    }
}



- (void)initStoreKit
{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}


- (void)purchaseItem: (NSString *)identifier
{
    [self showLoadingView:@"Access Store..."];
    
    if (![self canProcessPayments]) {
        NSLog(@"1.失败-->SKPaymentQueue canMakePayments NO");
        [self removeLoadingView];
        return;
    }
    NSLog(@"1.成功-->请求产品信息...%@", identifier);
    
    // 使用请求商品信息式购买
    SKProductsRequest *request= [[SKProductsRequest alloc]
                                 initWithProductIdentifiers: [NSSet setWithObject: identifier]];
    request.delegate = self;
    [request start];
}

// SKProductsRequest 的回调
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *myProduct = response.products;
    
    if (myProduct.count == 0) {
        NSLog(@"2.失败-->无法获取产品信息，购买失败。invalidProductIdentifiers = %@",response.invalidProductIdentifiers);
        [self removeLoadingView];
        return;
    }
    NSLog(@"2.成功-->获取产品信息成功，正在购买...");
    SKPayment * payment = [SKPayment paymentWithProduct:myProduct[0]];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

// SKPayment 的回调
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    NSLog(@"3.成功-->接收苹果购买数据，正在处理...");
    for (SKPaymentTransaction *transaction in transactions){
        switch (transaction.transactionState){
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
                
            default:
                break;
        }
    }
}

// 结束交易
- (void) completeTransaction: (SKPaymentTransaction*)transaction
{
    NSLog(@"4.成功-->结束交易 SKPaymentTransactionStatePurchased");
    [self removeLoadingView];
	// 记录交易和提供产品 这两方法必须处理
    [self recordTransaction: transaction];
    [self provideContent: transaction.payment.productIdentifier];
	
    // 移除 transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

// 重置交易
- (void) restoreTransaction: (SKPaymentTransaction*)transaction
{
    NSLog(@"4.成功-->重置交易 SKPaymentTransactionStateRestored");
    [self recordTransaction: transaction];
    [self provideContent: transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

// 交易失败
- (void) failedTransaction: (SKPaymentTransaction*)transaction
{
    [self removeLoadingView];
    NSLog(@"4.成功-->交易失败 SKPaymentTransactionStateRestored error.code:%d",(int)transaction.error.code);
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

// 交易记录
- (void) recordTransaction: (SKPaymentTransaction*)transaction
{
    NSLog(@"4.成功-->交易记录, 可以在此处存储记录");

}

// 提供产品
- (void) provideContent: (NSString*)identifier
{
    NSLog(@"4.成功-->交易成功，请提供产品 identifier = %@", identifier);
    
    [self removeLoadingView];
    [self showMessage:@"Success" Message:@"You have successfully purchased."];
    
    
    CCScene *scene = [[CCDirector sharedDirector] runningScene];
    
    if ([identifier isEqualToString:@"com.zlot.game.onenumber.morehints1"]) {
        MainLayer *mainLayer = (MainLayer *)[scene getChildByTag:0];
        [mainLayer updateHintsCountWithBuys:50];
    }
    
    if ([identifier isEqualToString:@"com.zlot.game.onenumber.morehints2"]) {
        MainLayer *mainLayer = (MainLayer *)[scene getChildByTag:0];
        [mainLayer updateHintsCountWithBuys:150];
    }
    
    if ([identifier isEqualToString:@"com.zlot.game.onenumber.unlocklevelpack"]) {
        CCNode * s = [scene getChildByTag:0];
        if ([s isKindOfClass:[IntroLayer class]]) {
            IntroLayer *introLayer = (IntroLayer *)[scene getChildByTag:0];
            [introLayer unlockLevelPack];
        } else { //restore purchages in setting
            isUnlockLevelPack = YES;
        }
        
    }
}

- (BOOL)getIsUnlockLevelPack
{
    return isUnlockLevelPack;
}

- (void)restorePurchases
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

-(void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    NSLog(@"restore purchase failed!");
}

@end

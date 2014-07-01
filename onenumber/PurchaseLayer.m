//
//  PurchaseLayer.m
//  onenumber
//
//  Created by garyliumac on 14-5-25.
//  Copyright 2014年 zlot. All rights reserved.
//

#import "PurchaseLayer.h"
#import "StoreKitManager.h"
#import "CommonUtils.h"


@implementation PurchaseLayer

- (id) init
{
	if (self = [super initWithColor:ccc4(0, 0, 0, 360)] ) {
        CGSize size = [[CCDirector sharedDirector] winSize];
        CCSprite *purbg = [CCSprite spriteWithFile:@"purchase_bg.png"];
        purbg.position = ccp(size.width/2, size.height/2);
        [self addChild:purbg];
        
        CCSprite* normal = [CCSprite spriteWithFile:@"closebtn.png"];
        CCSprite* selected = [CCSprite spriteWithFile:@"closebtn.png"];
        CCMenuItemSprite* closeitem = [CCMenuItemSprite itemWithNormalSprite:normal selectedSprite:selected
                                                                      target:self selector:@selector(closePurchase)];
        CCMenu* closeMenu = [CCMenu menuWithItems:closeitem, nil];
        closeMenu.position = ccp(size.width-30, size.height/2 + 100);
        [self addChild:closeMenu];
        
        CCSprite *hintSpr1 = [CCSprite spriteWithFile:@"hint_on.png"];
        hintSpr1.position = ccp(50.0, size.height/2 - 5);
        [self addChild:hintSpr1];
        CCSprite *hintSpr2 = [CCSprite spriteWithFile:@"hint_on.png"];
        hintSpr2.position = ccp(50.0, size.height/2 - 75);
        [self addChild:hintSpr2];
        
        CCLabelTTF *titleText = [CCLabelTTF labelWithString:@"" fontName:@"ArialHebrew" fontSize:25];
        [titleText setColor:ccc3(155, 70, 0)];
        titleText.position = ccp(size.width/2, size.height/2 + 65);
        [self addChild:titleText];
        [titleText setString: @"Bug more hints?"];
        
        CCLabelTTF *hintCountText1 = [CCLabelTTF labelWithString:@"" fontName:@"ArialHebrew" fontSize:25];
        [hintCountText1 setColor:ccc3(255, 255, 255)];
        hintCountText1.position = ccp(hintSpr1.position.x + 50, hintSpr1.position.y);
        [self addChild:hintCountText1];
        [hintCountText1 setString: @"x 50"];
        
        CCLabelTTF *hintCountText2 = [CCLabelTTF labelWithString:@"" fontName:@"ArialHebrew" fontSize:25];
        [hintCountText2 setColor:ccc3(255, 255, 255)];
        hintCountText2.position = ccp(hintSpr2.position.x + 55, hintSpr2.position.y);
        [self addChild:hintCountText2];
        [hintCountText2 setString: @"x 150"];
        
        
        CCLabelTTF *hintCostText1 = [CCLabelTTF labelWithString:@"" fontName:@"ArialHebrew" fontSize:25];
        [hintCostText1 setColor:ccc3(155, 70, 0)];
        hintCostText1.position = ccp(hintSpr1.position.x + 140, hintSpr1.position.y);
        [self addChild:hintCostText1];
        [hintCostText1 setString: @"$0.99"];
        
        CCLabelTTF *hintCostText2 = [CCLabelTTF labelWithString:@"" fontName:@"ArialHebrew" fontSize:25];
        [hintCostText2 setColor:ccc3(155, 70, 0)];
        hintCostText2.position = ccp(hintSpr2.position.x + 140, hintSpr2.position.y);
        [self addChild:hintCostText2];
        [hintCostText2 setString: @"$1.99"];
        
        CCMenu *buyMenu = [CCMenu menuWithItems:nil];
        CCSprite *buySpr = [CCSprite spriteWithFile:@"buybtn.png"];
        CCSprite *selBugSpr = [CCSprite spriteWithFile:@"buyselbtn.png"];
        CCMenuItem *buyItem1 = [CCMenuItemSprite itemWithNormalSprite:buySpr selectedSprite:selBugSpr target:self selector:@selector(buyHints1)];
        [buyMenu addChild:buyItem1 z:1 tag:1];
        
        CCSprite *buySpr2 = [CCSprite spriteWithFile:@"buybtn.png"];
        CCSprite *selBugSpr2 = [CCSprite spriteWithFile:@"buyselbtn.png"];
        CCMenuItem *buyItem2 = [CCMenuItemSprite itemWithNormalSprite:buySpr2 selectedSprite:selBugSpr2 target:self selector:@selector(buyHints2)];
        [buyMenu addChild:buyItem2 z:1 tag:2];
        buyMenu.position = ccp(size.width - 60, size.height/2 - 38);
        [buyMenu alignItemsVerticallyWithPadding:50];
        [self addChild:buyMenu];
        
	}
	return self;
}

- (void)buyHints1
{
    if (![CommonUtils connectedToNetwork]) {
        [CommonUtils showNoNetworkAlert];
        return;
    }
    StoreKitManager *skm = [StoreKitManager getInstance];
    [skm initStoreKit];
    [skm purchaseItem:@"com.zlot.game.onenumber.morehints1"];
    
}

- (void)buyHints2
{
    if (![CommonUtils connectedToNetwork]) {
        [CommonUtils showNoNetworkAlert];
        return;
    }
    StoreKitManager *skm = [StoreKitManager getInstance];
    [skm initStoreKit];
    [skm purchaseItem:@"com.zlot.game.onenumber.morehints2"];
    
}

- (void)closePurchase
{
    [self removeFromParentAndCleanup:YES];
}

@end

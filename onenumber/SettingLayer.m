//
//  SettingLayer.m
//  gathernumbers
//
//  Created by garyliumac on 14-4-14.
//  Copyright 2014年 zlot. All rights reserved.
//

#import "SettingLayer.h"
#import "SimpleAudioEngine.h"
#import "IntroLayer.h"
#import "CommonUtils.h"
#import "StoreKitManager.h"


@implementation SettingLayer


+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	SettingLayer *layer = [SettingLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (id) init
{
    if (self = [super init]) {
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        //set background
        CCSprite *bg = [CCSprite spriteWithFile:iPhone5 ? @"setting_bg.png" : @"setting_bg_35.png"];
        bg.anchorPoint = ccp(0.0, 0.0);
        [self addChild:bg z:0];
        
        //restore purchases
        CCSprite *rpBtnbg = [CCSprite spriteWithFile:@"packagebtn_bg.png"];
        CCSprite *rpSelBtnbg = [CCSprite spriteWithFile:@"packagebtn_selbg.png"];
        CCLabelTTF *rpText = [CCLabelTTF labelWithString:@"Restore Purchases" fontName:@"Verdana-Bold" fontSize:15];
        [rpText setColor:ccc3(155.0, 70.0, 0.0)];
        CGSize contentS = [rpBtnbg contentSize];
        [rpText setPosition:ccp(contentS.width/2, contentS.height/2)];
        [rpBtnbg addChild:rpText];
        
        CCLabelTTF *rpSelText = [CCLabelTTF labelWithString:@"Restore Purchases" fontName:@"Verdana-Bold" fontSize:15];
        [rpSelText setColor:ccc3(155.0, 70.0, 0.0)];
        [rpSelText setPosition:ccp(contentS.width/2, contentS.height/2)];
        [rpSelBtnbg addChild:rpSelText];
        
        CCMenuItemSprite *rpItem = [CCMenuItemSprite itemWithNormalSprite:rpBtnbg selectedSprite:rpSelBtnbg target:self selector:@selector(resrotePurchases)];
        
        //sound and music toggle buttons
        CCMenuItemSprite *soundToggleOn = [self getMenuItemForObj:@"SOUND" status:YES];
        CCMenuItemSprite *soundToggleOff = [self getMenuItemForObj:@"SOUND" status:NO];
        CCMenuItemToggle *soundItem = [CCMenuItemToggle itemWithTarget:self selector:@selector(toggleSound) items:soundToggleOn, soundToggleOff, nil];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSNumber *sound = [defaults objectForKey:@"onsound"];
        BOOL onsound = [sound intValue] != 0 ? YES : NO;
        [soundItem setSelectedIndex:(!sound || onsound) ? 0 : 1];
        
        CCMenuItemSprite *musicToggleOn = [self getMenuItemForObj:@"MUSIC" status:YES];
        CCMenuItemSprite *musicToggleOff = [self getMenuItemForObj:@"MUSIC" status:NO];
        CCMenuItemToggle *musicItem = [CCMenuItemToggle itemWithTarget:self selector:@selector(toggleMusic) items:musicToggleOff, musicToggleOn, nil];
        //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSNumber *music = [defaults objectForKey:@"onmusic"];
        BOOL onmusic = [music intValue] != 0 ? YES : NO;
        [musicItem setSelectedIndex:onmusic ? 1 : 0];
        
        
        CCMenu *menu = [CCMenu menuWithItems:rpItem, soundItem, musicItem, nil];
        [menu alignItemsVerticallyWithPadding:40.0];
        menu.touchEnabled = YES;
        menu.position = ccp(screenSize.width/2, screenSize.height/2);
        [self addChild:menu z:2];
        
        CCSprite *back = [CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"backbtn.png"]];
        CCSprite *backs = [CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"backbtn.png"]];
        CCMenuItemSprite *backItem = [CCMenuItemSprite itemWithNormalSprite:back selectedSprite:backs target:self selector:@selector(backMainScreen)];
        CCMenu *backMenu = [CCMenu menuWithItems: backItem,nil];
        backMenu.touchEnabled = YES;
        backMenu.position = ccp(30, 30);
        [self addChild:backMenu z:2];
    }
    return self;
}

- (CCMenuItemSprite *)getMenuItemForObj:(NSString*) toggleObj status:(BOOL) isOn
{
    if (!togglebtnTex) togglebtnTex = [[CCTextureCache sharedTextureCache] addImage:@"packagebtn_bg.png"];
    CCSprite *togglebtnSpr = [CCSprite spriteWithTexture:togglebtnTex];
    
    CCLabelTTF *objText = [CCLabelTTF labelWithString:toggleObj fontName:@"Verdana-Bold" fontSize:15];
    [objText setColor:ccc3(155.0, 70.0, 0.0)];
    CGSize contentS = [togglebtnSpr contentSize];
    [objText setPosition:ccp(contentS.width - 50, contentS.height/2)];
    [togglebtnSpr addChild:objText];
    
    CCSprite *statusSpr = [CCSprite spriteWithFile: isOn ? @"on.png" : @"off.png"];
    [statusSpr setPosition:ccp(50, contentS.height/2)];
    [togglebtnSpr addChild:statusSpr];
    
    CCMenuItemSprite *item = [CCMenuItemSprite itemWithNormalSprite:togglebtnSpr selectedSprite:nil];
    
    return item;
}

- (void) backMainScreen
{
    if ([CommonUtils isOnSound]) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];
    }
    [[CCDirector sharedDirector] popScene];
}

- (void) toggleMusic
{
    if ([CommonUtils isOnSound]) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //NSNumber *lp = [defaults objectForKey:@"levelProgress"];
    NSNumber *music = [defaults objectForKey:@"onmusic"];

    BOOL onmusic = [music intValue] != 0 ? YES : NO;
    if (onmusic) {
        [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
    } else {
        [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
    }
    music = [NSNumber numberWithBool:!onmusic];
    [defaults setObject:music forKey:@"onmusic"];
}

- (void) toggleSound
{
    if ([CommonUtils isOnSound]) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *sound = [defaults objectForKey:@"onsound"];
    BOOL onsound = (!sound || [sound intValue] != 0) ? YES : NO;
    sound = [NSNumber numberWithBool:!onsound];
    [defaults setObject:sound forKey:@"onsound"];
}

- (void) resrotePurchases
{
    StoreKitManager *skm = [StoreKitManager getInstance];
    [skm initStoreKit];
    [skm restorePurchases];
}

@end

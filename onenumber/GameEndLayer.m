//
//  GameEndLayer.m
//  gathernumbers
//
//  Created by garyliumac on 14-4-12.
//  Copyright 2014年 zlot. All rights reserved.
//

#import "GameEndLayer.h"
#import "MainLayer.h"

@implementation GameEndLayer


- (id) init
{
	if (self = [super initWithColor:ccc4(0, 0, 0, 360)]) {

	}
	return self;
}

- (void) initScreenWithWin:(BOOL) win inMainLayer: (CCLayer *) mainLayer
{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    if (!successBgTex) successBgTex = [[CCTextureCache sharedTextureCache] addImage:@"success_bg.png"];
    if (!failedBgTex) failedBgTex = [[CCTextureCache sharedTextureCache] addImage:@"failed_bg.png"];
    if (!nextTex) nextTex = [[CCTextureCache sharedTextureCache] addImage:@"next.png"];
    if (!levelSelectTex) levelSelectTex = [[CCTextureCache sharedTextureCache] addImage:@"level_select.png"];
    if (!replayTex) replayTex = [[CCTextureCache sharedTextureCache] addImage:@"replay.png"];
    
    CCSprite *bg = [CCSprite spriteWithTexture: win ? successBgTex : failedBgTex];
    bg.position = ccp(screenSize.width/2, screenSize.height/2);
    [self addChild:bg z:0];
    
    CCLabelTTF *endText = [CCLabelTTF labelWithString:@"" fontName:@"ArialHebrew" fontSize:25];
    [endText setColor:ccc3(155, 70, 0)];
    endText.position = ccp(screenSize.width/2, screenSize.height/2 + 30);
    [self addChild:endText z:1];
    [endText setString: win ? @"SUCCESS!" : @"FAILED!"];
    
    CCMenu *menu = [CCMenu menuWithItems:nil];
    
    CCSprite *levelSelSpr = [CCSprite spriteWithTexture:levelSelectTex];
    CCSprite *selLevelSelSpr = [CCSprite spriteWithTexture:levelSelectTex];
    selLevelSelSpr.scale = 1.2;
    CCMenuItem *levelSelItem = [CCMenuItemSprite itemWithNormalSprite:levelSelSpr selectedSprite:selLevelSelSpr target:mainLayer selector:@selector(backNavScreen)];
    [menu addChild:levelSelItem];
    
    CCSprite *replaySpr = [CCSprite spriteWithTexture:replayTex];
    CCSprite *selReplaySpr = [CCSprite spriteWithTexture:replayTex];
    CCMenuItem *retryItem = [CCMenuItemSprite itemWithNormalSprite:replaySpr selectedSprite:selReplaySpr target:mainLayer selector:@selector(retryGame)];
    [menu addChild:retryItem];
    
    if (win) {
        CCSprite *nextSpr = [CCSprite spriteWithTexture:nextTex];
        CCSprite *selNextSpr = [CCSprite spriteWithTexture:nextTex];
        selNextSpr.scale = 1.2;
        CCMenuItem *nextItem = [CCMenuItemSprite itemWithNormalSprite:nextSpr selectedSprite:selNextSpr target:mainLayer selector:@selector(enterNextLevel)];
        [menu addChild:nextItem];
    }
    
    [menu alignItemsHorizontallyWithPadding: win ? 50 : 100];
    menu.position = ccp(screenSize.width/2, screenSize.height/2 - 25);
    [self addChild:menu z:1];
    
}

@end //GameEndLayer

//
//  NavigateLayer.m
//  gathernumbers
//
//  Created by garyliumac on 14-4-12.
//  Copyright 2014年 zlot. All rights reserved.
//

#import "NavigateLayer.h"
#import "IntroLayer.h"
#import "MainLayer.h"
#import "CCMenu+Layout.h"
#import "SimpleAudioEngine.h"
#import "CommonUtils.h"


@implementation NavigateLayer

+ (CCScene *) sceneWithGameRank: (int) rank
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	NavigateLayer *layer = [NavigateLayer node];
	if (layer) {
        [layer initWithRank:rank];
        [layer setTouchEnabled:YES];
    }
	// add layer as a child to scene
	[scene addChild:layer];
	
	// return the scene
	return scene;
}

- (void) initWithRank: (int) r
{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
    //set background
    CCSprite *bg = [CCSprite spriteWithFile:iPhone5 ? @"nav_bg.png" : @"nav_bg_35.png"];
    bg.anchorPoint = ccp(0.0, 0.0);
    [self addChild:bg z:0];
    
    //set package title
    NSString *packageName = [CommonUtils getPackageNameByRank:r];
    CCLabelTTF *packageText = [CCLabelTTF labelWithString:packageName fontName:@"ArialHebrew" fontSize:30];
    [packageText setColor:ccc3(155.0, 70.0, 0.0)];
    packageText.position = ccp(screenSize.width/2, iPhone5 ? 470.0 : 405.0);
    [self addChild:packageText z:1];
    
    //get level progress
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *lp = [defaults objectForKey:@"levelProgress"];
    //NSLog(@"level progress is ------ in navigate ----- %d", [lp intValue]);
    int levelProgress = [lp intValue];
    
    //[defaults removeObjectForKey:@"levelProgress"];

    rank = r;
    int levelBaseNo = [self getLevelBaseNoByRank:r];
    
    CCMenu* levelMenu = [CCMenu menuWithItems:nil];
    
    [levelMenu setTouchEnabled:YES];
    
    if (!levelBgTex) levelBgTex = [[CCTextureCache sharedTextureCache] addImage:@"level_bg.png"];
    if (!levelLockTex) levelLockTex = [[CCTextureCache sharedTextureCache] addImage:@"level_lock.png"];
    
    int levelNo;
    for (int i=0; i<16; i++) {
        levelNo = levelBaseNo+i+1;
        
        /*
        CCLabelTTF *levelText = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", levelNo] fontName:@"Noteworthy-Bold" fontSize:30];
        CCLabelTTF *selLevelText = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", levelNo] fontName:@"Noteworthy-Bold" fontSize:30];
        
        if (levelProgress >= levelNo) {
            [levelText setColor:ccc3(255, 0, 0)];
            [selLevelText setColor:ccc3(255, 0, 0)];
            
            
            NSNumber *star = [defaults objectForKey:[NSString stringWithFormat:@"star_%d", levelNo]];
            NSLog(@"star is -------%d", [star intValue]);
            
        }
        
        selLevelText.scale = 1.2;
         */
        
        CCSprite *levelSpr = [self getLevelItemSpriteAtLevel:levelNo levelProgress:levelProgress isSelected:NO];
        CCSprite *selLevelSpr = [self getLevelItemSpriteAtLevel:levelNo levelProgress:levelProgress isSelected:YES];
        CCMenuItem *levelItem = [CCMenuItemSprite itemWithNormalSprite:levelSpr selectedSprite:selLevelSpr target:self selector:@selector(enterGameFromSender:)];
        [levelItem setTag:levelNo];
        
        //temp comment this
        [levelItem setIsEnabled:((levelProgress+1) >= levelNo) ? YES : NO];
        
        if(i >= (rank<2 ? 10 : 15)) { // rank 0/1 have 10 levels, rank 2/3 have 15 levels
            [levelItem setVisible:NO];
        }
        [levelMenu addChild:levelItem];

    }
    
    [levelMenu alignItemsInGridWithPadding:ccp(20.0, iPhone5 ? 45.0 : 30.0) columns:4];
    levelMenu.position = ccp(20.0, iPhone5 ? 70.0 : 60.0);
    [self addChild:levelMenu z:1];
    
    
    //add star
    float baseStarPosX = 48.0;
    float baseStarPosY = 376.0 + (iPhone5 ? 0.0 : - 55.0);
    int currentMaxLevel = [self getLevelBaseNoByRank:r+1];
    int currentLevelProgress = levelProgress > currentMaxLevel ? currentMaxLevel : levelProgress;
    
    for (int i=levelBaseNo; i<currentLevelProgress; i++) {
        NSNumber *starNum = [defaults objectForKey:[NSString stringWithFormat:@"star_%d", i+1]];
        int starValue = [starNum intValue];
        //NSLog(@"star is -------%d", [starNum intValue]);
        if (starValue >= 0) {
            int col = (i-levelBaseNo) % 4;
            int row = (i-levelBaseNo) / 4;
            CCSprite *starSprite = [CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"star%d.png", starValue]]];
            starSprite.position = ccp(baseStarPosX + col*75, baseStarPosY - row*(iPhone5 ? 100.0 : 85.0));
            [self addChild:starSprite z:2];
        }
    }
    
    //back menu to test
    CCSprite *back = [CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"backbtn.png"]];
    CCSprite *selback = [CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"backbtn.png"]];
    selback.scale = 1.2;
    CCMenuItemSprite *backItem = [CCMenuItemSprite itemWithNormalSprite:back selectedSprite:selback target:self selector:@selector(backIntroScreen)];
    CCMenu *backMenu = [CCMenu menuWithItems: backItem,nil];
    backMenu.touchEnabled = YES;
    backMenu.position = ccp(30, 30);
    [self addChild:backMenu z:1];
}


- (CCSprite *)getLevelItemSpriteAtLevel:(int)levelNo levelProgress:(int)pro isSelected:(BOOL) isSel
{
    CCSprite *body;
    if ((pro+1) >= levelNo) {
        body = [CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache] addImage:isSel ? @"level_selbg.png" : @"level_bg.png"]];
        
        CCLabelTTF *levelText = [CCLabelTTF labelWithString:[NSString stringWithFormat:(levelNo<10 ? @"0%d" : @"%d"), levelNo] fontName:@"Verdana-Bold" fontSize:25];
        [levelText setColor:ccc3(155.0, 70.0, 0.0)];
        CGSize contentS = [body contentSize];
        [levelText setPosition:ccp(contentS.width/2, contentS.height/2 + 5)];
        
        [body addChild:levelText];
    } else {
        body = [CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"level_lock.png"]];
    }
    
    //NSLog(@"width is -------- %f", [body contentSize].width);
    return body;
}


- (int)getLevelBaseNoByRank:(int) r
{
    int baseNo = 0;
    switch (r) {
        case 0:
            baseNo = 0;
            break;
        case 1:
            baseNo = 10;
            break;
        case 2:
            baseNo = 20;
            break;
        case 3:
            baseNo = 35;
            break;
        case 4:
            baseNo = 50;
        default:
            break;
    }
    
    return baseNo;
}


- (NSString *)getPackageNameByRank:(int) r
{
    NSString *s = [[NSString alloc]init];
    switch (r) {
        case 0:
            s = @"STARTER";
            break;
        case 1:
            s = @"EASY";
            break;
        case 2:
            s = @"MEDIUM";
            break;
        case 3:
            s = @"HARD";
            break;
        default:
            s = @"";
            break;
    }
    return s;
}

- (void) backIntroScreen
{
    if ([CommonUtils isOnSound]) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];
    }
    [[CCDirector sharedDirector] replaceScene:[IntroLayer scene]];
}

- (void) enterGameFromSender: (CCMenuItemSprite *) sender
{
    if ([CommonUtils isOnSound]) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];
    }
    CCScene *scene = [MainLayer sceneWithGameRank:rank withLevel:sender.tag];
    [[CCDirector sharedDirector] replaceScene:scene];

}

@end

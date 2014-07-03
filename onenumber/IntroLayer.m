//
//  IntroLayer.m
//  gathernumbers
//
//  Created by garyliumac on 14-3-20.
//  Copyright zlot 2014年. All rights reserved.
//


// Import the interfaces
#import "AppDelegate.h"
#import "IntroLayer.h"
#import "MainLayer.h"
#import "NavigateLayer.h"
#import "SettingLayer.h"
#import "SimpleAudioEngine.h"
#import "CommonUtils.h"
#import "StoreKitManager.h"

#pragma mark - IntroLayer

// HelloWorldLayer implementation
@implementation IntroLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	IntroLayer *layer = [IntroLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer z:0 tag:0];
	
	// return the scene
	return scene;
}

// 
-(id) init
{
	if( (self=[super init])) {
        
        //set background
        CCSprite *bg = [CCSprite spriteWithFile:(iPhone5 ? @"intro_bg.png" : @"intro_bg_35.png")];
        bg.anchorPoint = ccp(0.0, 0.0);
        [self addChild:bg z:0];
        
        //get level progress
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSNumber *music = [defaults objectForKey:@"onmusic"];
        levelPackLocked = [CommonUtils isLevelPackLocked];
                
        if (![[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying])
        {
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"bg.caf"];
            if (!music) { //first enter app
                [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
            }
        }
        
        if (music && [music intValue] == 0) {
            [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
        }
        
        [self addLevelPackMenu];
        
        CCSprite *settingBtn = [CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"setting_btn.png"]];
        CCSprite *settingBtnSel = [CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"setting_btn.png"]];
        CCMenuItemSprite *settingItem = [CCMenuItemSprite itemWithNormalSprite:settingBtn selectedSprite:settingBtnSel target:self selector:@selector(showSettingScreen)];
        
        CCSprite *rateBtn = [CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"ratebtn.png"]];
        CCSprite *rateBtnSel = [CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"ratebtn.png"]];
        CCMenuItemSprite *rateItem = [CCMenuItemSprite itemWithNormalSprite:rateBtn selectedSprite:rateBtnSel target:self selector:@selector(openRatePage)];
        
        CCSprite *shareBtn = [CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"sharebtn.png"]];
        CCSprite *shareBtnSel = [CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"sharebtn.png"]];
        CCMenuItemSprite *shareItem = [CCMenuItemSprite itemWithNormalSprite:shareBtn selectedSprite:shareBtnSel target:self selector:@selector(openSharePage)];
        
        CCMenu *menu = [CCMenu menuWithItems: settingItem, shareItem, rateItem, nil];
        [menu alignItemsHorizontallyWithPadding:25.0];
        menu.touchEnabled = YES;
        //menu.anchorPoint = ccp(0.0, 0.0);
        menu.position = ccp(85.0, 30.0);
        [self addChild:menu z:1];
	}
	
	return self;
}

- (void)addLevelPackMenu
{
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    CCSprite *btn1 = [self getPackageItemAtIndex:0 isSelected:NO];
    CCSprite *btn1s = [self getPackageItemAtIndex:0 isSelected:YES];
    CCMenuItemSprite *btn1Item = [CCMenuItemSprite itemWithNormalSprite:btn1 selectedSprite:btn1s target:self selector:@selector(enterStarter)];
    
    CCSprite *btn2 = [self getPackageItemAtIndex:1 isSelected:NO];
    CCSprite *btn2s = [self getPackageItemAtIndex:1 isSelected:YES];
    CCMenuItemSprite *btn2Item = [CCMenuItemSprite itemWithNormalSprite:btn2 selectedSprite:btn2s target:self selector:@selector(enterMedium)];
    
    CCSprite *btn3 = [self getPackageItemAtIndex:2 isSelected:NO];
    CCSprite *btn3s = [self getPackageItemAtIndex:2 isSelected:YES];
    CCMenuItemSprite *btn3Item = [CCMenuItemSprite itemWithNormalSprite:btn3 selectedSprite:btn3s target:self selector:@selector(enterHard)];
    
    CCSprite *btn4 = [self getPackageItemAtIndex:3 isSelected:NO];
    CCSprite *btn4s = [self getPackageItemAtIndex:3 isSelected:YES];
    CCMenuItemSprite *btn4Item = [CCMenuItemSprite itemWithNormalSprite:btn4 selectedSprite:btn4s target:self selector:@selector(enterExtreme)];
    
    CCMenu* btnsMenu = [CCMenu menuWithItems: btn1Item, btn2Item, btn3Item, btn4Item, nil];
    btnsMenu.touchEnabled = YES;
    [btnsMenu alignItemsVerticallyWithPadding:25.0];
    btnsMenu.position = ccp(size.width/2, iPhone5 ? 230 : 180);
    [self addChild:btnsMenu z:1 tag:1];
}

- (CCSprite *)getPackageItemAtIndex:(int) index isSelected:(BOOL) isSel
{
    if (!packagebtnbgTex) packagebtnbgTex = [[CCTextureCache sharedTextureCache] addImage:@"packagebtn_bg.png"];
    if (!selPackagebtnbgTex) selPackagebtnbgTex = [[CCTextureCache sharedTextureCache] addImage:@"packagebtn_selbg.png"];
    if (!packagebtnlockbgTex) packagebtnlockbgTex = [[CCTextureCache sharedTextureCache] addImage:@"packagebtn_lock_bg.png"];
    if (!selPackagebtnlockbgTex) selPackagebtnlockbgTex = [[CCTextureCache sharedTextureCache] addImage:@"packagebtn_lock_selbg.png"];
    CCSprite *packageBgSpr;
    if (index > 0  && levelPackLocked) {
        packageBgSpr = [CCSprite spriteWithTexture:isSel ? selPackagebtnlockbgTex : packagebtnlockbgTex];
    } else {
        packageBgSpr = [CCSprite spriteWithTexture:isSel ? selPackagebtnbgTex : packagebtnbgTex];
    }
    
    //add btn text
    NSString *pn = [CommonUtils getPackageNameByRank:index];
    CCLabelTTF *packageNameText = [CCLabelTTF labelWithString:pn fontName:@"Verdana-Bold" fontSize:15];
    [packageNameText setColor:ccc3(155.0, 70.0, 0.0)];
    CGSize contentS = [packageBgSpr contentSize];
    [packageNameText setPosition:ccp(contentS.width/2, contentS.height/2)];
    [packageBgSpr addChild:packageNameText];
    
    return packageBgSpr;
}

- (void)showSettingScreen
{
    if ([CommonUtils isOnSound]) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];
    }
    [[CCDirector sharedDirector] pushScene:[CCTransitionSlideInR transitionWithDuration:0.2 scene:[SettingLayer scene]]];
}

- (void) enterStarter
{
    if ([CommonUtils isOnSound]) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];
    }
    CCScene *scene = [NavigateLayer sceneWithGameRank:0];
	[[CCDirector sharedDirector] replaceScene:scene];
}

- (void) enterMedium
{
    if ([CommonUtils isOnSound]) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];
    }
    
    if (levelPackLocked) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Unlock more level pack for $1.99?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Buy", nil];
        [alert show];
        return;
    }
    
    CCScene *scene = [NavigateLayer sceneWithGameRank:1];
	[[CCDirector sharedDirector] replaceScene:scene];
}

- (void) enterHard
{
    if ([CommonUtils isOnSound]) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];
    }
    
    if (levelPackLocked) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Unlock more level pack for $1.99?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Buy", nil];
        [alert show];
        return;
    }
    
    CCScene *scene = [NavigateLayer sceneWithGameRank:2];
	[[CCDirector sharedDirector] replaceScene:scene];
}

- (void) enterExtreme
{
    if ([CommonUtils isOnSound]) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];
    }
    
    if (levelPackLocked) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Unlock more level pack for $1.99?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Buy", nil];
        [alert show];
        return;
    }
    
    CCScene *scene = [NavigateLayer sceneWithGameRank:3];
	[[CCDirector sharedDirector] replaceScene:scene];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        if (![CommonUtils connectedToNetwork]) {
            [CommonUtils showNoNetworkAlert];
            return;
        }
        StoreKitManager *skm = [StoreKitManager getInstance];
        [skm initStoreKit];
        [skm purchaseItem:@"com.zlot.game.onenumber.unlocklevelpack"];
    }
}

- (void)unlockLevelPack
{
    levelPackLocked = NO;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *packLockedNum = [NSNumber numberWithBool:NO];
    [defaults setObject:packLockedNum forKey:@"packLocked"];
    
    [self removeChildByTag:1];
    [self addLevelPackMenu];
}

- (void)onEnter
{
	[super onEnter];
    StoreKitManager *skm = [StoreKitManager getInstance];
    if ([skm getIsUnlockLevelPack] && levelPackLocked) {
        [self unlockLevelPack];
    }
}

- (void)openRatePage
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", @"itms-apps://itunes.apple.com/cn/app/make-one/id882637207?mt=8"]]];
}

- (void)openSharePage
{
    //NSLog(@"open share page");
    NSString *textToShare = @"Make One is a ultra high difficult puzzle game. It is cool concept and challenge to your spatial imagination, logic thinking, and patience. http://itunes.apple.com/cn/app/make-one/id882637207?mt=8";
    NSArray *activityItems = @[textToShare];
    
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    
    controller.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,UIActivityTypeAddToReadingList,UIActivityTypePostToFlickr,UIActivityTypePostToVimeo,UIActivityTypeAirDrop];
    
    AppController *appController = [[UIApplication sharedApplication] delegate];
    [appController.navController presentViewController:controller animated:YES completion:nil];
    
}


@end

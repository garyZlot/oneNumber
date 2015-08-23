//
//  HelloWorldLayer.m
//  gathernumbers
//
//  Created by garyliumac on 14-3-20.
//  Copyright zlot 2014年. All rights reserved.
//


// Import the interfaces
#import "MainLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"
#import "CCDrawingPrimitives.h"
#import "NavigateLayer.h"
#import "GameEndLayer.h"
#import "PurchaseLayer.h"
#import "SimpleAudioEngine.h"
#import "CommonUtils.h"
#import "StoreKitManager.h"
#import "IntroLayer.h"

#pragma mark - HelloWorldLayer

@implementation MainLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+ (CCScene *) sceneWithGameRank: (int) r withLevel: (int) l
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MainLayer *layer = [MainLayer node];
	if (layer) {
        [layer initDataAtRank:r atLevel:l];
        [layer initScreen];
        [layer enterCurrentLevel];
    }
	// add layer as a child to scene
	[scene addChild:layer z:0 tag:0];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if (self=[super init]) {
        [self initCommonData];
	}
	return self;
}



- (void)initCommonData
{
    zOrderStep = 10;
    needCheckGameEnd = YES;
    movingOutTrap = NO;
    haveMovedByHint = NO;
    isCheckingGameOver = NO;
    enableHint = NO;
    defaultHintCount = 30;
    
    getStar = 3;
    NSArray *getStarTimeArray = [getStarTimeStr componentsSeparatedByString:@","];
    int i = 0;
    for (NSString *s in getStarTimeArray) {
        getStarTimeData[i] = [s intValue];
        i++;
    }
    
    NSArray *hintArray = [hintData componentsSeparatedByString:@","];
    hintDataArray = [[NSMutableArray alloc]init];
    for (NSString *s in hintArray) {
        [hintDataArray addObject:s];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *lp = [defaults objectForKey:@"levelProgress"];
    levelProgress = [lp intValue];
    
    [self updateHintsCountWithBuys:0];
}

- (void)updateHintsCountWithBuys:(int) count
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *hintCountNum = [defaults objectForKey:@"hintCount"];
    hintCount = hintCountNum ? [hintCountNum intValue] : defaultHintCount;
    
    if (count > 0) {
        hintCount = count + hintCount;
        NSNumber *hc = [NSNumber numberWithInt:hintCount];
        [defaults setObject:hc forKey:@"hintCount"];
    }
    
    if (hintCountText) {
        [hintCountText setString:[NSString stringWithFormat:@"%d", hintCount]];
    }
}


-(void) initScreen
{
    
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
    //start time
    //startTime = CACurrentMediaTime();
    
    //use time text
    elapsedTimeText = [CCLabelTTF labelWithString:@"00:00" fontName:@"ArialHebrew" fontSize:20];
    elapsedTimeText.position = ccp(screenSize.width - 58, 465 + iPhone4offset);
    [self addChild:elapsedTimeText z:2];
    
    //star sprite
    starTex0 = [[CCTextureCache sharedTextureCache] addImage:@"star0.png"];
    starTex1 = [[CCTextureCache sharedTextureCache] addImage:@"star1.png"];
    starTex2 = [[CCTextureCache sharedTextureCache] addImage:@"star2.png"];
    starTex3 = [[CCTextureCache sharedTextureCache] addImage:@"star3.png"];
    starSprite = [CCSprite spriteWithTexture:starTex3];
    starSprite.position = ccp(screenSize.width - 58, 450 + iPhone4offset);
    [self addChild:starSprite z:2];
    
    
    //add game background
    CCSprite *bg = [CCSprite spriteWithFile:iPhone5 ? @"main_bg.png" : @"main_bg_35.png"];
    bg.anchorPoint = CGPointMake(0, 0);
    //bg.position = ccp(screenSize.width/2, screenSize.height/2);
    [self addChild:bg z:0];
    [self setTouchEnabled:YES];
    
    //level text
    CCLabelTTF *levelStringText = [CCLabelTTF labelWithString:@"LEVEL" fontName:@"ArialHebrew" fontSize:10];
    [levelStringText setColor:ccc3(255, 168, 35)];
    levelStringText.position = ccp(screenSize.width/2, 468 + iPhone4offset);
    [self addChild:levelStringText z:2];
    levelText = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", level] fontName:@"ArialHebrew" fontSize:30];
    [levelText setColor:ccc3(255, 168, 35)];
    levelText.position = ccp(screenSize.width/2, 452 + iPhone4offset);
    [self addChild:levelText z:2];
    
    
    //restart menu to test
    CCSprite *restart = [CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"restart.png"]];
    CCSprite *selectedRestart = [CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"restart.png"]];
    selectedRestart.scale = 1.2;
    CCMenuItemSprite *restartItem = [CCMenuItemSprite itemWithNormalSprite:restart selectedSprite:selectedRestart target:self selector:@selector(resetGame)];
    restartMenu = [CCMenu menuWithItems: restartItem,nil];
    restartMenu.touchEnabled = YES;
    restartMenu.position = ccp(screenSize.width - 50, 30 + iPhone4offsetForBottomBtns);
    [self addChild:restartMenu z:2];
    
    //back menu to test
    CCSprite *back = [CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"backbtn.png"]];
    CCSprite *backs = [CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"backbtn.png"]];
    CCMenuItemSprite *backItem = [CCMenuItemSprite itemWithNormalSprite:back selectedSprite:backs target:self selector:@selector(backNavScreen)];
    backMenu = [CCMenu menuWithItems: backItem,nil];
    backMenu.touchEnabled = YES;
    backMenu.position = ccp(30, 30 + iPhone4offsetForBottomBtns);
    [self addChild:backMenu z:2];
    
    //hint menu to show hand to hint
    hintOnTex = [[CCTextureCache sharedTextureCache] addImage:@"hint_on.png"];
    hintOffTex = [[CCTextureCache sharedTextureCache] addImage:@"hint_off.png"];
    hintSprite = [CCSprite spriteWithTexture:hintOffTex];
    hintSpriteSel = [CCSprite spriteWithTexture:hintOffTex];
    hintSpriteSel.scale = 1.2;
    
    CCMenuItemSprite *hintItem = [CCMenuItemSprite itemWithNormalSprite:hintSprite selectedSprite:hintSpriteSel target:self selector:@selector(toggleHint:)];
    hintMenu = [CCMenu menuWithItems: hintItem,nil];
    hintMenu.touchEnabled = YES;
    hintMenu.position = ccp(screenSize.width/2, 30 + iPhone4offsetForBottomBtns);
    [self addChild:hintMenu z:2];
    
    //hint count
    CCSprite *hintCountBg = [CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"hint_count.png"]];
    hintCountBg.position = ccp(screenSize.width/2 + 15, 35 + iPhone4offsetForBottomBtns);
    [self addChild:hintCountBg z:3];
    
    hintCountText = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", hintCount] fontName:@"ArialHebrew" fontSize:16];
    hintCountText.position = hintCountBg.position;
    [self addChild:hintCountText z:4];
}


- (void)showHelpAtIndex:(int) index atPos:(CGPoint) pos
{
    CCSprite *helpBg = [CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"help_bg.png"]];
    helpBg.position = pos;
    [self addChild:helpBg z:3 tag:8];
    NSString *helpText;
    switch (index) {
        case 1:
            helpText = @"The bigger number can eat smaller number.";
            break;
        case 2:
            helpText = @"The same and joint numbers can be moved.";
            break;
        case 3:
            helpText = @"The fixed number can be eaten by any number.";
            break;
        default:
            helpText = @"";
            break;
    }
    CCLabelTTF *helpLabel = [CCLabelTTF labelWithString:helpText fontName:@"ArialHebrew" fontSize:18 dimensions:CGSizeMake(200,100) hAlignment:UITextAlignmentLeft];
    helpLabel.color = ccc3(153.0, 69.0, 0.0);
    helpLabel.position = ccp(pos.x, pos.y - 30);
    [self addChild:helpLabel z:4 tag:18];
}

- (void)hideHelp
{
    //CCScene *runningScene = [[CCDirector sharedDirector] runningScene];
    //[runningScene getChildByTag:0];
    [self removeChildByTag:8];
    [self removeChildByTag:18];
}

- (void)toggleHintBtnStatus:(BOOL) enabled
{
    [hintSprite setTexture:enabled ? hintOnTex : hintOffTex];
    [hintSpriteSel setTexture:enabled ? hintOnTex : hintOffTex];
}

- (void)updateTime
{
    elapsedTime++;
    int second = elapsedTime % 60;
    int minute = elapsedTime / 60;
    NSString *sStr = [NSString stringWithFormat: (second>9) ? @"%d" : @"0%d", second];
    NSString *mStr = [NSString stringWithFormat: (minute>9) ? @"%d:" : @"0%d:", minute];
    NSString *timeStr = [NSString stringWithFormat:@"%@%@", mStr, sStr];
    [elapsedTimeText setString:timeStr];
    
    [self updateStarSpriteByTime:elapsedTime];
}

- (void)updateStarSpriteByTime: (int) t
{
    int basePos = 3 * (difficulty-1);
    int treeStarTime = getStarTimeData[basePos];
    int twoStarTime = getStarTimeData[basePos+1];
    int oneStarTime = getStarTimeData[basePos+2];
    
    int currentStar = 0;
    if (t <= treeStarTime) currentStar = 3;
    if (t>treeStarTime && t <= twoStarTime) currentStar = 2;
    if (t>twoStarTime && t <= oneStarTime) currentStar = 1;
    
    if (currentStar != getStar) {
        getStar = currentStar;
        [starSprite setTexture:[self getTextureByStar:getStar]];
        /*
        if (getStar > 0) {
            [starSprite setTexture:[self getTextureByStar:getStar]];
            if (![starSprite visible]) [starSprite setVisible:YES];
        } else {
            [starSprite setVisible:NO];
        }
         */
    }
}

- (CCTexture2D *) getTextureByStar: (int) s
{
    if (s==0) return starTex0;
    if (s==1) return starTex1;
    if (s==2) return starTex2;
    if (s==3) return starTex3;
    return nil;
}

- (void) backNavScreen
{
    if ([CommonUtils isOnSound]) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];
    }
    [self unschedule:@selector(updateTime)];
    [[CCDirector sharedDirector] replaceScene:[NavigateLayer sceneWithGameRank:rank]];
}


- (void) initDataAtRank: (int) gameRank atLevel:(int) gameLevel
{
    level = gameLevel;
    rank = gameRank;
   
    switch (gameRank) {
        case 0:
            levelBaseNo = 0;
            gameData = starterDataStr;
            break;
        case 1:
            levelBaseNo = 10;
            gameData = easyDataStr;
            break;
        case 2:
            levelBaseNo = 20;
            gameData = mediumDataStr;
            break;
        case 3:
            levelBaseNo = 35;
            gameData = hardDataStr;
            break;
        default:
            break;
    }
    int m = levelBaseNo*COL;
    int n = 0;
    int numNo = -1;
    int itemNo = -1;
    int itemDataPos = 0;
    int itemDataLen = 0;
    int currentLevel = levelBaseNo;
    BOOL isNumberData = YES;
    for (int i=0; i<[gameData length]; i++) {
        NSString *ch = [gameData substringWithRange:NSMakeRange(i,1)];
        //NSLog(@"ch is %@ at %d",  ch, i);
        if (![ch isEqualToString:@","] && isNumberData) {
            allNumberData[m][n] = [ch isEqualToString:@"x"] ? 100 : [ch intValue];
            n++;
            if (n==ROW) n = 0;
            numNo++;
            if ((numNo+1)%ROW == 0 && numNo>0) m++;
            //NSLog(@"m n is [%d, %d]",  m, n);
            if (m % COL == 0 && m>0 && n==0) {
                itemDataPos = i+2;
                itemDataLen = 0;
                isNumberData = NO;
            }
        }
        
        if (!isNumberData) {
            itemDataLen++;
            if ([ch isEqualToString:@","]) itemNo++;
            if (itemNo == 4) {
                NSString *itemDataStr = [gameData substringWithRange:NSMakeRange(itemDataPos, itemDataLen-3)];
                isNumberData = YES;
                itemNo = -1;
                NSArray *itemsData = [itemDataStr componentsSeparatedByString:@","];
                //NSLog(@"items is %@", [itemsData objectAtIndex:0]);
                for (int i=0; i<itemsData.count; i++) {
                    allItemData[currentLevel][i] = [[itemsData objectAtIndex:i] intValue];
                }
                currentLevel ++;
            }
        }
        
    }
    currentLevelCount = m / COL;
}

- (void)enterCurrentLevel
{
    [elapsedTimeText setString:@"00:00"];
    elapsedTime = 0;
    
    //timer = [[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime) userInfo:Nil repeats:YES] retain];
    
    [self schedule:@selector(updateTime) interval:1.0f];
    
    if (level > currentLevelCount) {
        [self initDataAtRank:rank+1 atLevel:level];
    }
    [levelText setString:[NSString stringWithFormat:@"%d", level]];
    [self updateLevelData];
    [self updateGame];
    if (level < 4 && hintCount > 0) {//level > levelProgress &&
        enableHint = YES;
        [self toggleHintBtnStatus:YES];
        [self showHintAnimationAtLevel:level actionNo:0];
    }
}

- (void)enterNextLevel
{
    if ([CommonUtils isOnSound]) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];
    }
    
    if (level == 10) {
        if ([CommonUtils isLevelPackLocked]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"You must unlock more level pack firstly." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
    }
    
    if (level>=50) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Join me in next version if you like 'Make One'." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    level++;
    [self enterCurrentLevel];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [[CCDirector sharedDirector] replaceScene:[IntroLayer scene]];
    }
}

- (void)toggleHint:(id)sender
{
    if (sender) {
        if ([CommonUtils isOnSound]) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];
        }
        if (hintCount <= 0) {
            [self showPurchaseLayer];
            return;
        }
    }
    
    enableHint = !enableHint;
    if (enableHint) {
        [self updateGame];
        [self toggleHintBtnStatus:YES];
        [self showHintAnimationAtLevel:level actionNo:0];
    } else {
        [self hideHelp];
        hintActionNo = 0;
        [self toggleHintBtnStatus:NO];
        CCNode *finger = [self getChildByTag:1000];
        if (finger) {
            [finger stopAllActions];
            [self removeChild:finger];
        }
    }
}

- (void)showPurchaseLayer
{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    PurchaseLayer  *purchaseLayer = [PurchaseLayer node];
    purchaseLayer.position = ccp(0, screenSize.height);
    
    CCScene *scene = [[CCDirector sharedDirector] runningScene];
    [scene addChild:purchaseLayer z:1 tag:2];
    
    [purchaseLayer runAction:[CCMoveTo actionWithDuration:0.5 position:ccp(0, 0)]];
}

- (void)updateHintPosArrayByLevel: (int) gameLevel
{
    NSString *hintDataStr = [hintDataArray objectAtIndex:gameLevel-1];
    int m = 0;
    int n = 0;
    for (int i=0; i<[hintDataStr length]; i++) {
        NSString *ch = [hintDataStr substringWithRange:NSMakeRange(i,1)];
        int posValue = [ch intValue];
        
        currentHintPosArray[m][n] = posValue;
        n++;
        if (n==4) {
            n=0;
            m++;
        }
    }
    currentHintStepCount = m-1;
}


- (void)showHintAnimationAtLevel: (int) gameLevel actionNo:(int) no
{
    if (no == 0) {
        [self updateHintPosArrayByLevel:gameLevel];
    }
    
    if (currentHintStepCount<no) return;
    
    haveMovedByHint = NO;
    hintActionNo = no;
    
    CGPoint startP = [self getPositonAtCol:currentHintPosArray[no][0] atRow:currentHintPosArray[no][1]];
    startP = ccp(startP.x + 20, startP.y);
    hintPos[0] = currentHintPosArray[no][0];
    hintPos[1] = currentHintPosArray[no][1];
    hintPos[2] = currentHintPosArray[no][2];
    hintPos[3] = currentHintPosArray[no][3];
    CGPoint endP = [self getPositonAtCol:currentHintPosArray[no][2] atRow:currentHintPosArray[no][3]];
    endP = ccp(endP.x + 20, endP.y);
    
    CCSprite *finger = [CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"finger.png"]];
    finger.position = startP;
    [self addChild:finger z:1000 tag:1000];
    
    id a1 = [CCMoveTo actionWithDuration:1.0 position:endP];
    id a2 = [CCMoveTo actionWithDuration:0.01 position:startP];
    
    id action = [CCRepeatForever actionWithAction:[CCSequence actions:a1,a2,nil]];
    
    [finger runAction:action];
    
    //show help
    if (level < 4) {
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        CGPoint p = ccp(screenSize.width/2, 370.0 + iPhone4offset);
        if (level == 1 && hintActionNo == 0) {
            [self showHelpAtIndex:1 atPos:p];
        }
        
        if (level == 2 && hintActionNo == 0) {
            [self showHelpAtIndex:2 atPos:p];
        }
        
        if (level == 3 && hintActionNo == 2) {
            [self showHelpAtIndex:3 atPos:p];
        }
    }
}


- (void) retryGame
{
    if ([CommonUtils isOnSound]) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];
    }
    [self schedule:@selector(updateTime) interval:1.0f];
    [self updateGame];
}

- (void)resetGame
{
    if ([CommonUtils isOnSound]) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];
    }
    if (enableHint) [self toggleHint:nil];
    [self updateGame];
}

-(void) updateGame
{
    CCScene *scene = [[CCDirector sharedDirector] runningScene];
    CCNode *endLayer = [scene getChildByTag:1];
    if (endLayer) {
        [scene removeChild:endLayer];
    }
    [self enableMainLayerTouch:YES];
    
    [self removeBlocks];
    [self removeBarriers];
    [self removeItems];
    
    blockArray = [[NSMutableArray alloc] init];
    barrierArray = [[NSMutableArray alloc] init];
    itemArray = [[NSMutableArray alloc] init];
    movedBlockArray = [[NSMutableArray alloc] init];
    directionArray = [[NSArray alloc] initWithObjects:@(-1),@2,@1,@(-2), nil];
    for (int i=0; i<6; i++) {
        for (int j=0; j<6; j++) {
            itemLayout[i][j] = 0;
        }
    }
    
    [self addNumBlocksWithArray:numberData];
    [self addItemsWithArray:allItemData[level-1]];
    
    targetCol = 0;
    targetRow = 0;
    movedDirection = 0;
}

- (void) updateLevelData
{
    int startI = COL * (level-1);
    for (int i=0; i<COL; i++) {
        for (int j=0; j<ROW; j++) {
            numberData[i][j] = allNumberData[startI][j];
            if (j == (ROW-1)) {
                startI++;
            }
        }
    }
}

- (void) addItemsWithArray:(int [4]) itemData
{
    NSString *targetPos = [NSString stringWithFormat:@"%d",itemData[0]];
    int targetC = [[targetPos substringWithRange:NSMakeRange(0, 1)] intValue];
    int targetR = [[targetPos substringWithRange:NSMakeRange(1, 1)] intValue];
    itemLayout[targetC][targetR] = 1;
    endTargetPos[0]= targetC;
    endTargetPos[1]= targetR;
    CCSprite *targetSprite = [CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"target.png"]];
    targetSprite.position = [self getPositonAtCol:targetC atRow:targetR];
    [self addChild:targetSprite z:0];
    [itemArray addObject:targetSprite];
    
    if (itemData[1] != 0 ) { // for trap
        NSString *trapPos = [NSString stringWithFormat:@"%d", itemData[1]];
        for (int i=0; i<trapPos.length; i++) {
            int trapC = [[trapPos substringWithRange:NSMakeRange(i,1)] intValue];
            int trapR = [[trapPos substringWithRange:NSMakeRange(++i,1)] intValue];
            itemLayout[trapC][trapR] = 2;
            CCSprite *trapSprite = [CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"trap.png"]];
            trapSprite.position = [self getPositonAtCol:trapC atRow:trapR];
            [self addChild:trapSprite z:100];
            [itemArray addObject:trapSprite];
        }
    }

    if (itemData[2] != 0) { // for gate
        //use 1~8 for pos
        NSString *gatePos = [NSString stringWithFormat:@"%d", itemData[2]];
        int allGatePos[][4] = {{1,5,1,0},{2,5,2,0},{3,5,3,0},{4,5,4,0},{5,4,0,4},{5,3,0,3},{5,2,0,2},{5,1,0,1}};
        
        for (int i=0; i<gatePos.length; i++) {
            int posNo = [[gatePos substringWithRange:NSMakeRange(i,1)] intValue];
            //int posInfo[4] = allGatePos[posNo-1];
            
            for (int j=0; j<4; j++) {
                int gateC = allGatePos[posNo-1][j++];
                int gateR = allGatePos[posNo-1][j];
                itemLayout[gateC][gateR] = 3;
                CCSprite *gateSprite;
                CGPoint pos = [self getPositonAtCol:gateC atRow:gateR];
                if (gateC == 0 || gateC == 5) {
                    gateSprite = [CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"gate_h.png"]];
                    pos = ccp(pos.x + ((gateC == 0) ? 26 : - 28), pos.y);
                } else {
                    gateSprite = [CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"gate_v.png"]];
                    pos = ccp(pos.x, pos.y  + ((gateR == 0) ? 30 : - 36));
                }
                gateSprite.position = pos;
                [self addChild:gateSprite z:1];
                [itemArray addObject:gateSprite];
            }
        }
    }
    
    if (itemData[3] != 0) { // for difficulty
        difficulty = itemData[3];
    }
    

}

- (void) addNumBlocksWithArray:(int [COL][ROW]) numbers
{
    for (int i=0; i<COL; i++) {
        for (int j=0; j<ROW; j++) {
            int num = numbers[i][j];
            if (num != 0) {
                int col = i + 1;
                int row = j + 1;
                [self addBlockAtCol:col atRow:row withNum:num];
            }
        }
    }
}

- (Block *)addBlockAtCol:(int) col atRow:(int) row withNum: (int) num
{
    Block *b = [Block spriteWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"block.png"]];
    [b setIsBarrier: num == 100 ? YES : NO];
    b.position = [self getPositonAtCol:col atRow:row];
    [b setCol:col];
    [b setRow:row];
    
    NSString *numStr = b.isBarrier ? @"X" : [NSString stringWithFormat:@"%d", num];
    CCLabelTTF *b_num = [CCLabelTTF labelWithString:numStr fontName:@"ArialHebrew-Bold" fontSize:40];
    b_num.position = b.position;
    [b_num setColor:ccc3(153, 69, 0)];
    
    [b setNum:num];
    [b setNumLabel:b_num];
    [self addChild:b z:1];
    [self addChild:b_num z:2];
    
    //visible barrier
    if (b.isBarrier) {
        [b setVisible:NO];
        CCSprite *vb = [CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"barrier.png"]];
        vb.position = b.position;
        [self addChild:vb z:3];
        [barrierArray addObject:vb];
    }
    
    [blockArray addObject:b];
    
    return b;
}


- (void) removeBlocks
{
    for (int i=0; i<blockArray.count; i++) {
        Block *b = [blockArray objectAtIndex:i];
        [self removeChild:b];
        [self removeChild:b.numLabel];
    }
}

- (void) removeBarriers
{
    for (int i=0; i<barrierArray.count; i++) {
        CCSprite *b = [barrierArray objectAtIndex:i];
        [self removeChild:b];
    }
}

- (void) removeItems
{
    for (int i=0; i<itemArray.count; i++) {
        CCSprite *s = [itemArray objectAtIndex:i];
        [self removeChild:s];
    }
}

- (CGPoint) getPositonAtCol:(int) col atRow: (int) row
{
    CGFloat initX = 112/2;
    CGFloat initY = 256/2 + iPhone4offset;
    CGPoint p = ccp(initX + (col-1)*width_col, initY + (row - 1)*height_row);
    return p;
}

- (CGRect) getRectForSprite: (CCSprite *)s
{
	float w = [s contentSize].width * s.scaleX;
	float h = [s contentSize].height * s.scaleY;
	CGPoint point = CGPointMake([s position].x - (w/2), [s position].y - (h/2));
	return CGRectMake(point.x, point.y, w, h);
}


- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (touchedBlock) return;
    if ([touches count]==1)   {
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInView:[touch view]];
        gestureStartPoint = [[CCDirector sharedDirector] convertToGL:location];
        for (int n=0; n<blockArray.count; n++) {
            Block *b = [blockArray objectAtIndex:n];
            CGRect rect = [self getRectForSprite:b];
            if (CGRectContainsPoint(rect, gestureStartPoint)) {
                if (b.isBarrier) break;
                if (enableHint) {
                    if (b.col != hintPos[0] || b.row != hintPos[1]) {
                        break;
                    }
                }
                touchedBlock = b;
                if ([self isTrapedForBlock:b]) {
                    if (b.zOrder < 100) {
                        [b setZOrder:b.zOrder + 100];
                        [b.numLabel setZOrder:b.numLabel.zOrder + 100];
                    } else if (b.zOrder == 100) {
                        [b setZOrder:b.zOrder + 50];
                        [b.numLabel setZOrder:b.numLabel.zOrder + 50];
                    }
                }
                break;
            }
        }
    }
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!touchedBlock) return;
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:[touch view]];
    CGPoint currentPosition = [[CCDirector sharedDirector] convertToGL:location];
    
    CGFloat deltaX = currentPosition.x - gestureStartPoint.x;
    CGFloat deltaY = currentPosition.y - gestureStartPoint.y;
    CGFloat absdeltaX = fabsf(deltaX);
    CGFloat absdeltaY = fabsf(deltaY);
    
    if (absdeltaX >= kMinimumGestureLength && absdeltaY <= kMaximumVariance) {
        movedDirection = deltaX>0 ? 1 : -1;
    } else if(absdeltaY >= kMinimumGestureLength && absdeltaX <= kMaximumVariance) {
        movedDirection = deltaY>0 ? 2 : -2;
    }
    
    if (movedDirection != 0) {
        if (!touchedBlock.isChecked) {
            [self checkMovableForBlock:touchedBlock atDirection:movedDirection isPulled:NO];
        }
        if (touchedBlock.isCanMoved) {
            if ([self isTrapedForBlock:touchedBlock]) {
                movingOutTrap = YES;
            }
            for (int i=0; i<movedBlockArray.count; i++) {
                Block *b = [movedBlockArray objectAtIndex:i];
                if (b.zOrder <= 100) {
                    [b setZOrder:b.zOrder + zOrderStep];
                    [b.numLabel setZOrder:b.numLabel.zOrder + zOrderStep];
                }
                
                if (abs(movedDirection) == 1) {
                    deltaX = deltaX > width_col ? width_col : (deltaX < -width_col ? -width_col : deltaX);
                    b.position = ccp([self getPositonAtCol:b.col atRow:b.row].x + deltaX, b.position.y);
                } else if (abs(movedDirection) == 2) {
                    deltaY = deltaY > height_row ? height_row : (deltaY < -height_row ? -height_row : deltaY);
                    b.position = ccp(b.position.x, [self getPositonAtCol:b.col atRow:b.row].y + deltaY);
                }
                b.numLabel.position = b.position;
            }
        }
    }
}


- (BOOL)checkMovableForBlock: (Block *) b atDirection: (int) direction isPulled:(BOOL) pulled
{
    [b setIsChecked:YES];
    if ([b isBarrier]) return NO;
    int tCol = (abs(direction) == 1) ? (b.col + direction) : b.col;
    int tRow = (abs(direction) == 2) ? (b.row + direction/2) : b.row;
    Block *tb;
    //if (tCol>0 && tCol<=COL && tRow>0 && tRow<=ROW) { //valid col/row
        tb = [self getTargetBlockAtCol:tCol atRow:tRow];
        if (tb) {
            if (tb.num < b.num || (tb.num > b.num && [self isTrapedForBlock:tb])) {
                [b setIsCanMoved:YES];
            } else if (tb.num == b.num) {
                if (tb == touchedBlock && !tb.isCanMoved && tb.isChecked && !pulled) { //is checking
                    [b setIsChecked:NO];
                } else if (pulled || [self isTrapedForBlock:tb] || (tb.isChecked && tb.isCanMoved)) {
                    [b setIsCanMoved:YES];
                } else if (!tb.isChecked) {
                    if ([self checkMovableForBlock:tb atDirection:direction isPulled:NO]) {
                        [b setIsCanMoved:YES];
                    }
                }
            }
            
        }
        
        if ((!tb && ![self isWallTargetAtCol:tCol atRow:tRow]) || b.isCanMoved) {
            
            if (touchedBlock == b) {
                //check the conjoint blocks at other three direction
                
                Block *cba,*cbb,*cbc;
                if (abs(direction) == 1) { //check same col
                    cba = [self getBlockAtCol: b.col atRow:b.row+1];
                    cbb = [self getBlockAtCol:b.col atRow:b.row-1];
                    cbc = [self getBlockAtCol:(b.col - direction) atRow:b.row];
                }
                    
                if (abs(direction) == 2) { //check same row
                    cba = [self getBlockAtCol: b.col-1 atRow:b.row];
                    cbb = [self getBlockAtCol:b.col+1 atRow:b.row];
                    cbc = [self getBlockAtCol:b.col atRow:(b.row - direction/2)];
                }
                
                BOOL hasCanMovedConjointBlock = NO;
                if (cba && cba.num == b.num && !cba.isChecked && ![self isTrapedForBlock:cba]) {
                    if ([self checkMovableForBlock:cba atDirection:direction isPulled:NO]) {
                        hasCanMovedConjointBlock = YES;
                    }
                }
                
                if (cbb && cbb.num == b.num && !cbb.isChecked && ![self isTrapedForBlock:cbb]) {
                    if ([self checkMovableForBlock:cbb atDirection:direction isPulled:NO]) {
                        hasCanMovedConjointBlock = YES;
                    }
                }
                
                if (cbc && cbc.num == b.num && !cbc.isChecked && ![self isTrapedForBlock:cbc]) {
                    if ([self checkMovableForBlock:cbc atDirection:direction isPulled:YES]) {
                        hasCanMovedConjointBlock = YES;
                    }
                }

                if (hasCanMovedConjointBlock) {
                    [b setIsCanMoved:YES];
                }
                
            } else {
                [b setIsCanMoved:YES];
            }
        }
    //}
    
    if (b.isCanMoved) {//check same number and conjoint block
        int tNum = tb ? tb.num : 0;
        if (!isCheckingGameOver) {
            [self addMovedBlock:b targetCol:tCol targetRow:tRow targetNum:tNum];
        }
        
        if (touchedBlock != b && ![self isTrapedForBlock:b]) {
            int conjointCol, conjointRow;
            for (int i=0; i<directionArray.count; i++) {
                int direc = [[directionArray objectAtIndex:i] intValue];
                if (direc != direction) {
                    conjointCol = (abs(direc) == 1) ? (b.col + direc) : b.col;
                    conjointRow = (abs(direc) == 2) ? (b.row + direc/2) : b.row;
                    Block *cb = [self getBlockAtCol:conjointCol atRow:conjointRow];
                    if (cb && cb.num == b.num && !cb.isChecked && ![self isTrapedForBlock:cb]) {
                        [self checkMovableForBlock:cb atDirection:direction isPulled:NO];
                    }
                }
            }
        }
        
    }
    
    return b.isCanMoved;
}

- (BOOL)isWallTargetAtCol:(int) col atRow:(int) row
{
    return (col<1 || col>COL || row<1 || row>ROW) && ![self hasGateAtCol:col atRow:row];
}

- (void) addMovedBlock:(Block *) b targetCol:(int) col targetRow:(int) row targetNum: (int) num
{
    [b setIsCanMoved:YES];
    NSArray *tbInfo = [[NSArray alloc] initWithObjects:@(col), @(row), @(num), nil];
    [b setTargetInfo:tbInfo];
    [movedBlockArray addObject:b];
    
    if (col<1 || col>COL || row<1 || row>ROW) { //target is another side through gate
        //copy current block to show a moving action
        int newBlockCol, newBlockRow;
        newBlockCol = (abs(movedDirection) == 2) ? col : col - movedDirection * (COL+1);
        newBlockRow = (abs(movedDirection) == 1) ? row : row - movedDirection/2 * (ROW+1);
        Block *nb = [self addBlockAtCol:newBlockCol atRow:newBlockRow withNum:b.num];
        
        int newTargetCol,newTargetRow;
        newTargetCol = (abs(movedDirection) == 1) ? (newBlockCol + movedDirection) : newBlockCol;
        newTargetRow = (abs(movedDirection) == 2) ? (newBlockRow + movedDirection/2) : newBlockRow;
        [self addMovedBlock:nb targetCol:newTargetCol targetRow:newTargetRow targetNum:num];
    }
}

- (Block *)getTargetBlockAtCol:(int) col atRow: (int) row
{
    Block *b;
    if (!(b = [self getBlockAtCol:col atRow:row])) {
        int tCol,tRow;
        if ([self hasGateAtCol:col atRow:row]) { // if have gate to enter
            
            tCol = (abs(movedDirection) == 2) ? col : col - movedDirection * COL;
            tRow = (abs(movedDirection) == 1) ? row : row - movedDirection/2 * ROW;
            
            b = [self getBlockAtCol:tCol atRow:tRow];
        }
    }
    
    return b;
}

- (Block *)getBlockAtCol:(int) col atRow: (int) row
{
    if ([self outOfScopeAtCol:col atRow:row]) return nil;
    for (int i=0; i<blockArray.count; i++) {
        Block *block = [blockArray objectAtIndex:i];
        if (block.col == col && block.row == row) {
            return block;
        }
    }
    return nil;
}

- (BOOL)outOfScopeAtCol:(int) col atRow: (int) row
 {
    return (col<1 || col>COL || row<1 || row>ROW);
}

- (BOOL)hasGateAtCol:(int) c atRow: (int) r
{
    return itemLayout[c][r] == 3;
}

- (BOOL)isTrapedForBlock:(Block *) b
{
    return [self hasTrapAtCol:b.col atRow:b.row];
}

- (BOOL)hasTrapAtCol:(int) c atRow: (int) r
{
    return itemLayout[c][r] == 2;
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{

    if (!touchedBlock) return;
    if([touches count]==1){
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInView: [touch view]];
        CGPoint currentPosition = [[CCDirector sharedDirector] convertToGL:location];
        CGFloat deltaX = currentPosition.x - gestureStartPoint.x;
        CGFloat deltaY = currentPosition.y - gestureStartPoint.y;
        CGFloat absdeltaX = fabsf(deltaX);
        CGFloat absdeltaY = fabsf(deltaY);
        
        BOOL needWaitForAnimation = NO;
        if (((abs(movedDirection) == 1) && (absdeltaX < width_col/2)) ||
            ((abs(movedDirection) == 2) && (absdeltaY < height_row/2))) {
            [self restoreMovedBlocksPosition];
        } else {
            if (enableHint) {
                NSArray *tInfo = touchedBlock.targetInfo;
                
                int tCol = [[tInfo objectAtIndex:0] intValue];
                int tRow = [[tInfo objectAtIndex:1] intValue];
                
                int tColByHint = hintPos[2];
                int tRowByHint = hintPos[3];

                if (tCol == tColByHint && tRow == tRowByHint) {
                    needWaitForAnimation = [self updateMovedBlockPosition];
                } else {
                    [self restoreMovedBlocksPosition];
                }
            } else {
                needWaitForAnimation = [self updateMovedBlockPosition];
            }
        }
        
        
        needCheckGameEnd = YES;
        [self resetStatusAfterMove];
        
        if (enableHint && haveMovedByHint) {
            if (level < 4) {
                [self hideHelp];
            }
            
            hintCount--;
            if (hintCount>=0) {
                [hintCountText setString:[NSString stringWithFormat:@"%d", hintCount]];
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSNumber *hintCountNum = [NSNumber numberWithInt:hintCount];
                [defaults setObject:hintCountNum forKey:@"hintCount"];
                
                if (hintCount>0) {
                    [self showHintAnimationAtLevel:level actionNo:++hintActionNo];
                } else {
                    [self toggleHint:nil];
                }
                
            }
        }
    }

}

- (int *)getClonedBlockPosPassGateByHint
{
    int tCol = (hintPos[0] == hintPos[2]) ? hintPos[0] : ((hintPos[0] > hintPos[2]) ? 5 : 0);
    int tRow = (hintPos[1] == hintPos[3]) ? hintPos[1] : ((hintPos[1] > hintPos[3]) ? 5 : 0);
    int *target = malloc(2 * sizeof(int));
    target[0] = tCol;
    target[1] = tRow;
    return target;
}


- (void) restoreMovedBlocksPosition
{
    for (Block *b in movedBlockArray) {
        if (b.col>COL || b.col<1 || b.row>ROW || b.row<1) { // added for moving out of gate, need to remove
            [self removeBlock:b];
        }
        b.position = [self getPositonAtCol:b.col atRow:b.row];
        b.numLabel.position = b.position;
    }
}


- (void)removeBlock:(Block *) b
{
    [self removeChild:b];
    [self removeChild:b.numLabel];
    int bIndex = [blockArray indexOfObject:b];
    [blockArray removeObjectAtIndex:bIndex];
}


- (BOOL) updateMovedBlockPosition
{
    BOOL needAnimation = NO;
    for (Block *b in movedBlockArray) {
        NSArray *tInfo = b.targetInfo;
        
        int tCol = [[tInfo objectAtIndex:0] intValue];
        int tRow = [[tInfo objectAtIndex:1] intValue];
        int tNum = [[tInfo objectAtIndex:2] intValue];
        //target is smaller number or is traped then can eat
        if (tNum != 0 && (tNum < b.num  || (!movingOutTrap && [self hasTrapAtCol:tCol atRow:tRow]))) {
            needAnimation = YES;
            //remove smaller target block
            Block *tb = [self getBlockAtCol:tCol atRow:tRow];
            if (tb) {
                [self removeBlock:tb];
            }
        }
        
        if (tCol<1 || tCol>COL || tRow<1 || tRow>ROW) { // out of gate
            [self removeBlock:b];
        }
        
        [self updateNewBlockStatus:self withBlock:b];
    }
    return needAnimation;
}

- (void) updateNewBlockStatus:(int) sender withBlock:(Block *) b
{
    if (b.parent) {
        NSArray *tInfo = b.targetInfo;
        
        
        
        int tCol = [[tInfo objectAtIndex:0] intValue];
        int tRow = [[tInfo objectAtIndex:1] intValue];
        int tNum = [[tInfo objectAtIndex:2] intValue];
        int newNum = 0;
        
        int sColByHint = hintPos[0];
        int sRowByHint = hintPos[1];
        if ([self outOfScopeAtCol:hintPos[2] atRow:hintPos[3]]) { // pass gate
            int *target = [self getClonedBlockPosPassGateByHint];
            sColByHint = target[0];
            sRowByHint = target[1];
            free(target);
        }
        
        if (enableHint && b.col == sColByHint && b.row == sRowByHint) { // judge if the Hint block is moved
            if (b.col != tCol || b.row != tRow) {
                haveMovedByHint = YES;
                /*
                CCNode *finger = [self getChildByTag:1000];
                if (finger) {
                    [finger stopAllActions];
                    [self removeChild:finger];
                }
                 */
                [self removeChildByTag:1000 cleanup:YES];
            }
        }
        
        
        //target is smaller number or is traped then can eat
        if (tNum != 0 && (tNum < b.num  || (!movingOutTrap && [self hasTrapAtCol:tCol atRow:tRow]))) {
            newNum = (b.num + tNum);
        }
        
        b.position = [self getPositonAtCol:tCol atRow:tRow];
        b.numLabel.position = b.position;
        [b setCol:tCol];
        [b setRow:tRow];
        
        if ([CommonUtils isOnSound]) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"blockmove.caf"];
        }
        
        if (newNum != 0) {
            [self setTouchEnabled:NO];
            [self flipBlock:b];
            [b setNum:newNum];
            [self flipNumber:b];
        }
    }
}

- (void) flipBlock : (CCNode *) node
{
    float d = 0.3; // duration
    CCEaseExponentialIn *flipHalf = [CCEaseExponentialIn actionWithAction:[CCActionTween actionWithDuration:d key:@"scaleX" from:-1.0 to:0.0]];
    CCEaseExponentialOut *flipRemainingHalf = [CCEaseExponentialOut actionWithAction:[CCActionTween actionWithDuration:d key:@"scaleX" from:0.0 to:1.0]];
    CCSequence* seq = [CCSequence actions:flipHalf,flipRemainingHalf, nil];
    [node runAction:seq];
}

- (void) flipNumber : (Block *) b
{
    float d = 0.3; // duration
    CCEaseExponentialIn *flipHalf = [CCEaseExponentialIn actionWithAction:[CCActionTween actionWithDuration:d key:@"scaleX" from:1.0 to:0.0]];
    CCCallFuncND *call = [CCCallFuncND actionWithTarget:self selector:@selector(updateNumString:block:) data:(__bridge void *)(b)];
    CCEaseExponentialOut *flipRemainingHalf = [CCEaseExponentialOut actionWithAction:[CCActionTween actionWithDuration:d key:@"scaleX" from:0.0 to:1.0]];
    CCSequence* seq = [CCSequence actions:flipHalf,call,flipRemainingHalf, nil];
    [b.numLabel runAction:seq];
}

- (void) updateNumString: (int) sender block:(Block *) b
{
    [b.numLabel setString:[NSString stringWithFormat:@"%d", b.num]];
}


- (void) resetStatusAfterMove
{
    [self setTouchEnabled:YES];
    movedDirection = 0;
    movingOutTrap = NO;
    [movedBlockArray removeAllObjects];
    [self restoreBlocksStatus];
    touchedBlock = nil;
    
    if (needCheckGameEnd) {
        if ([self checkGameEnd]) {
            if (enableHint) {
                [self toggleHint:nil];
            }
            Block *b = [self getLeftOneBlock];
            if (b) {
                if (b.col == endTargetPos[0] && b.row == endTargetPos[1]) {
                    NSLog(@"--------Game Success--------");
                    [self enableMainLayerTouch:NO];
                    [self showGameEndViewWithWin:YES];
                    if (level > levelProgress) {
                        levelProgress = level;
                        [self storeGameStatueWithLevel:level];
                    }
                    return;
                }
            }
            NSLog(@"----------Game Over----------");
            [self enableMainLayerTouch:NO];
            [self showGameEndViewWithWin:NO];
        }
    }
}

- (Block *)getLeftOneBlock
{
    int count = 0;
    Block *leftBlock;
    for (int i=0; i<blockArray.count; i++) {
        Block *b = [blockArray objectAtIndex:i];
        if (b.num != 100) {
            count++;
            leftBlock = b;
        }
    }
    return (count == 1) ? leftBlock : nil;
}

- (void) restoreBlocksStatus
{
    for (int i=0; i<blockArray.count; i++) {
        Block *b = [blockArray objectAtIndex:i];
        [b setIsChecked:NO];
        [b setIsCanMoved:NO];
        [b setTargetInfo:nil];
        if (b.zOrder > zOrderStep) {
            [b setZOrder:b.zOrder - zOrderStep];
            [b.numLabel setZOrder:b.numLabel.zOrder - zOrderStep];
            NSLog(@"b zorder is---111- %d", b.zOrder);
            if (b.zOrder > 100) { //setted when move from trap
                [b setZOrder:b.zOrder - 100];
                [b.numLabel setZOrder:b.numLabel.zOrder - 100];
                NSLog(@"b zorder is--222-- %d", b.zOrder);
            }
        }
    }
}

- (void) enableMainLayerTouch: (BOOL) enabled
{
    [self setTouchEnabled:enabled];
    [restartMenu setTouchEnabled:enabled];
    [backMenu setTouchEnabled:enabled];
}

- (BOOL) checkGameEnd
{
    BOOL isOver = YES;
    for (int i=0; i<blockArray.count; i++) {
        Block *b = [blockArray objectAtIndex:i];
        touchedBlock = b;
        for (int j=0; j<directionArray.count; j++) {
            int dir = [[directionArray objectAtIndex:j] intValue];
            movedDirection = dir;
            isCheckingGameOver = YES;
            if ([self checkMovableForBlock:b atDirection:dir isPulled:NO]) {
                isOver = NO;
                break;
            }
            [self restoreBlocksStatus];
        }
        if (!isOver) break;
    }
    isCheckingGameOver = NO;
    touchedBlock = nil;
    if (!isOver) {
        needCheckGameEnd = NO;
        [self resetStatusAfterMove];
    }
    return isOver;
}


- (void) showGameEndViewWithWin: (BOOL) win
{
    //[timer invalidate];
    [self unschedule:@selector(updateTime)];
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    GameEndLayer  *gameEndLayer = [GameEndLayer node];
    CGFloat yOffset = screenSize.height/2;
    gameEndLayer.position = ccp(gameEndLayer.position.x, gameEndLayer.position.y + 3*yOffset);
    [gameEndLayer initScreenWithWin:win inMainLayer:self];
    CCScene *scene = [[CCDirector sharedDirector] runningScene];
    [scene addChild:gameEndLayer z:1 tag:1];

    //animate to show
    //[NSThread sleepForTimeInterval:1.0f];
    //[self performSelector:@selector(checkCanRemoveBlocks) withObject:self afterDelay:0.5];
    [gameEndLayer runAction:[CCMoveTo actionWithDuration:0.5 position:ccp(gameEndLayer.position.x, gameEndLayer.position.y - 3*yOffset)]];
}

- (void)storeGameStatueWithLevel: (int) l
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSNumber *lp = [NSNumber numberWithInt:l];//change to test
    [defaults setObject:lp forKey:@"levelProgress"];
    
    NSNumber *getStarNum = [NSNumber numberWithInt:getStar];
    [defaults setObject:getStarNum forKey:[NSString stringWithFormat:@"star_%d", l]];
}



// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	//[super dealloc];
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}
@end //MainLayer

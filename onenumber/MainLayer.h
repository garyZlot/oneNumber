//
//  HelloWorldLayer.h
//  gathernumbers
//
//  Created by garyliumac on 14-3-20.
//  Copyright zlot 2014年. All rights reserved.
//


#import <GameKit/GameKit.h>
#import "Block.h"


// HelloWorldLayer
@interface MainLayer : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate>
{
    CGPoint gestureStartPoint;
    NSMutableArray *blockArray;
    NSMutableArray *barrierArray;
    NSMutableArray *itemArray; //道具 target trap gate
    int itemLayout[6][6]; // 1 target, 2 trap, 3 gate
    int endTargetPos[2];
    Block *touchedBlock;
    CCLabelTTF *movedNum;
    int movedDirection; //1 for x, -1 for -x, 2 for y, -2 for -y
    Block *targetBlock;
    CCLabelTTF *targetNum;
    int targetCol;
    int targetRow;
    BOOL startMove;
    NSMutableArray *movedBlockArray;
    NSArray *directionArray;
    NSArray *dataArray;
    int dataNo;
    int numberData[COL][ROW];
    int zOrderStep;
    BOOL needCheckGameEnd;
    int allNumberData[levelCount*COL][ROW];
    int allItemData[levelCount][4];
    int level;
    CCLabelTTF *levelText;
    CCLabelTTF *elapsedTimeText;
    CCLabelTTF *hintCountText;
    NSString *gameData;
    int currentLevelCount;
    BOOL movingOutTrap; // player is moving block out of trap
    int rank;
    CCMenu *restartMenu;
    CCMenu *backMenu;
    CCMenu *hintMenu;
    int levelProgress;
    int hintCount;
    int defaultHintCount; 
    int difficulty; //any value of 1,2,3,4,5,6
    //CFTimeInterval startTime;
    //NSTimer *timer;
    int elapsedTime;
    int levelBaseNo;
    int hintPos[4];
    int hintActionNo;
    BOOL haveMovedByHint;
    BOOL isCheckingGameOver;
    int getStarTimeData[18]; // 3 times for 6 difficulty
    int getStar;
    CCSprite *starSprite;
    CCTexture2D *starTex0;
    CCTexture2D *starTex1;
    CCTexture2D *starTex2;
    CCTexture2D *starTex3;
    
    NSMutableArray *hintDataArray;
    int currentHintPosArray[40][4];
    int currentHintStepCount;
    BOOL enableHint;
    
    CCTexture2D *hintOnTex;
    CCTexture2D *hintOffTex;
    CCSprite *hintSprite;
    CCSprite *hintSpriteSel;
}


// returns a CCScene that contains the HelloWorldLayer as the only child
+ (CCScene *)sceneWithGameRank: (int) r withLevel: (int) l;
- (void)backNavScreen;
- (void)enterNextLevel;
- (void)retryGame;
- (void)updateHintsCountWithBuys: (int) hintCount;

@end

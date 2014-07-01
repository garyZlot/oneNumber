//
//  IntroLayer.h
//  gathernumbers
//
//  Created by garyliumac on 14-3-20.
//  Copyright zlot 2014年. All rights reserved.
//


// HelloWorldLayer
@interface IntroLayer : CCLayer
{
    CCTexture2D *packagebtnbgTex;
    CCTexture2D *selPackagebtnbgTex;
    CCTexture2D *packagebtnlockbgTex;
    CCTexture2D *selPackagebtnlockbgTex;
    BOOL levelPackLocked;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+ (CCScene *) scene;

- (void)unlockLevelPack;

@end

//
//  NavigateLayer.h
//  gathernumbers
//
//  Created by garyliumac on 14-4-12.
//  Copyright 2014年 zlot. All rights reserved.
//

@interface NavigateLayer : CCLayer {
    int rank; //0,1,2,3
    CCTexture2D *levelBgTex;
    CCTexture2D *levelLockTex;
}

+ (CCScene *) sceneWithGameRank: (int) rank;

@end

//
//  GameEndLayer.h
//  gathernumbers
//
//  Created by garyliumac on 14-4-12.
//  Copyright 2014年 zlot. All rights reserved.
//

@interface GameEndLayer : CCLayerColor {
    CCTexture2D *successBgTex;
    CCTexture2D *failedBgTex;
    CCTexture2D *levelSelectTex;
    CCTexture2D *nextTex;
    CCTexture2D *replayTex;
}

- (void) initScreenWithWin:(BOOL) win inMainLayer: (CCLayer *) mainLayer;
@end

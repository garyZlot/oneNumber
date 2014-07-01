//
//  Block.h
//  gathernumbers
//
//  Created by garyliumac on 14-3-21.
//  Copyright 2014年 zlot. All rights reserved.
//


@interface Block : CCSprite {
    int col;
    int row;
    int num;
    BOOL isRemoved;
    BOOL isChecked;
    BOOL isCanMoved;
    BOOL isBarrier;
    CCLabelTTF *numLabel;
    NSArray *targetInfo;
}

@property int col;
@property int row;
@property int num;
@property BOOL isRemoved;
@property BOOL isChecked;
@property BOOL isCanMoved;
@property BOOL isBarrier;
@property (nonatomic, retain) CCLabelTTF *numLabel;
@property (nonatomic, retain) NSArray *targetInfo;


@end

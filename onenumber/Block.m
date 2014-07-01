//
//  Block.m
//  gathernumbers
//
//  Created by garyliumac on 14-3-21.
//  Copyright 2014年 zlot. All rights reserved.
//

#import "Block.h"


@implementation Block

@synthesize col;
@synthesize row;
@synthesize num;
@synthesize isRemoved;
@synthesize isChecked;
@synthesize isCanMoved;
@synthesize numLabel;
@synthesize targetInfo;
@synthesize isBarrier;


-(id) init
{
    if (self = [super init]) {
        [self setIsRemoved:NO];
        [self setIsChecked:NO];
        [self setIsCanMoved:NO];
        [self setIsBarrier:NO];
    }
    
    return self;
}

@end

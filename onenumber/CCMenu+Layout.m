//
//  CCMenu+Layout.m
//  onenumber
//
//  Created by garyliumac on 14-5-24.
//  Copyright (c) 2014年 zlot. All rights reserved.
//

#import "CCMenu+Layout.h"

@implementation CCMenu (Layout)

- (void)alignItemsInGridWithPadding:(CGPoint)padding columns:(NSInteger)columns
{
    CCMenuItem *item = [_children objectAtIndex:0];
    CGFloat contentWidth = item.contentSize.width * item.scaleX;
    CGFloat contentHeight = item.contentSize.height * item.scaleY;
    
    // set content size
    NSInteger count = _children.count;
    NSInteger numRows = (count + columns - 1) / columns;
    NSInteger numCols = MIN(count, columns);
    CGFloat height = contentHeight * numRows + padding.y * (numRows - 1);
    CGFloat width = contentWidth * numCols + padding.x * (numCols - 1);
    [self setContentSize:CGSizeMake(width, height)];
    
    // layout menu items
    NSInteger row = 0;
    NSInteger col = 0;
    CCARRAY_FOREACH(_children, item) {
        CGFloat x = (contentWidth + padding.x) * col + contentWidth * 0.5f;
        CGFloat y = height - (contentHeight + padding.y) * row - contentHeight * 0.5f;
        [item setPosition:ccp(x, y)];
        
        if(++col == columns) {
            col = 0;
            row++;
        }
    }
}


@end

//
//  DebugSprite.m
//  ContourTracing
//
//  Created by Mark Kim on 1/3/14.
//  Copyright (c) 2014 Mark Kim. All rights reserved.
//

#import "DebugSprite.h"
#import "cocos2d.h"

#define DEBUG_DRAW 1
#define DEBUG_LINE_WIDTH 1

@implementation DebugSprite

- (void)draw
{
    [super draw];
    
    if (DEBUG_DRAW) {
        
        ccDrawColor4F(1.0, 0.0, 0.0, 1.0);
        glLineWidth(DEBUG_LINE_WIDTH);
        if (_surfaces && [_surfaces count] > 0) {
            
            for (NSArray *edges in _surfaces) {
                int stride = 1;
                for (int i=0; i<[edges count]; ++i) {
                    if (i % stride != 0) {
                        continue;
                    }
                    CGPoint point1;
                    CGPoint point2;
                    if (i < [edges count]) {
                        point1 = CGPointFromString([edges objectAtIndex:i]);
                        int strideLeft = [edges count] - i;
                        
                        if (strideLeft > stride) {
                            point2 = CGPointFromString([edges objectAtIndex:i+stride]);
                        } else {
                            point2 = CGPointFromString([edges objectAtIndex:0]);
                        }
                        ccDrawLine(ccpMult(point1, 1.0 / CC_CONTENT_SCALE_FACTOR()),
                                   ccpMult(point2, 1.0 / CC_CONTENT_SCALE_FACTOR()));
                    }
                }
            }
        }
    }
}

- (id)initWithSurfaces:(NSArray *)surfaces
{
    if (self = [super init]) {
        _surfaces = surfaces;
    }
    return self;
}

@end

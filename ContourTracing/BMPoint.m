//
//  Point.m
//  ContourTracing
//
//  Created by Mark Kim on 1/3/14.
//  Copyright (c) 2014 Mark Kim. All rights reserved.
//

#import "BMPoint.h"

@interface BMPoint ()
{
    BMDirectionType _neighborDirection;
}

@end

@implementation BMPoint

- (CGPoint)nextNeighbor
{
    BMDirectionType nextNeighborDirection = (_neighborDirection + 1) % 8;
    _relativeDirection = relativeDirection(_neighborDirection, nextNeighborDirection);
    
    _neighborDirection = nextNeighborDirection;
    CGPoint unitVector = unitVectorForDirection(nextNeighborDirection);
    CGPoint vectorToAdd = ccpMult(unitVector, NEIGHBOR_STEP);
    
    return ccpAdd(_point, vectorToAdd);
}

- (id)initWithPixelPoint:(CGPoint)pixelPoint
           fromDirection:(BMDirectionType)directionType
{
    if (self = [super init]) {
        _point = pixelPoint;
        _neighborDirection = directionType;
    }
    return self;
}

@end
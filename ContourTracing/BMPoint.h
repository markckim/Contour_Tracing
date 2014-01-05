//
//  BMPoint.h
//  ContourTracing
//
//  Created by Mark Kim on 1/3/14.
//  Copyright (c) 2014 Mark Kim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "contour_functions.h"

@interface BMPoint : NSObject

@property (nonatomic, readonly) CGPoint point;
@property (nonatomic, readonly) BMDirectionType relativeDirection;

- (CGPoint)nextNeighbor;
- (id)initWithPixelPoint:(CGPoint)pixelPoint
           fromDirection:(BMDirectionType)directionType;

@end

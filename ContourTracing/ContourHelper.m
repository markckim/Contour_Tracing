//
//  ContourHelper.m
//  ContourTracing
//
//  Created by Mark Kim on 1/4/14.
//  Copyright (c) 2014 Mark Kim. All rights reserved.
//

#import "ContourHelper.h"
#import "BMPoint.h"
#import "Tile.h"
#import "cocos2d.h"
#import "functions.h"

@implementation ContourHelper

+ (NSArray *)getLinesForTile:(Tile *)tile
{
    NSAssert(tile && tile.view && tile.width > 0.0 && tile.height > 0.0, @"tile not properly setup");
    CGRect viewRectInPixels = CGRectMake(0.0, 0.0, CC_CONTENT_SCALE_FACTOR() * tile.width, CC_CONTENT_SCALE_FACTOR() * tile.height);
    
    NSMutableArray *lines = [[NSMutableArray alloc] init];
    
    for (int i=1; i<=viewRectInPixels.size.height; i=MIN(i + PIXEL_STEP_Y, viewRectInPixels.size.height) ) {
        NSMutableArray *pixelsOnLine = [NSMutableArray array];
        [lines addObject:pixelsOnLine];
        
        for (int j=1; j<=viewRectInPixels.size.width; j=MIN(j + PIXEL_STEP_X, viewRectInPixels.size.width) ) {
            CGPoint pixelPoint = ccp(j-1, i-1);
            addPointToArray(pixelPoint, pixelsOnLine, YES);
            if (j == viewRectInPixels.size.width) break;
        }
        if (i == viewRectInPixels.size.height) break;
    }
    return lines;
}

+ (BMPoint *)solidPointBetweenPixel1:(CGPoint)pixelPoint1
                              pixel2:(CGPoint)pixelPoint2
                           alphaData:(NSMutableArray *)alphaData
                            viewRect:(CGRect)viewRect
{
    // assumptions:
    // * one of the pixel points is clear and the other is solid
    // * the pixel points are parallel along the x-axis
    // * pixelPoint1 has a lower x-coordinate value than pixelPoint2
    int index = indexForPoint(pixelPoint2, viewRect);
    int isPixel2Clear = [[alphaData objectAtIndex:index] intValue];
    CGPoint pixelPoint = pixelPoint1;
    CGPoint stepPixelVector = ccp(1.0, 0.0);
    CGPoint nextPixelPoint;
    while (pixelPoint.x < pixelPoint2.x) {
        nextPixelPoint = ccpAdd(pixelPoint, stepPixelVector);
        // check if boundary reached
        int index = indexForPoint(nextPixelPoint, viewRect);
        int isTestPixelClear = [[alphaData objectAtIndex:index] intValue];
        if (isTestPixelClear == isPixel2Clear) {
            if (!isTestPixelClear) {
                return [[BMPoint alloc] initWithPixelPoint:nextPixelPoint fromDirection:kWest];
            } else {
                return [[BMPoint alloc] initWithPixelPoint:pixelPoint fromDirection:kEast];
            }
        }
        pixelPoint = nextPixelPoint;
    }
    return nil;
}

+ (void)_setSurfacesForTile:(Tile *)tile point:(CGPoint)point surfaceData:(NSMutableArray *)surfaceData
{
    CGRect viewRectInPixels = CGRectMake(0.0, 0.0, CC_CONTENT_SCALE_FACTOR() * tile.width, CC_CONTENT_SCALE_FACTOR() * tile.height);
    int threshold = MAX(NEIGHBOR_STEP - 1, 0);
    for (int i=-threshold; i<=threshold; ++i) {
        for (int j=-threshold; j<=threshold; ++j) {
            CGPoint deltaPoint = ccp(j, i);
            CGPoint testPoint = ccpAdd(point, deltaPoint);
            int index = indexForPoint(testPoint, viewRectInPixels);
            if (index >= 0 && index < [surfaceData count]) {
                [surfaceData replaceObjectAtIndex:index withObject:@1];
            }
        }
    }
}

+ (NSArray *)createSurfaceForTile:(Tile *)tile edgePoint:(BMPoint *)edgePoint alphaData:(NSMutableArray *)alphaData surfaceData:(NSMutableArray *)surfaceData
{
    int neighbor_debug_count = 0;
    CGRect viewRectInPixels = CGRectMake(0.0, 0.0, CC_CONTENT_SCALE_FACTOR() * tile.width, CC_CONTENT_SCALE_FACTOR() * tile.height);
    
    NSMutableArray *pointArray = [NSMutableArray array];
    BMPoint *point = edgePoint;
    addPointToArray(edgePoint.point, pointArray, YES);
    
    BOOL isSurfaceClosed = NO;
    while (!isSurfaceClosed) {
        ++neighbor_debug_count;
        CGPoint testPixelPoint = [point nextNeighbor];
        
        if (neighbor_debug_count > 7) {
            /*
             * this can happen if:
             * we begin on a pixel with no other pixels surrounding it
             * not sure if there are any other strange cases where this could happen
             */
            return pointArray;
        }
        
        if (isPixelOutsideViewRect(testPixelPoint, viewRectInPixels)) {
            continue;
        }
        
        int index = indexForPoint(testPixelPoint, viewRectInPixels);
        if ([[alphaData objectAtIndex:index] intValue]) {
            continue;
        } else {
            [ContourHelper _setSurfacesForTile:tile point:point.point surfaceData:surfaceData];
            addPointToArray(testPixelPoint, pointArray, YES);
            
            neighbor_debug_count = 0;
            point = [[BMPoint alloc] initWithPixelPoint:testPixelPoint fromDirection:point.relativeDirection];
            
            // test if end point reached
            int x1 = (int)roundf(point.point.x);
            int y1 = (int)roundf(point.point.y);
            int x2 = (int)roundf(edgePoint.point.x);
            int y2 = (int)roundf(edgePoint.point.y);
            int threshold = MAX(NEIGHBOR_STEP - 1, 0);
            if (ABS(x2 - x1) <= threshold && ABS(y2 - y1) <= threshold) {
                isSurfaceClosed = YES;
            }
            
            if (CGPointEqualToPoint(point.point, edgePoint.point)) {
                isSurfaceClosed = YES;
            }
        }
    }
    return pointArray;
}

@end

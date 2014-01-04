//
//  ContourHelper.h
//  ContourTracing
//
//  Created by Mark Kim on 1/4/14.
//  Copyright (c) 2014 Mark Kim. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BMPoint;
@class Tile;

@interface ContourHelper : NSObject

+ (NSArray *)getLinesForTile:(Tile *)tile;
+ (BMPoint *)solidPointBetweenPixel1:(CGPoint)pixelPoint1
                              pixel2:(CGPoint)pixelPoint2
                           alphaData:(NSMutableArray *)alphaData
                            viewRect:(CGRect)viewRect;
+ (NSArray *)createSurfaceForTile:(Tile *)tile
                        edgePoint:(BMPoint *)edgePoint
                        alphaData:(NSMutableArray *)alphaData
                      surfaceData:(NSMutableArray *)surfaceData;

@end

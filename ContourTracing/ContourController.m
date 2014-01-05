//
//  TileController.m
//  ContourTracing
//
//  Created by Mark Kim on 1/3/14.
//  Copyright (c) 2014 Mark Kim. All rights reserved.
//

#import "ContourController.h"
#import "BMPoint.h"
#import "ContourHelper.h"
#import "DebugSprite.h"
#import "Tile.h"
#import "debug_constants.h"
#import "contour_functions.h"

@interface ContourController ()

@property (nonatomic, strong) NSMutableArray *alphaData; // @1 = clear
@property (nonatomic, strong) NSMutableArray *surfaceData; // @1 = surface
@property (nonatomic, strong) NSMutableArray *surfaces; // array of array of @"{x,y}" values
@property (nonatomic, strong) Tile *currentTile;
@property (nonatomic, strong) NSArray *tileSpriteNames;
@property (nonatomic, strong) CCLayer *tileView;

@end

@implementation ContourController

- (void)_saveDataForTile:(Tile *)tile
{
    if ([FILE_TYPE_TO_RETURN isEqualToString:@"json"]) {
        NSData *surfaceData = [NSJSONSerialization dataWithJSONObject:_surfaces options:0 error:nil];
        [surfaceData writeToFile:[NSString stringWithFormat:@"%@%@.json", DESTINATION_FOLDER, tile.name] atomically:YES];
    } else {
        [NSKeyedArchiver archiveRootObject:_surfaces
                                    toFile:[NSString stringWithFormat:@"%@%@.plist", DESTINATION_FOLDER, tile.name]];
    }
}

- (void)_optimizeSurfaces
{
    // method removes excess adjacent points that are in the same direction
    // (e.g., a square shape should have at most 4 points that define it)
    // currently works for cardinal and intercardinal directions only
    NSAssert(_surfaces, @"_surfaces not setup");
    NSMutableArray *optimizedSurfaces = [[NSMutableArray alloc] init];
    
    for (NSArray *surface in _surfaces) {
        
        NSMutableArray *optimizedSurface = [[NSMutableArray alloc] init];
        
        CGPoint currentPoint = CGPointFromString(getPointFromArray(surface, 0));
        CGPoint nextPoint = CGPointFromString(getPointFromArray(surface, 1));
        BMDirectionType currentDirection = directionForPoints(currentPoint, nextPoint);
        
        for (int i=1; i<[surface count]; ++i) {
            nextPoint = CGPointFromString(getPointFromArray(surface, i));
            BMDirectionType nextDirection = directionForPoints(currentPoint, nextPoint);
            
            // if its the same direction, move onto the next point
            if (nextDirection == currentDirection) {
                currentPoint = nextPoint;
            } else {
                // direction is different => optimized point is at currentPoint
                addPointToArray(currentPoint, optimizedSurface, YES);
                currentPoint = nextPoint;
                currentDirection = nextDirection;
            }
        }
        
        // take care of the rest and close the surface
        // note: there will between 0 and 2 additional optimized surfaces here
        for (int j=1; j<2; ++j) {
            nextPoint = CGPointFromString(getPointFromArray(surface, j));
            BMDirectionType nextDirection = directionForPoints(currentPoint, nextPoint);
            
            if (nextDirection == currentDirection) {
                currentPoint = nextPoint;
            } else {
                addPointToArray(currentPoint, optimizedSurface, YES);
                currentPoint = nextPoint;
                currentDirection = nextDirection;
            }
        }
        [optimizedSurfaces addObject:optimizedSurface];
    }
    _surfaces = optimizedSurfaces;
}

- (void)_setupSurfaceForTile:(Tile *)tile
{
    NSAssert([_surfaceData count] == 0, @"_surfaceData already contains data");
    CGRect viewRectInPixels = CGRectMake(0.0, 0.0, CC_CONTENT_SCALE_FACTOR() * tile.width, CC_CONTENT_SCALE_FACTOR() * tile.height);
    for (int i=0; i<(viewRectInPixels.size.width * viewRectInPixels.size.height); ++i) {
        [_surfaceData addObject:@0];
    }
    
    NSArray *lines = [ContourHelper getLinesForTile:tile];
    for (NSArray *line in lines) {
        NSNumber *isPixelClear = nil;
        for (int i=0; i<[line count]; ++i) {
            CGPoint testPixelPoint = CGPointFromString(getPointFromArray(line, i));
            int index = indexForPoint(testPixelPoint, viewRectInPixels);
            BMPoint *edgePoint = nil;
            
            // left edge case
            if (!isPixelClear) {
                isPixelClear = [_alphaData objectAtIndex:index];
                if (![isPixelClear intValue]) {
                    edgePoint = [[BMPoint alloc] initWithPixelPoint:testPixelPoint fromDirection:kWest];
                }
            // normal case
            } else if ([isPixelClear intValue] != [[_alphaData objectAtIndex:index] intValue]) {
                isPixelClear = [_alphaData objectAtIndex:index];
                CGPoint prevPixelPoint = CGPointFromString(getPointFromArray(line, i-1));
                edgePoint = [ContourHelper solidPointBetweenPixel1:prevPixelPoint pixel2:testPixelPoint alphaData:_alphaData viewRect:viewRectInPixels];
            }
            
            if (edgePoint) {
                // note: assumes edgePoint is always a solid pixel
                int index = indexForPoint(edgePoint.point, viewRectInPixels);
                if (![[_surfaceData objectAtIndex:index] intValue]) {
                    NSArray *surface = [ContourHelper surfaceForTile:tile edgePoint:edgePoint alphaData:_alphaData surfaceData:_surfaceData];
                    [_surfaces addObject:surface];
                }
            }
        }
    }
}

- (void)_setupAlphaForTile:(Tile *)tile
{
    NSAssert([_alphaData count] == 0, @"_alphaData already contains data");
    CGRect viewRectInPixels = CGRectMake(0.0, 0.0, CC_CONTENT_SCALE_FACTOR() * tile.width, CC_CONTENT_SCALE_FACTOR() * tile.height);
    for (int i=0; i<(viewRectInPixels.size.width * viewRectInPixels.size.height); ++i) {
        [_alphaData addObject:@0];
    }
    
    // move sprite so that its left-corner is on (0, 0)
    tile.view.position = ccp(0.5 * tile.width, 0.5 * tile.height);
    
    // will be used to keep track of the alpha data (e.g., 1 = transparent)
    unsigned char data[4];
    
    CCRenderTexture *renderTexture = [[CCRenderTexture alloc] initWithWidth:viewRectInPixels.size.width
                                                                     height:viewRectInPixels.size.height
                                                                pixelFormat:kCCTexture2DPixelFormat_RGBA8888];
    [renderTexture beginWithClear:1.0 g:1.0 b:1.0 a:0.0];
    [tile.view visit];
    for (int i = 0; i < viewRectInPixels.size.height; ++i) {
        for (int j = 0; j < viewRectInPixels.size.width; ++j) {
            CGPoint pixelPoint = ccp(j, i);
            glReadPixels(pixelPoint.x, pixelPoint.y, 1, 1, GL_RGBA, GL_UNSIGNED_BYTE, data);
            if (isPixelClear(data, ALPHA_THRESHOLD)) {
                int index = indexForPoint(pixelPoint, viewRectInPixels);
                [_alphaData replaceObjectAtIndex:index withObject:@1];
            }
        }
    }
    [renderTexture end];
}

- (void)_resetData
{
    [_alphaData removeAllObjects];
    [_surfaceData removeAllObjects];
    [_surfaces removeAllObjects];
}

- (void)_setupTile:(Tile *)tile
{
    NSAssert(tile && tile.view && tile.width > 0.0 && tile.height > 0.0, @"tile not properly setup");
    [self _resetData];
    [self _setupAlphaForTile:tile];
    [self _setupSurfaceForTile:tile];
    if (SHOULD_OPTIMIZE) {
        [self _optimizeSurfaces];
    }
    [self _saveDataForTile:tile];
}

- (void)_setupData
{
    NSAssert(_tileSpriteNames && [_tileSpriteNames count] > 0, @"_tiles not properly setup");
    for (NSString *tileSpriteName in _tileSpriteNames) {
        Tile *tile = [[Tile alloc] init];
        tile.view = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@.%@", tileSpriteName, IMAGE_FORMAT]];
        tile.name = tileSpriteName;
        tile.width = tile.view.contentSize.width;
        tile.height = tile.view.contentSize.height;
        _currentTile = tile;
        [self _setupTile:tile];
    }
}

- (void)_setupSprites
{
    CGSize winSize = [CCDirector sharedDirector].winSize;
    CGFloat midXOffset = 10.0;
 
    // debug sprite tracing the contours
    DebugSprite *debugSprite = [[DebugSprite alloc] initWithSurfaces:_surfaces];
    debugSprite.position = ccp(0.5 * winSize.width + midXOffset, 0.5 * winSize.height);
    [_tileView addChild:debugSprite];
    
    _currentTile.view.position = ccp(0.5 * winSize.width - 0.5 * _currentTile.view.contentSize.width - midXOffset,
                                     0.5 * winSize.height + 0.5 * _currentTile.view.contentSize.height);
    [_tileView addChild:_currentTile.view];
}

- (id)init
{
    if (self = [super init]) {
        _tileSpriteNames = SPRITE_NAMES;
        _tileView = [[CCLayer alloc] init];
        _alphaData = [[NSMutableArray alloc] init];
        _surfaceData = [[NSMutableArray alloc] init];
        _surfaces = [[NSMutableArray alloc] init];
        
        [self _setupData];
        [self _setupSprites];
        
        [self addChild:_tileView];
    }
    return self;
}

@end

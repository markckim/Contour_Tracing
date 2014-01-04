//
//  functions.h
//  ContourTracing
//
//  Created by Mark Kim on 1/3/14.
//  Copyright (c) 2014 Mark Kim. All rights reserved.
//

#ifndef ContourTracing_functions_h
#define ContourTracing_functions_h

#define NEIGHBOR_STEP 1
#define PIXEL_STEP_X 1
#define PIXEL_STEP_Y 1

typedef enum {
    kWest,
    kNorthWest,
    kNorth,
    kNorthEast,
    kEast,
    kSouthEast,
    kSouth,
    kSouthWest,
} BMDirectionType;

CG_INLINE NSString*
pathForResourceNameAndType(NSString *name, NSString *type)
{
    // check documents path first (which will hold any downloaded resources)
    // if resource is not in documents path, check the app bundle
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *resourcePath = [docPath stringByAppendingString:[NSString stringWithFormat:@"/%@.%@", name, type]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:resourcePath]) {
        resourcePath = [[NSBundle mainBundle] pathForResource:name ofType:type];
    }
    return resourcePath;
}

CG_INLINE int
isPixelClear(unsigned char data[4])
{
    int isPixelClear = 0;
    if (data[3] == 0) {
        isPixelClear = 1;
    }
    return isPixelClear;
}

CG_INLINE int
indexForPoint(CGPoint point, CGRect viewRect)
{
    CGPoint roundedPixelPoint = ccp(roundf(point.x), roundf(point.y));
    int x = (int)roundedPixelPoint.x;
    int y = (int)roundedPixelPoint.y;
    int offsetX = (int)viewRect.origin.x;
    int offsetY = (int)viewRect.origin.y;
    int widthInPixels = (int)viewRect.size.width;
    return ((x - offsetX) + (y - offsetY) * widthInPixels);
}

CG_INLINE CGPoint
unitVectorForDirection(BMDirectionType directionType)
{
    CGPoint unitVector;
    
    switch (directionType) {
        case kWest:
            unitVector = ccp(-1.0, 0.0);
            break;
        case kNorthWest:
            unitVector = ccp(-1.0, 1.0);
            break;
        case kNorth:
            unitVector = ccp(0.0, 1.0);
            break;
        case kNorthEast:
            unitVector = ccp(1.0, 1.0);
            break;
        case kEast:
            unitVector = ccp(1.0, 0.0);
            break;
        case kSouthEast:
            unitVector = ccp(1.0, -1.0);
            break;
        case kSouth:
            unitVector = ccp(0.0, -1.0);
            break;
        case kSouthWest:
            unitVector = ccp(-1.0, -1.0);
            break;
        default:
            NSLog(@"ERROR: unitVector not found");
            unitVector = ccp(-1.0, 0.0);
    }
    return unitVector;
}

CG_INLINE BMDirectionType
directionForPoints(CGPoint initialPoint, CGPoint finalPoint)
{
    // assumptions:
    // * initialPoint and finalPoint must be adjacent or diagonal to each other
    // * initialPoint and finalPoint cannot be the same point
    if (initialPoint.x == finalPoint.x && initialPoint.y == finalPoint.y) {
        NSLog(@"ERROR: initialPoint and finalPoint are the same");
    }
    
    BMDirectionType directionTypeToReturn;
    int dX = finalPoint.x - initialPoint.x;
    int dY = finalPoint.y - initialPoint.y;
    
    if (dX == 0) {
        if (dY > 0) {
            directionTypeToReturn = kNorth;
        } else {
            directionTypeToReturn = kSouth;
        }
    } else if (dX > 0) {
        if (dY > 0) {
            directionTypeToReturn = kNorthEast;
        } else if (dY == 0) {
            directionTypeToReturn = kEast;
        } else {
            directionTypeToReturn = kSouthEast;
        }
    } else {
        if (dY > 0) {
            directionTypeToReturn = kNorthWest;
        } else if (dY == 0) {
            directionTypeToReturn = kWest;
        } else {
            directionTypeToReturn = kSouthWest;
        }
    }
    return directionTypeToReturn;
}

CG_INLINE BMDirectionType
relativeDirection(BMDirectionType direction1, BMDirectionType direction2)
{
    // assumptions:
    // * direction1 and direction2 must be adjacent
    CGPoint unitVector1 = unitVectorForDirection(direction1);
    CGPoint unitVector2 = unitVectorForDirection(direction2);
    int x1 = (int)unitVector1.x;
    int y1 = (int)unitVector1.y;
    int x2 = (int)unitVector2.x;
    int y2 = (int)unitVector2.y;
    
    BMDirectionType directionTypeToReturn;
    if ((x2 - x1) == 0) {
        if ((y2 - y1) > 0) {
            directionTypeToReturn = kSouth;
        } else {
            directionTypeToReturn = kNorth;
        }
    } else {
        if ((x2 - x1) > 0) {
            directionTypeToReturn = kWest;
        } else {
            directionTypeToReturn = kEast;
        }
    }
    return directionTypeToReturn;
}

CG_INLINE BOOL
isPixelOutsideViewRect(CGPoint pixelPoint, CGRect viewRectInPixels)
{
    BOOL isPointOutsideView = NO;
    int pixelPointX = (int)roundf(pixelPoint.x);
    int pixelPointY = (int)roundf(pixelPoint.y);
    
    int leftX = (int)roundf(viewRectInPixels.origin.x);
    int rightX = (int)roundf(viewRectInPixels.origin.x + viewRectInPixels.size.width);
    int botY = (int)roundf(viewRectInPixels.origin.y);
    int topY = (int)roundf(viewRectInPixels.origin.y + viewRectInPixels.size.height);
    
    if (pixelPointX < leftX || pixelPointX >= rightX ||
        pixelPointY < botY || pixelPointY >= topY) {
        isPointOutsideView = YES;
    }
    return isPointOutsideView;
}

CG_INLINE NSString*
addPointToArray(CGPoint point, NSMutableArray *arr, BOOL isInteger)
{
    id pointValue = nil;
    if (isInteger) {
        pointValue = [NSString stringWithFormat:@"{%d,%d}", (NSInteger)point.x, (NSInteger)point.y];
    } else {
        pointValue = [NSString stringWithFormat:@"{%f,%f}", point.x, point.y];
    }
    [arr addObject:pointValue];
    return pointValue;
}

CG_INLINE NSString*
getPointFromArray(NSArray *arr, int index)
{
    id pointValue = nil;
    if ([arr count] > index) {
        pointValue = [arr objectAtIndex:index];
    } else {
        NSLog(@"unable to get point; array is smaller than index: %d", index);
    }
    return pointValue;
}

#endif

//
//  Tile.h
//  ContourTracing
//
//  Created by Mark Kim on 1/3/14.
//  Copyright (c) 2014 Mark Kim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCSprite.h"

@interface Tile : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, strong) CCSprite *view;

@end

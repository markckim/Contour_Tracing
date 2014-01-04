//
//  DebugSprite.h
//  ContourTracing
//
//  Created by Mark Kim on 1/3/14.
//  Copyright (c) 2014 Mark Kim. All rights reserved.
//

#import "CCSprite.h"

@interface DebugSprite : CCSprite

@property (nonatomic, strong) NSArray *surfaces;

- (id)initWithSurfaces:(NSArray *)surfaces;

@end

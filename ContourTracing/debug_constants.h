//
//  debug_constants.h
//  ContourTracing
//
//  Created by Mark Kim on 1/4/14.
//  Copyright (c) 2014 Mark Kim. All rights reserved.
//

#ifndef ContourTracing_debug_constants_h
#define ContourTracing_debug_constants_h

// select highest alpha value considered "clear" (0 thru 255)
#define ALPHA_THRESHOLD 100

// select image format
#define IMAGE_FORMAT @"png"

// select @"json" or @"plist"
#define FILE_TYPE_TO_RETURN @"json"

// select destination for your data
#define DESTINATION_FOLDER @"/Users/markkim/Desktop/test_tile_data/"

// select images (note: add images to project before compiling)
#define SPRITE_NAMES @[@"cloud"]

#endif

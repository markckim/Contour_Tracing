Contour_Tracing
===============

An implementation of the Moore Neighborhood algorithm used to trace the contours of a given image and output a JSON (or plist) file of the resulting pixel coordinates. In order to use, follow these steps:

    debug_constants.h
    
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

![Cloud Demo](http://i.imgur.com/vsH4XQQ.png?raw=true)

![Alien Demo](http://i.imgur.com/KU0g7d5.png?raw=true)

Sample images taken from http://kenney.nl/

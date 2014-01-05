Contour_Tracing
===============

An implementation of the Moore Neighborhood algorithm used to trace the contours of a given image and output a JSON (or plist) file of the resulting pixel coordinates. If an image is made up of more than one body, the coordinate data for each body will be stored in a separate array. Coordinate data is of the form `@"{x,y}"` and can be parsed from an iOS application using `CGPointFromString`. 

Example JSON data output for an image made up of two rectangular bodies: 
    
    [["{0,0}","{0,1}","{1,1}","{1,0}"],["{3,2}","{5,2}","{5,3}","{3,3}"]].

In order to use the program, follow these steps:

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
    #define SPRITE_NAMES @[@"cloud", @"alien"]

![Cloud Demo](http://i.imgur.com/vsH4XQQ.png?raw=true)

![Alien Demo](http://i.imgur.com/KU0g7d5.png?raw=true)

Sample images taken from http://kenney.nl/

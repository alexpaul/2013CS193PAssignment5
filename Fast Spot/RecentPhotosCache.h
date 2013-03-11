//
//  RecentPhotosCache.h
//  Fast Spot
//
//  Created by Alex Paul on 3/11/13.
//  Copyright (c) 2013 Alex Paul. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecentPhotosCache : NSObject

//  The file Path for storing the image using the photo id
@property (nonatomic, strong) NSURL *filePath;


@end

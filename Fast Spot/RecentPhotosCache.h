//
//  RecentPhotosCache.h
//  Fast Spot
//
//  Created by Alex Paul on 3/11/13.
//  Copyright (c) 2013 Alex Paul. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecentPhotosCache : NSObject

@property (nonatomic, strong) NSString *photoId;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, readonly) NSData *imageData;

- (NSUInteger)currentSizeOfCache;

@end

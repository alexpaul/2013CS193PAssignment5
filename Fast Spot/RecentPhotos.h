//
//  RecentPhotos.h
//  SPoT
//
//  Created by Alex Paul on 3/5/13.
//  Copyright (c) 2013 Alex Paul. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecentPhotos : NSObject

@property (nonatomic, strong) NSString *photoId;
@property (nonatomic, strong) NSDate *recentPhotoDate;

+ (NSArray *)recentPhotos; // most recent photos viewed

@end

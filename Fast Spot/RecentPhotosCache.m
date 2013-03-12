//
//  RecentPhotosCache.m
//  Fast Spot
//
//  Created by Alex Paul on 3/11/13.
//  Copyright (c) 2013 Alex Paul. All rights reserved.
//

#import "RecentPhotosCache.h"

@interface RecentPhotosCache ()
@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) NSURL *cachesPath;
@property (nonatomic, readwrite) NSData *imageData;
@end

@implementation RecentPhotosCache

- (NSUInteger)currentSizeOfCache
{
#warning incomplete implementation 
    int cacheSize = 0; 
    // Enumerate the contents of the caches directory and return the size of the images on disk
    
    return cacheSize; 
}


- (void)setPhotoId:(NSString *)photoId
{    
    _photoId = photoId; 
    
    //  Create the file Path for storing the image using the photo id
    NSURL *filePath = [self.cachesPath URLByAppendingPathComponent:self.photoId];
    
    //  Check if the file Path already exist
    BOOL fileExist = [self.fileManager fileExistsAtPath:[filePath path]];
    if (fileExist == NO) {
        self.imageData = [[NSData alloc] initWithContentsOfURL:self.imageURL];
        [self.imageData writeToURL:filePath atomically:YES];
    }else{
        //  Use the image if it already exist in the caches directory
        self.imageData = [self.fileManager contentsAtPath:[filePath path]];
    }
}

- (id)init
{
    if (self = [super init]) {
        //  Create an NSFileManager and then find the Caches Directory
        _fileManager = [[NSFileManager alloc] init];
        NSArray *urls = [self.fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
        _cachesPath = [urls objectAtIndex:0];
    }
    return self;
}

@end

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
@property (nonatomic, strong) NSMutableArray *cacheImages;
@end

@implementation RecentPhotosCache

#define CACHE_MAX 3000000 // 3MB (about 6 photos on the iPhone)
//#define CACHE_MAX  1000000// 1MB (about 3 photos on the iPhone)


- (NSUInteger)currentSizeOfCache
{
    int cacheSize = 0; 
    // Enumerate the contents of the caches directory and return the size of the images on disk
    
    NSArray *keys = [NSArray arrayWithObjects:NSURLIsDirectoryKey, NSURLIsPackageKey, NSURLLocalizedNameKey, nil];
    
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager]
                                         enumeratorAtURL:self.cachesPath
                                         includingPropertiesForKeys:keys
                                         options:(NSDirectoryEnumerationSkipsPackageDescendants | NSDirectoryEnumerationSkipsHiddenFiles | NSDirectoryEnumerationSkipsSubdirectoryDescendants)
                                         errorHandler:^(NSURL* url, NSError *error){
                                             // Handle the error
                                             // Return YES if the enumeration should contiune after the error
                                             return NO;
                                         }];
    for (NSURL *url in enumerator) {
        NSNumber *isDirectory;
        [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];
        if ([isDirectory boolValue] == YES) { //  Skips Directories
            [enumerator skipDescendants]; 
        }
        else{
            NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[url path] error:nil];
            NSNumber *fileSize = [attributes objectForKey:NSFileSize];
            cacheSize += [fileSize intValue];
            [self.cacheImages addObject:url]; // Add image file to cache images array
        }
    }
    
    [self leastRecentlyViewedPhoto]; 
    
    return cacheSize; 
}

- (NSURL *)leastRecentlyViewedPhoto
{
    NSDate *olderDate = [NSDate date];
    NSComparisonResult result;
    NSURL *urlToBeDeleted; 
    for (NSURL *url in self.cacheImages) {
        NSDate *lastAccessDate;
        [url getResourceValue:&lastAccessDate forKey:NSURLContentAccessDateKey error:nil];
        
        NSLog(@"file: %@ last access: %@", [[url path] lastPathComponent], lastAccessDate);
        NSLog(@"\n");
        
        result = [olderDate compare:lastAccessDate];
        if (result == NSOrderedDescending) { // The receiver is later in time than anotherDate
            olderDate = lastAccessDate;
            urlToBeDeleted = url; 
        }
    }
    NSLog(@"url %@ with older view date %@ is next to be deleted", olderDate, [[urlToBeDeleted path]lastPathComponent]);
    
    return urlToBeDeleted; 
}

- (NSMutableArray *)cacheImages
{
    if (!_cacheImages) _cacheImages = [[NSMutableArray alloc] init];
    return _cacheImages; 
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
        
        if ([self currentSizeOfCache] < CACHE_MAX) { // CACHE_MAX 3MB
            [self.imageData writeToURL:filePath atomically:YES];
        }else{ // Evict least viewed photo
            NSURL *evictURL = [self leastRecentlyViewedPhoto];
            BOOL fileRemoved = [[NSFileManager defaultManager] removeItemAtURL:evictURL error:nil];
            if (fileRemoved){
                NSLog(@"%@ File was removed", evictURL);
                [self.imageData writeToURL:filePath atomically:YES];
                NSLog(@"%@ File was added to cache", [[filePath path] lastPathComponent]);
            }
        }
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

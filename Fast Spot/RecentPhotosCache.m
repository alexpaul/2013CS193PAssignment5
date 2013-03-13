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

#define CACHE_MAX 3000000 // 3MB

- (NSUInteger)currentSizeOfCache
{
#warning incomplete implementation 
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
        //  Skips Directories
        if ([isDirectory boolValue] == YES) {
            [enumerator skipDescendants]; 
        }
        else{
            NSLog(@"url is %@", url);
            NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[url path] error:nil];
            NSNumber *fileSize = [attributes objectForKey:NSFileSize];
            NSLog(@"file size is %@", fileSize); 
        }
    }
    
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

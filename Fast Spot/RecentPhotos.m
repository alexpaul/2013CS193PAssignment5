//
//  RecentPhotos.m
//  SPoT
//
//  Created by Alex Paul on 3/5/13.
//  Copyright (c) 2013 Alex Paul. All rights reserved.
//

#import "RecentPhotos.h"

@implementation RecentPhotos


#define RECENT_PHOTOS_KEY @"Recent_Photos"
#define DATE_KEY @"Date_Key"
#define PHOTO_ID_KEY @"Photo_Id_Key"
#define SORT_BY_PHOTO_ID @"photoId"
#define SORT_BY_RECENT_PHOTO_DATE @"recentPhotoDate"
#define RECENTS_MAX_COUNT 10

+ (NSArray *)recentPhotos
{
    NSMutableArray *recentPhotos = [[NSMutableArray alloc] init];
    
    for (id pList in [[[NSUserDefaults standardUserDefaults] dictionaryForKey:RECENT_PHOTOS_KEY] allValues]) {
        RecentPhotos *recents = [[RecentPhotos alloc] initFromPropertyList:pList];
        [recentPhotos addObject:recents]; 
    }
    
    //  Sort recent photos by most recently viewed (date)
    NSMutableArray *sortedRecentPhotos = [[NSMutableArray alloc] initWithArray:recentPhotos];
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:SORT_BY_RECENT_PHOTO_DATE ascending:NO]; //key: photoId, recentPhotoDate
    NSArray *sortDescriptors = @[descriptor];
    [sortedRecentPhotos sortUsingDescriptors:sortDescriptors];

    return sortedRecentPhotos;
}

- (void)setPhotoId:(NSString *)photoId
{
    BOOL duplicate = NO; 
    for (RecentPhotos *recents in [RecentPhotos recentPhotos]) {
        if ([photoId isEqualToString:recents.photoId]) { // Checks for duplicates
            duplicate = YES; 
        }
    }
    
    //  If photo id is not a duplicate add it to NSUserDefaults
    if (duplicate == NO) {
        if ([[RecentPhotos recentPhotos] count] < RECENTS_MAX_COUNT) { // limit the number of photos in recent photos
            _photoId = photoId;
            self.recentPhotoDate = [NSDate date];
            [self synchronize];
        }
    }
}

- (id)init
{
    if (self = [super init]){
        _recentPhotoDate = [NSDate date];
    }
    return self; 
}

- (id)initFromPropertyList: (NSDictionary *)pList
{
    if (self = [super init]) {
        _recentPhotoDate = [pList objectForKey:DATE_KEY];
        _photoId = [pList objectForKey:PHOTO_ID_KEY];
        if (!_recentPhotoDate) self = nil; 
    }
    return self; 
}

- (void)synchronize
{
    NSMutableDictionary *mutableRecentPhotosFromUserDefaults = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:RECENT_PHOTOS_KEY] mutableCopy];
    
    if (!mutableRecentPhotosFromUserDefaults) mutableRecentPhotosFromUserDefaults = [[NSMutableDictionary alloc] init];

    mutableRecentPhotosFromUserDefaults[[self.recentPhotoDate description]] = [self asPropertyList]; // NSDate can't be Keys so we use description of date which is an NSString for the key
    
    [[NSUserDefaults standardUserDefaults] setObject:mutableRecentPhotosFromUserDefaults forKey:RECENT_PHOTOS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize]; // writes to the persistence domain
}

- (id)asPropertyList
{
    return @{DATE_KEY : self.recentPhotoDate, PHOTO_ID_KEY : self.photoId};
}

@end
